const std = @import("std");

const Rule = struct {
    pattern: []const u8,
    dir_only: bool,
};

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);

    var null_separated = false;
    var root: []const u8 = ".";

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (std.mem.eql(u8, arg, "-0")) {
            null_separated = true;
        } else if (std.mem.startsWith(u8, arg, "-")) {
            std.debug.print("unknown flag: {s}\n", .{arg});
            std.process.exit(1);
        } else {
            root = arg;
        }
    }

    var rules = std.ArrayList(Rule).empty;
    try loadGitIgnore(init, arena, root, &rules);

    const root_dir = if (std.fs.path.isAbsolute(root))
        try std.Io.Dir.openDirAbsolute(init.io, root, .{ .iterate = true })
    else
        try std.Io.Dir.cwd().openDir(init.io, root, .{ .iterate = true });
    defer root_dir.close(init.io);

    try walk(init, arena, root_dir, root, &rules, null_separated);
}

fn loadGitIgnoreFromDir(
    io: std.Io,
    arena: std.mem.Allocator,
    dir: std.Io.Dir,
    rules: *std.ArrayList(Rule),
) !void {
    const file = dir.openFile(io, ".gitignore", .{}) catch |err| switch (err) {
        error.FileNotFound => return,
        error.AccessDenied => return,
        else => |e| return e,
    };
    defer file.close(io);

    const stat = try file.stat(io);
    const content = try arena.alloc(u8, @intCast(stat.size));
    _ = try file.readPositionalAll(io, content, 0);

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \r\t");
        if (line.len == 0 or line[0] == '#')
            continue;
        try rules.append(arena, .{
            .pattern = try arena.dupe(u8, line),
            .dir_only = std.mem.endsWith(u8, line, "/"),
        });
    }
}

fn loadGitIgnore(
    init: std.process.Init,
    arena: std.mem.Allocator,
    root: []const u8,
    rules: *std.ArrayList(Rule),
) !void {
    const root_dir = if (std.fs.path.isAbsolute(root))
        try std.Io.Dir.openDirAbsolute(init.io, root, .{})
    else
        try std.Io.Dir.cwd().openDir(init.io, root, .{});
    defer root_dir.close(init.io);

    try loadGitIgnoreFromDir(init.io, arena, root_dir, rules);
}

fn isBinary(io: std.Io, file: std.Io.File) bool {
    var buf: [8192]u8 = undefined;
    const bytes_read = file.readPositionalAll(io, &buf, 0) catch return false;
    return std.mem.indexOfScalar(u8, buf[0..bytes_read], 0) != null;
}

fn ignored(
    path: []const u8,
    rules: []const Rule,
) bool {
    for (rules) |rule| {
        var pattern = rule.pattern;

        if (rule.dir_only) {
            pattern = pattern[0 .. pattern.len - 1];
        }

        if (std.mem.startsWith(u8, pattern, "*.")) {
            const ext = pattern[1..];
            if (std.mem.endsWith(u8, path, ext)) {
                return true;
            }
        } else {
            if (std.mem.indexOf(u8, path, pattern) != null) {
                return true;
            }
        }
    }

    return false;
}

fn walk(
    init: std.process.Init,
    arena: std.mem.Allocator,
    dir: std.Io.Dir,
    dir_path: []const u8,
    rules: *std.ArrayList(Rule),
    null_separated: bool,
) !void {
    var iter = dir.iterate();
    while (try iter.next(init.io)) |entry| {
        if (std.mem.eql(u8, entry.name, ".git"))
            continue;

        const full_path = try std.fs.path.join(arena, &.{ dir_path, entry.name });

        if (ignored(full_path, rules.items))
            continue;

        switch (entry.kind) {
            .file => {
                const file = dir.openFile(init.io, entry.name, .{}) catch |err| switch (err) {
                    error.FileNotFound => continue,
                    error.AccessDenied => continue,
                    else => |e| return e,
                };
                defer file.close(init.io);

                if (isBinary(init.io, file))
                    continue;

                if (null_separated) {
                    std.debug.print("{s}\x00", .{full_path});
                } else {
                    std.debug.print("{s}\n", .{full_path});
                }
            },
            .directory => {
                const subdir = try dir.openDir(init.io, entry.name, .{ .iterate = true });
                defer subdir.close(init.io);

                const prev_len = rules.items.len;
                defer rules.shrinkRetainingCapacity(prev_len);

                try loadGitIgnoreFromDir(init.io, arena, subdir, rules);
                try walk(init, arena, subdir, full_path, rules, null_separated);
            },
            else => {},
        }
    }
}
