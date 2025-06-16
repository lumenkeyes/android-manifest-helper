const std = @import("std");
const fallbackFeaturesFile =  @embedFile("src/androidStrings/androidFeatures.txt");
pub const Helper = @import("src/root.zig");
pub const Manifest = Helper.manifest;
pub const ManifestConfig = Helper.ManifestConfig;

pub fn build(b: *std.Build) !void {
    const api_level = b.option(usize, "android_api_level", "the version of android you're targeting");
    const maybe_sdk_path = b.option([]const u8, "android_sdk_path", "the version of android you're targeting");
    const userOptions = b.addOptions();

    const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_mod = b.addModule("root", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    if(api_level) |level| {
        const sdk_root = maybe_sdk_path orelse 
        std.process.getEnvVarOwned(b.allocator, "ANDROID_SDK_ROOT")
        catch @panic("android_sdk_path must be specified if android_api_level is specified");

        userOptions.addOption(usize, "android_api_level", level);
        userOptions.addOption([]const u8, "android_sdk_path", sdk_root);
        const fullPath = b.fmt("{s}/platforms/android-{d}/data/features.txt", .{sdk_root, level});
        root_mod.addAnonymousImport("features", .{ .root_source_file = .{ .cwd_relative = fullPath } });
    } else {
        root_mod.addAnonymousImport("features", .{ .root_source_file = b.path("src/androidStrings/androidFeatures.txt") });
    }

    const tests_step = b.step("test", "Run tests");

    const tests = b.addTest(.{
        .version = version,
        .root_module = root_mod
    });

    const tests_run = b.addRunArtifact(tests);
    tests_step.dependOn(&tests_run.step);
    b.getInstallStep().dependOn(tests_step);
}
