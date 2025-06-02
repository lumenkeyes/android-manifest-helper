const std = @import("std");
pub const Helper = @import("src/root.zig");

pub fn build(b: *std.Build) !void {
    const api_level = b.option(usize, "api_level", "the version of android you're targeting");
    const userOptions = b.addOptions();

    if(api_level) |level| {
        userOptions.addOption(usize, "api_level", level);
        const sdk_root = try std.process.getEnvVarOwned(b.allocator, "ANDROID_SDK_ROOT");
        const fullPath = b.fmt("{s}/platforms/android-{d}/data/features.txt", .{sdk_root, level});
        const file = try std.fs.openFileAbsolute(fullPath, .{});
        const contents = try file.readToEndAlloc(b.allocator, 1024 * 1024);
        std.debug.print("{s}\n", .{contents});
    }

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
