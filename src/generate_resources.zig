const std = @import("std");
const LazyPath = std.Build.LazyPath;
pub const ResourcesConfig = struct {
    appName: []const u8,
    packageName: []const u8,
    embedFiles: []const struct {
        name: []const u8,
        bytes: []const u8
    } = &.{}
};

pub fn createResources(b: *std.Build, conf: ResourcesConfig) !LazyPath {

    if(conf.embedFiles.len < 1) {
        std.log.err("must include at least one embedded resource!", .{});
        return error.noResources;
    }

    const stringsTemplate =
    \\<?xml version="1.0" encoding="utf-8"?>
    \\<resources>
    \\    <string name="app_name">{[appName]s}</string>
    \\    <string name="package_name">{[packageName]s}</string>
    \\</resources>
    ;
    const renderedStrings = b.fmt(stringsTemplate, .{
        .appName = conf.appName,
        .packageName = conf.packageName,
    });

    const wf = b.addWriteFiles();

    _ = wf.add("values/strings.xml", renderedStrings);
    for(conf.embedFiles) |file| {
        _ = wf.add(file.name, file.bytes);
    }

    const resourceDir = wf.getDirectory();
    return resourceDir;
}
