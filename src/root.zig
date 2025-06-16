const std = @import("std");
const LazyPath = std.Build.LazyPath;
const androidPermNames = @embedFile("androidStrings/androidPermNames.txt");
const androidFeatures = @embedFile("androidStrings/androidFeatures.txt");

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

/// https://developer.android.com/guide/topics/manifest/manifest-intro
pub const ManifestConfig = struct {
    apiLevel: u32,
    packageName: []const u8,
    activities: []const AndroidActivity,
    appProperties: struct{
        standard: AndroidAppProperties = .{},
        custom: []const struct {
            name: []const u8,
            value: []const u8
        } = &.{}
    } = .{},
    permissions: []const struct {
        name: []const u8,
        requested: bool = true
    } = &.{},
    features: []const struct {
        name: []const u8,
        required: bool = true,
    } = &.{},
    ndkPath: ?[]const u8 = null,
    glEsVersion: []const u8 = ""
};

/// https://developer.android.com/guide/topics/manifest/application-element
pub const AndroidAppProperties = struct {
    allowTaskReparenting: ?bool = null,
    allowBackup: ?bool = null,
    allowClearUserData: ?bool = null,
    allowNativeHeapPointerTagging: ?bool = null,
    appCategory: ?enum {
        accessibility,
        audio,
        game,
        image,
        maps,
        news,
        productivity,
        social,
        video
    } = null,
    backupAgent: ?[]const u8 = null,
    backupInForeground: ?bool = null,
    /// drawable resource
    banner: ?[]const u8 = null,
    /// string resource
    dataExtractionRules: ?[]const u8 = null,
    debuggable: ?bool = null,
    /// string resource
    description: ?[]const u8 = null,
    enabled: ?bool = null,
    enabledOnBackInvokedCallback: ?bool = null,
    extractNativeLibs: ?bool = null,
    fullBackupContent: ?[]const u8 = null,
    fullBackupOnly: ?bool = null,
    gwpAsanMode: ?enum { always, never } = null,
    hasCode: ?bool = true,
    hasFragileUserData: ?bool = null,
    hardwareAccelerated: ?bool = null,
    /// drawable resource, your app's launcher icon
    icon: ?[]const u8 = "@mipmap/ic_launcher",
    isGame: ?bool = null,
    isMonitoringTool: ?enum { parental_control, enterprise_management, other } = null,
    killAfterRestore: ?bool = null,
    largeHeap: ?bool = null,
    label: ?[]const u8 = "@string/app_name",
    /// drawable resource
    logo: ?[]const u8 = null,
    manageSpaceActivity: ?[]const u8 = null,
    name: ?[]const u8 = null,
    /// xml resource
    networkSecurityConfig: ?[]const u8 = null,
    permission: ?[]const u8 = null,
    persistent: ?bool = null,
    process: ?[]const u8 = null,
    restoreAnyVersion: ?bool = null,
    requestLegacyExternalStorage: ?bool = null,
    requiredAccountType: ?[]const u8 = null,
    resizeableActivity: ?bool = null,
    restrictedAccountType: ?[]const u8 = null,
    supportsRtl: ?bool = null,
    taskAffinity: ?[]const u8 = null,
    testOnly: ?bool = null,
    /// A theme/style (e.g., "@android:style/Theme.NoTitleBar.Fullscreen")
    theme: ?[]const u8 = null, //resource or theme
    uiOptions: ?enum {none, splitActionBarWhenNarrow} = null,
    usesCleartextTraffic: ?bool = null,
    vmSafeMode: ?bool = null,
};

/// https://developer.android.com/guide/topics/manifest/activity-element
pub const AndroidActivity = struct {
    properties: struct {
        allowEmbedded: ?bool = null,
        allowTaskReparenting: ?bool = null,
        alwaysRetainTaskState: ?bool = null,
        autoRemoveFromRecents: ?bool = null,
        /// a drawable resource
        banner: ?[]const u8 = null,
        canDisplayOnRemoteDevices: ?bool = null,
        clearTaskOnLaunch: ?bool = null,
        colorMode: ?enum { hdr , wideColorGamut } = null,
        configChanges: ?[]const enum {
            colorMode,
            density,
            fontScale,
            fontWeightAdjustment,
            grammaticalGender,
            keyboard,
            keyboardHidden,
            layoutDirection,
            locale,
            mcc,
            mnc,
            navigation,
            orientation,
            screenLayout,
            screenSize,
            smallestScreenSize,
            touchscreen,
            uiMode
        } = null,
        directBootAware: ?bool = null,
        documentLaunchMode: ?enum {intoExisting , always ,
                              none , never } = null,
        enabled: ?bool = null,
        enabledOnBackInvokedCallback: ?bool = null,
        excludeFromRecents: ?bool = null,
        exported: ?bool = true,
        finishOnTaskLaunch: ?bool = null,
        hardwareAccelerated: ?bool = null,
        /// a drawable resource
        icon: ?[]const u8 = null,
        immersive: ?bool = null,
        /// a string resource, defaults to inheriting from the app
        label: ?[]const u8 = null,
        launchMode: ?enum {
                standard, 
                singleTop,
                singleTask,
                singleInstance, 
                singleInstancePerTask 
            } = null,
        lockTaskMode: ?enum {
                normal, 
                never,
                if_whitelisted, 
                always 
            } = null,
        maxRecents: ?i64 = null,
        maxAspectRatio: ?f64 = null,
        multiprocess: ?bool = null,
        /// the name of the java class this activity inherits from (e.g., Activity, NativeActivity, etc.)
        name: ?[]const u8 = null,
        noHistory: ?bool = null,
        parentActivityName: ?[]const u8 = null ,
        persistableMode: ?enum {persistRootOnly , 
                               persistAcrossReboots , persistNever } = null,
        permission: ?[]const u8 = null,
        process: ?[]const u8 = null,
        relinquishTaskIdentity: ?bool = null,
        requireContentUriPermissionFromCaller: ?enum {
                none,
                read,
                readAndWrite,
                readOrWrite, 
                write
            }  = null,
        resizeableActivity: ?bool = null,
        screenOrientation: ?enum {
                unspecified, 
                behind,
                reverseLandscape, 
                reversePortrait ,
                sensorLandscape , 
                sensorPortrait ,
                userLandscape , userPortrait ,
                sensor, fullSensor , nosensor ,
             user , fullUser , locked } = null,
        showForAllUsers: ?bool = null,
        stateNotNeeded: ?bool = null,
        supportsPictureInPicture: ?bool = null,
        taskAffinity: ?[]const u8 = null,
        /// resource or theme
        theme: ?[]const u8 = null,
        uiOptions: ?enum {
                none, 
                splitActionBarWhenNarrow 
            } = null,
        windowSoftInputMode: ?[]const enum {
                stateUnspecified,
                stateUnchanged, 
                stateHidden,
                stateAlwaysHidden, 
                stateVisible,
                stateAlwaysVisible, 
                adjustUnspecified,
                adjustResize, 
                adjustPan 
            } = null,
},
    metadata: ?[]const struct {
        name: []const u8,
        value: []const u8
    } = &.{},
    intentFilters: ?[]const u8 = null,
};


const indent = " " ** 2;
const appPropIndent = 3;
const activityPropIndent = 4;
const tagClose = " />";

fn anyAsString(allocator: std.mem.Allocator, comptime T: type, val: anytype, comptime fieldName: []const u8) []const u8 {
        _ = fieldName;
        const valString = switch(T) {
            []const u8 => val,
            bool, i64, u64, f64 => std.fmt.allocPrint(allocator, "{any}", .{val}) catch @panic("OOM"),
            else => blk: {
                if(@hasField(T, "len")) {
                    var tagNames = std.ArrayList([]const u8).init(allocator);
                    for(val) |name| {
                        tagNames.append(@tagName(name)) catch @panic("OOM");
                    }
                    const nameSlices = tagNames.toOwnedSlice() catch @panic("OOM");
                    break :blk std.mem.join(allocator, "|", nameSlices) catch @panic("OOM");
            } else {
                break :blk @tagName(val);
            }
        }
    };
    return valString;
}

fn formatProps(allocator: std.mem.Allocator, instance: anytype, comptime indentCount: usize) ![]const u8 {
        var propertiesString: []const u8 = "";
        var propCount: usize = 0;
        inline for(comptime std.meta.fieldNames(@TypeOf(instance))) |fieldName| {
            if(@field(instance, fieldName)) |val| {
                const valString = anyAsString(allocator, @TypeOf(val), val, fieldName);
                propertiesString = try std.mem.concat(allocator, u8, &.{
                    propertiesString,
                    if(propCount > 0) (indent ** indentCount) else "",
                    "android:", fieldName, "=\"", valString, "\"", "\n"
                });
                propCount += 1;
            }
        }
        return propertiesString;
}

// https://developer.android.com/guide/topics/manifest/uses-feature-element#features-reference
// https://developer.android.com/ndk/guides/sdk-versions#compilesdkversion
// https://developer.android.com/reference/android/Manifest.permission
pub const manifest = struct {
    const Self = @This();
    conf: ManifestConfig,
    allocator: std.mem.Allocator,
    pub fn init(alloc: std.mem.Allocator, conf: ManifestConfig) !*Self {
        var self = try alloc.create(Self);
        self.conf = conf;
        self.allocator = alloc;
        return self;
    }

    pub fn fmt(self: *Self, comptime formatString: []const u8, args: anytype) ![]const u8 {
        return try std.fmt.allocPrint(self.allocator, formatString, args);
    }

    /// call this AFTER adding all desired artifacts to your APK
    pub fn addToApk(self: *Self, b: *std.Build, apk: anytype) !void {
        const hasCode = self.conf.appProperties.standard.hasCode orelse {
            std.log.err("hasCode property should not be null", .{});
            return error.InvalidProperty;
        };
        if(hasCode) {
            if(apk.java_files.items.len == 0) {
            std.log.err("must add at least one java source file or configure the android manifest with hasCode=\"false\"", .{});
            return error.MissingJavaFiles;
            }
        } else {}

        blk: {
            for(self.conf.activities) |activity| {
                if(activity.metadata == null) break :blk;
                var requiresNamedLib: bool = false;
                var requiredLibName: []const u8 = undefined;
                var haveMatchingLib: bool = false;
                var haveMainLib: bool = false;
                for(activity.metadata.?) |meta| {
                    if(std.mem.eql(u8, "android.app.lib_name", meta.name)) {
                        requiresNamedLib = true;
                        requiredLibName = meta.value;
                        for(apk.artifacts.items) |artifact| {
                            if(std.mem.eql(u8, meta.value, artifact.name)) haveMatchingLib = true;
                            if(std.mem.eql(u8, "main", artifact.name)) haveMainLib = true;
                        }
                    }
                }
                if(requiresNamedLib) {
                    if(!haveMatchingLib) {
                        std.log.err("android.app.lib_name \"{s}\" of activity does not match any artifact currently installed to APK\n", .{requiredLibName});
                        return error.MissingLibrary;
                    }
                } else {
                    if(!haveMainLib and !hasCode) {
                        std.log.err("Native Activity requires a corresponding shared library, either \"libmain.so\" or a custom name declared in activity metadata", .{});
                        return error.MissingLibrary;
                    }
                }
            }
        }
        const renderedManifest = try self.print();
        const wf = b.addWriteFiles();
        const lp: LazyPath = wf.add("AndroidManifest.xml", renderedManifest);
        apk.setAndroidManifest(lp);
    }

    pub fn print(self: *Self) ![]const u8 {
        const conf = self.conf;
        for(conf.activities) |activity| {
            if(activity.properties.exported) |exported| {
                if(exported == false) {
                    //FIXME: should only error if activity is launchable from another app (say, perhaps, a luncher?)
                    std.log.err("must export at least one activity class\n", .{});
                }
            }
        }

        const manifestHeaderTemplate = 
        \\<?xml version="1.0" encoding="utf-8"?>
        \\<manifest
        \\  xmlns:android="http://schemas.android.com/apk/res/android"
        \\  xmlns:tools="http://schemas.android.com/tools"
        \\  package="{[packageName]s}"
        \\  >
        \\
        ;
        const renderedHeader = try self.fmt(manifestHeaderTemplate, .{
            .packageName = conf.packageName
        });

        const manifestFeaturesTemplate = 
        \\  {[featureString]s}
        \\  {[permissionString]s}
        \\  <uses-sdk android:minSdkVersion="{[minSdkVersion]d}" />
        \\
        ;

        var permissionString: []const u8 = "";
        for(conf.permissions, 1..) |perm, i| {
            if(std.mem.containsAtLeast(u8, androidPermNames, 1, perm.name)) {
                permissionString = try std.mem.concat(self.allocator, u8, &.{
                    permissionString,
                    if(i > 1) (" " ** 2) else "",
                    "<uses-permission android:name=\"android.permission.", perm.name, "\"",
                    tagClose,
                    if(i < conf.permissions.len) "\n" else ""
                });
            } else {
                std.log.err("not a recognized permission name: {s}\n", .{perm.name});
            }
        }

        var featureString: []const u8 = "";
        for(conf.features, 1..) |feature, i| {
            if(std.mem.containsAtLeast(u8,androidFeatures, 1, feature.name)) {
                featureString = try std.mem.concat(self.allocator, u8, &.{
                    featureString, 
                    "<uses-feature ", feature.name, 
                    " android:required=\"", (if(feature.required) "true" else "false"), "\"",
                    tagClose,
                    if(i < (conf.features.len) or conf.glEsVersion.len > 0) "\n" else ""
                });
            } else {
                std.log.err("not a recognized feature name: {s}\n", .{feature.name});
            }
        }
        //TODO: sensible default gles version

        featureString = try std.mem.concat(self.allocator, u8, &.{
            featureString,
            "<uses-feature android:glEsVersion=\"", conf.glEsVersion, "\" android:required=\"true\"",
            tagClose
        });

        const renderedFeatures = try self.fmt(manifestFeaturesTemplate, .{
            .permissionString = permissionString,
            .featureString = featureString,
            .minSdkVersion = conf.apiLevel
        });

        var propertiesString: []const u8 = try formatProps(self.allocator, conf.appProperties.standard, appPropIndent);
        for(conf.appProperties.custom) |prop| {
            propertiesString = try std.mem.concat(self.allocator, u8, &.{
                propertiesString,
                (indent ** appPropIndent),
                prop.name, "=\"", prop.value, "\"", "\n"
            });
        }
        propertiesString = try std.mem.concat(self.allocator, u8, &.{
            (indent ** appPropIndent),
            propertiesString,
            (indent ** appPropIndent), ">\n"
        });

        var activitiesString: []const u8 = indent ** (activityPropIndent - 1);
        for(conf.activities, 1..) |activity, i| {
            var metaDataString: []const u8 = "";
            if(activity.metadata) |metadata| {
                for(metadata) |metaProp| {
                   metaDataString = try std.mem.concat(self.allocator, u8, &.{
                        indent ** (activityPropIndent + 1),
                        "<meta-data android:name=\"", metaProp.name, "\" ",
                        "android:value=\"", metaProp.value, "\"", tagClose, "\n"
                    }); 
                }
            }
            activitiesString = try std.mem.concat(self.allocator, u8, &.{
                activitiesString,
                "<activity\n", (indent ** activityPropIndent),
                try formatProps(self.allocator, activity.properties, activityPropIndent),
                (indent ** activityPropIndent), ">\n",
                metaDataString,
                \\          <intent-filter>
                \\              <action android:name="android.intent.action.MAIN" />
                \\              <category android:name="android.intent.category.LAUNCHER" />
                \\          </intent-filter>
                \\      </activity>
                , if(i != conf.activities.len) "\n" else ""
            });
        }

        const renderedManifest = try std.mem.concat(self.allocator, u8, &.{
            renderedHeader, 
            renderedFeatures, 
            indent, "<application\n",
            propertiesString,
            activitiesString, "\n",
            indent, "</application>\n",
            "</manifest>"
        });
        return renderedManifest;


    }
};

const exampleManifest =
\\<?xml version="1.0" encoding="utf-8"?>
\\<manifest
\\  xmlns:android="http://schemas.android.com/apk/res/android"
\\  xmlns:tools="http://schemas.android.com/tools"
\\  package="com.zig.minimal"
\\  >
\\  <uses-feature android:glEsVersion="0x00020000" android:required="true" />
\\  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
\\  <uses-permission android:name="android.permission.INTERNET" />
\\  <uses-sdk android:minSdkVersion="29" />
\\  <application
\\      android:hasCode="false"
\\      android:icon="@mipmap/ic_launcher"
\\      android:label="@string/app_name"
\\      android:theme="@android:style/Theme.NoTitleBar.Fullscreen"
\\      tools:targetApi="29"
\\      >
\\      <activity
\\        android:configChanges="layoutDirection|locale|orientation|uiMode|screenLayout|screenSize|smallestScreenSize|keyboard|keyboardHidden|navigation"
\\        android:exported="true"
\\        android:launchMode="singleInstance"
\\        android:name="android.app.NativeActivity"
\\        >
\\          <meta-data android:name="android.app.lib_name" android:value="main" />
\\          <intent-filter>
\\              <action android:name="android.intent.action.MAIN" />
\\              <category android:name="android.intent.category.LAUNCHER" />
\\          </intent-filter>
\\      </activity>
\\  </application>
\\</manifest>
;

test "generate correct manifest" {
    std.testing.refAllDecls(@This());
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();
    const test_manifest = try manifest.init(alloc, .{
            .apiLevel = 29,
            .packageName = "com.zig.minimal",
            .permissions = &.{
                .{.name = "ACCESS_NETWORK_STATE"}, 
                .{.name = "INTERNET"},
            },
            .appProperties = .{ 
                .standard = .{ .hasCode = false, .theme = "@android:style/Theme.NoTitleBar.Fullscreen"},
                .custom = &.{
                    .{
                        .name = "tools:targetApi",
                        .value = try std.fmt.allocPrint(alloc, "{d}", .{29})
                    }
                }
            },
            .activities =  &.{
                .{
                    .properties = .{
                        .launchMode = .singleInstance,
                        .name = "android.app.NativeActivity",
                        .configChanges = &.{.layoutDirection, .locale, .orientation, .uiMode, .screenLayout, .screenSize, .smallestScreenSize, .keyboard, .keyboardHidden, .navigation}
                    },
                    .metadata = &.{
                        .{
                            .name = "android.app.lib_name",
                            .value = "main"
                        }
                    }
                }
            },
            .glEsVersion = "0x00020000"
    });
    const outputManifest = try test_manifest.print();
    defer alloc.free(outputManifest);
    try std.testing.expectEqualStrings(exampleManifest, outputManifest);
}
