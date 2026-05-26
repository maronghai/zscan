const std = @import("std");

pub fn build(b: *std.Build) !void {
    comptime {
        switch (@typeInfo(@typeInfo(@TypeOf(build)).@"fn".return_type.?)) {
            .void, .error_union => {},
            else => @compileError("build must return void or !void"),
        }
    }

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zscan",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run zscan");
    run_step.dependOn(&run_cmd.step);
}
