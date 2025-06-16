const std = @import("std");

pub fn build(b: *std.Build) !void {
    // const api_level = b.option(usize, "android_api_level", "the version of android you're targeting");
    // const maybe_sdk_path = b.option([]const u8, "android_sdk_path", "the version of android you're targeting");
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
    _ = b.addModule("stripJava", .{ 
        .root_source_file = b.path("src/stripJava.zig"),
        .target = target,
        .optimize = optimize
    });
    _ = b.addModule("fallback_permissions", .{
        .root_source_file = b.path("src/androidStrings/androidPermNames.txt"),
        .target = target,
        .optimize = optimize
    });
    _ = b.addModule("fallback_features", .{
        .root_source_file = b.path("src/androidStrings/androidFeatures.txt"),
        .target = target,
        .optimize = optimize
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
pub fn buildManifest(conf: struct {
    b: *std.Build,
    manifest_conf: ManifestConfig,
    conf_as_bytes: []const u8,
    sdkPath: ?[]const u8 = null,
    apiLevel: ?u8 = null,
}) !std.Build.LazyPath {
    const b = conf.b;
    if(conf.sdkPath) |sdkPath| {
        const platformPath = b.fmt("{s}/platforms/android-{d}", .{sdkPath, conf.apiLevel.?});
        const featuresPath = b.fmt("{s}/data/features.txt", .{platformPath});
        const jarPath = b.fmt("{s}/android.jar", .{platformPath});

        const extract = b.addSystemCommand(&.{"unzip"});
        extract.addFileArg(.{ .cwd_relative = jarPath });
        // extract.step.makeFn 
        // extract.addArg("-u");
        extract.addArg("-d");
        const output = extract.addOutputDirectoryArg("extractedJar");

        const readClass = b.addSystemCommand(&.{"javap"});
        // const convertedPath = convertPathArg(readClass, );
        readClass.addFileArg(output.path(b, "android/Manifest$permission.class"));
        const classOutput = readClass.captureStdOut();

        const string_mod = b.dependency("android_manifest_helper", .{}).module("stripJava");
        // string_mod.addAnonymousImport("javap_output", .{ .root_source_file = classOutput });
        const strip_tool = b.addExecutable(.{ 
            .root_module = string_mod,
            .name = "strip_javap_output",
        });
        const run_strip_tool = b.addRunArtifact(strip_tool);
        run_strip_tool.addFileArg(classOutput);
        const stripped_output = run_strip_tool.captureStdOut();

        const manifest_mod = b.dependency("android_manifest_helper", .{}).module("manifest");
        manifest_mod.addAnonymousImport("features", .{ .root_source_file = .{ .cwd_relative = featuresPath } });
        manifest_mod.addAnonymousImport("permissions", .{ .root_source_file = stripped_output });

        // const structAsBytes: []const u8 = &std.mem.toBytes(conf.manifest_conf);
        std.log.debug("{any}\n", .{conf.manifest_conf});
        // std.log.debug("struct as bytes len: {d}\n", .{structAsBytes.len});
        // std.log.debug("struct as bytes ptr: {any}\n", .{structAsBytes.ptr});

        const write_conf_struct = b.addWriteFiles();
        // const mf_conf_file = write_conf_struct.add("manifest_conf", conf.conf_as_bytes);

        const opts = b.addOptions();
        opts.addOption(ManifestConfig, "manifest_conf", conf.manifest_conf);
        manifest_mod.addOptions("build_options", opts);
        const generate_manifest = b.addExecutable(.{ .root_module = manifest_mod, .name = "generate_manifest" });
        const run_generate_manifest = b.addRunArtifact(generate_manifest);

        // run_generate_manifest.addFileArg(mf_conf_file.dupe(b));
        // manifest_mod.addAnonymousImport("manifest_config", .{ .root_source_file = mf_conf_file });

        const generated_output = run_generate_manifest.captureStdOut();

        readClass.step.dependOn(&extract.step);

        run_strip_tool.step.dependOn(&readClass.step);
        // strip_step.step.dependOn(&wf.step);

        // mf_conf_file.addStepDependencies(&generate_manifest.step);
        // mf_conf_file.addStepDependencies(&run_generate_manifest.step);

        generate_manifest.step.dependOn(&run_strip_tool.step);
        generate_manifest.step.dependOn(&write_conf_struct.step);

        run_generate_manifest.step.dependOn(&write_conf_struct.step);
        run_generate_manifest.step.dependOn(&run_strip_tool.step);
        run_generate_manifest.step.dependOn(&generate_manifest.step);

        b.getInstallStep().dependOn(&run_generate_manifest.step);
        // b.getInstallStep().dependOn(&wf.step);

        return generated_output;
    } else {
        return conf.b.dependency("android_manifest_helper", .{}).module("fallback_permissions").root_source_file.?;
        // return conf.b.dependency("android_manifest_helper", .{}).path("src/androidStrings/androidPermNames.txt");
        // return .{
        //     .features = conf.b.dependency("android_manifest_helper").path("src/androidStrings/androidFeatures.txt"),
        //     .permissions = conf.b.dependency("android_manifest_helper").path("src/androidStrings/androidPermNames.txt")
        // };
    }
}

pub fn createManifest(
    b: *std.Build,
    manifest_conf: ManifestConfig,
    sdkPath: ?[]const u8,
    apiLevel: ?u8,
) !void {
        const platformPath = b.fmt("{s}/platforms/android-{d}", .{sdkPath.?, apiLevel.?});
        const featuresPath = b.fmt("{s}/data/features.txt", .{platformPath});
        const jarPath = b.fmt("{s}/android.jar", .{platformPath});

        try b.cache_root.handle.deleteTree("extractedJar");
        try b.cache_root.handle.makeDir("extractedJar");
        const extractedJarPath = try b.cache_root.handle.realpathAlloc(b.allocator, "extractedJar");
        var extract = std.process.Child.init(&.{"unzip", jarPath, "-d", extractedJarPath}, b.allocator);
        extract.stdout_behavior = .Pipe;
        _ = try extract.spawnAndWait();

        var readClassOutput: std.ArrayListUnmanaged(u8) = .empty;
        var readClassStdErr: std.ArrayListUnmanaged(u8) = .empty;

        var readClass = std.process.Child.init(&.{"javap", b.fmt("{s}/android/Manifest$permission.class", .{extractedJarPath})}, b.allocator);
        readClass.stdout_behavior = .Pipe;
        try readClass.spawn();
        try readClass.collectOutput(b.allocator, &readClassOutput, &readClassStdErr, 8196);
        _ = try readClass.wait();

        const strippedOutput = try @import("src/stripJava.zig").strip(readClassOutput.items, b.allocator);

        const featureFile = try std.fs.openFileAbsolute(featuresPath, .{});
        const featureString = try featureFile.readToEndAlloc(b.allocator, 8196);

        const printedManifest = try @import("src/generate_manifest.zig").print(manifest_conf, b.allocator, featureString, strippedOutput);
        std.log.debug("{s}\n", .{printedManifest});

        // const wf = b.addWriteFiles();
        // return wf.add("AndroidManifest.xml", printedManifest);
}

const Build = std.Build;
const Run = std.Build.Step.Run;

fn convertPathArg(run: *Run, path: Build.Cache.Path) []const u8 {
    const b = run.step.owner;
    const path_str = path.toString(b.graph.arena) catch @panic("OOM");
    const child_lazy_cwd = run.cwd orelse return path_str;
    const child_cwd = child_lazy_cwd.getPath3(b, &run.step).toString(b.graph.arena) catch @panic("OOM");
    return std.fs.path.relative(b.graph.arena, child_cwd, path_str) catch @panic("OOM");
}
pub const ManifestConfig = @import("src/types.zig").ManifestConfig;
const ResourcesConfig = @import("src/generate_resources.zig").ResourcesConfig;
pub fn createResources(b: *std.Build, conf: ResourcesConfig) !std.Build.LazyPath {
    return try @import("src/generate_resources.zig").createResources(b, conf);
        // return b.dependency("android_manifest_helper", .{}).path("src/androidStrings/androidPermNames.txt");
        // return b.dependency("android_manifest_helper", .{}).module("fallback_permissions").root_source_file.?;
}
// pub const Helper = @import("src/root.zig");
