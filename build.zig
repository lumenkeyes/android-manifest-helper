const std = @import("std");
const Build = std.Build;
const Run = std.Build.Step.Run;
pub const ManifestConfig = @import("src/types.zig").ManifestConfig;
pub const ResourcesConfig = @import("src/generate_resources.zig").ResourcesConfig;

const fallbackFeatures = @embedFile("src/androidStrings/androidFeatures.txt");
const fallbackPermissions = @embedFile("src/androidStrings/androidPermNames.txt");

pub fn build(b: *std.Build) !void {
    const userOptions = b.addOptions();
    userOptions.addOption([]const u8, "features", @embedFile("src/androidStrings/androidFeatures.txt"));

    const version = std.SemanticVersion{ .major = 0, .minor = 1, .patch = 0 };
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_mod = b.addModule("manifest", .{
        .root_source_file = b.path("src/generate_manifest.zig"),
        .target = target,
        .optimize = optimize,
    });
    const tests_step = b.step("test", "Run tests");

    const tests = b.addTest(.{
        .version = version,
        .root_module = root_mod
    });

    const tests_run = b.addRunArtifact(tests);
    tests_step.dependOn(&tests_run.step);
    b.getInstallStep().dependOn(tests_step);
}

const CombinedConf = struct {
    b: *Build,
    manifest_conf: ManifestConfig,
    sdkPath: ?[]const u8 = null,
};

pub fn createManifest(apk: anytype, conf: CombinedConf) !void {
    const manifest = try createManifestUnchecked(conf);
    try @import("src/generate_manifest.zig").check(conf.manifest_conf, apk);
    apk.setAndroidManifest(manifest);
}

pub fn createManifestUnchecked(conf: CombinedConf) !std.Build.LazyPath {
    const b = conf.b;
    const manifest_contents = blk: {
        if(conf.sdkPath) |sdkPath| {
            const platformPath = b.fmt("{s}/platforms/android-{d}", .{sdkPath, conf.manifest_conf.apiLevel});
            const featuresPath = b.fmt("{s}/data/features.txt", .{platformPath});
            const jarPath = b.fmt("{s}/android.jar", .{platformPath});
            const classPath = b.fmt("jar:file://{s}!/android/Manifest$permission.class", .{jarPath});

            const readClass = b.run(&.{"javap", classPath});
            const permissons = try @import("src/stripJava.zig").strip(readClass, b.allocator);
            const featuresFile = try std.fs.openFileAbsolute(featuresPath, .{});
            const featuresFileStat = try featuresFile.stat();
            const features = try featuresFile.readToEndAlloc(b.allocator, featuresFileStat.size);
            break :blk try @import("src/generate_manifest.zig").print(conf.manifest_conf, b.allocator, features, permissons);
        } else {
            break :blk try @import("src/generate_manifest.zig").print(conf.manifest_conf, b.allocator, fallbackFeatures, fallbackPermissions);
        }
    };

    const wf = b.addWriteFiles();
    const manifest = wf.add("AndroidManifest.xml", manifest_contents);
    b.getInstallStep().dependOn(&wf.step);
    return manifest;
}


pub fn createResources(b: *std.Build, conf: ResourcesConfig) !std.Build.LazyPath {
    return try @import("src/generate_resources.zig").createResources(b, conf);
}
