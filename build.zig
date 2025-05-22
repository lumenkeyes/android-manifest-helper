const std = @import("std");
pub const Helper = @import("src/root.zig");

pub fn build(b: *std.Build) void {
    const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root = b.path("src/root.zig");

    _ = b.addModule("manifest_helper", .{
        .root_source_file = root,
        .target = target,
        .optimize = optimize,
    });

    const tests_step = b.step("test", "Run tests");

    const tests = b.addTest(.{
        .version = version,
        .root_module = b.createModule(.{
            .target = target,
            .root_source_file = root,
        }),
    });

    const tests_run = b.addRunArtifact(tests);
    tests_step.dependOn(&tests_run.step);
    b.getInstallStep().dependOn(tests_step);
}
