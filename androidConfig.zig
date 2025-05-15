const std = @import("std");
const LazyPath = std.Build.LazyPath;
const android = @import("android");

pub const embeddedResource = struct {
    name: []const u8,
    bytes: []const u8
};

pub const ResourcesConfig = struct {
    appName: []const u8,
    packageName: []const u8,
    embedFiles: []const embeddedResource = &.{}
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

pub const ManifestConfig = struct {
    apiLevel: u32,
    packageName: []const u8,
    appProperties: AndroidAppProperties = .{},
    activities: []const AndroidActivity,
    customAppProperties: []const CustomAndroidAppProperty = &.{},
    permissions: []const AndroidPermission = &.{},
    features: []const AndroidFeature = &.{},
    glEsVersion: []const u8 = ""
};

pub const AndroidFeature = struct {
    name: []const u8,
    required: bool,
};

pub const AndroidPermission = struct {
    name: []const u8,
    requested: bool = true
};


pub const AndroidAppCategory = enum {
    accessibility,
    audio,
    game,
    image,
    maps,
    news,
    productivity,
    social,
    video
};

// https://developer.android.com/guide/topics/manifest/application-element
pub const AndroidAppProperties = struct {
    allowTaskReparenting: ?bool = null,
    allowBackup: ?bool = null,
    allowClearUserData: ?bool = null,
    allowNativeHeapPointerTagging: ?bool = null,
    appCategory: ?AndroidAppCategory = null,
    backupAgent: ?[]const u8 = null,
    backupInForeground: ?bool = null,
    banner: ?[]const u8 = null, //drawable resource
    dataExtractionRules: ?[]const u8 = null, // "string resource"
    debuggable: ?bool = null,
    description: ?[]const u8 = null,// string resource
    enabled: ?bool = null,
    enabledOnBackInvokedCallback: ?bool = null,
    extractNativeLibs: ?bool = null,
    fullBackupContent: ?[]const u8 = null,
    fullBackupOnly: ?bool = null,
    gwpAsanMode: ?enum { always, never } = null,
    hasCode: ?bool = true,
    hasFragileUserData: ?bool = null,
    hardwareAccelerated: ?bool = null,
    icon: ?[]const u8 = "@mipmap/ic_launcher", //drawable resource
    isGame: ?bool = null,
    isMonitoringTool: ?enum { parental_control, enterprise_management, other } = null,
    killAfterRestore: ?bool = null,
    largeHeap: ?bool = null,
    label: ?[]const u8 = "@string/app_name",
    logo: ?[]const u8 = null, //drawable resource
    manageSpaceActivity: ?[]const u8 = null,
    name: ?[]const u8 = null,
    networkSecurityConfig: ?[]const u8 = null, // xml resource
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
    theme: ?[]const u8 = "@android:style/Theme.NoTitleBar.Fullscreen", //resource or theme
    uiOptions: ?enum {none, splitActionBarWhenNarrow} = null,
    usesCleartextTraffic: ?bool = null,
    vmSafeMode: ?bool = null,
};
pub const CustomAndroidAppProperty = struct {
    name: []const u8,
    value: []const u8
};

pub const AndroidActivityMetaData = struct {
    name: []const u8,
    value: []const u8
};

pub const AndroidActivity = struct {
    properties: AndroidActivityProperties,
    metadata: ?[]const AndroidActivityMetaData = &.{
        .{
            .name="android.app.lib_name",
            .value="main"
        }
    },
    intentFilters: ?[]const u8 = null,
};

pub const AndroidActivityHandleableConfigChanges = enum {
 colorMode, density, fontScale, fontWeightAdjustment,
        grammaticalGender, keyboard, keyboardHidden, layoutDirection, locale,
        mcc, mnc, navigation, orientation, screenLayout, screenSize,
        smallestScreenSize, touchscreen, uiMode
};

pub const AndroidActivityProperties = struct {
allowEmbedded: ?bool = null,
allowTaskReparenting: ?bool = null,
alwaysRetainTaskState: ?bool = null,
autoRemoveFromRecents: ?bool = null,
banner: ?[]const u8 = null, //"drawable resource",
canDisplayOnRemoteDevices: ?bool = null,
clearTaskOnLaunch: ?bool = null,
colorMode: ?enum { hdr , wideColorGamut } = null,
configChanges: ?[]const AndroidActivityHandleableConfigChanges = null,
directBootAware: ?bool = null,
documentLaunchMode: ?enum {intoExisting , always ,
                      none , never } = null,
enabled: ?bool = null,
enabledOnBackInvokedCallback: ?bool = null,
excludeFromRecents: ?bool = null,
exported: ?bool = true,
finishOnTaskLaunch: ?bool = null,
hardwareAccelerated: ?bool = null,
icon: ?[]const u8 = null, //"drawable resource",
immersive: ?bool = null,
label: ?[]const u8 = "@string/app_name", //"string resource",
launchMode: ?enum {standard , singleTop ,
                  singleTask , singleInstance , singleInstancePerTask } = null,
lockTaskMode: ?enum {normal , never ,
                  if_whitelisted , always } = null,
maxRecents: ?i64 = null,
maxAspectRatio: ?f64 = null,
multiprocess: ?bool = null,
name: ?[]const u8 = null,
noHistory: ?bool = null,
parentActivityName: ?[]const u8 = null ,
persistableMode: ?enum {persistRootOnly , 
                       persistAcrossReboots , persistNever } = null,
permission: ?[]const u8 = null,
process: ?[]const u8 = null,
relinquishTaskIdentity: ?bool = null,
requireContentUriPermissionFromCaller: ?enum {none , read , readAndWrite ,
                                             readOrWrite , write }  = null,
resizeableActivity: ?bool = null,
screenOrientation: ?enum {unspecified , behind ,
                         reverseLandscape , reversePortrait ,
                         sensorLandscape , sensorPortrait ,
                         userLandscape , userPortrait ,
                         sensor , fullSensor , nosensor ,
                         user , fullUser , locked } = null,
showForAllUsers: ?bool = null,
stateNotNeeded: ?bool = null,
supportsPictureInPicture: ?bool = null,
taskAffinity: ?[]const u8 = null,
theme: ?[]const u8 = null, //"resource or theme",
uiOptions: ?enum {none , splitActionBarWhenNarrow } = null,
windowSoftInputMode: ?enum {stateUnspecified,
                           stateUnchanged, stateHidden,
                           stateAlwaysHidden, stateVisible,
                           stateAlwaysVisible, adjustUnspecified,
                           adjustResize, adjustPan } = null,
};

const indent = " " ** 2;
const appPropIndent = 2;
const activityPropIndent = 3;
const tagClose = " />";

fn anyAsString(b: *std.Build, comptime T: anytype, val: anytype, comptime fieldName: []const u8) []const u8 {
        const valType = (@typeInfo(@TypeOf(@field(T{}, fieldName)))).optional.child;
        const valString = switch(valType) {
            []const u8 => val,
            bool, i64, u64, f64 => b.fmt("{any}", .{val}),
            []const AndroidActivityHandleableConfigChanges => blk: {
                var tagNames = std.ArrayList([]const u8).init(b.allocator);
                for(val) |name| {
                    tagNames.append(@tagName(name)) catch @panic("OOM");
                }
                const nameSlices = tagNames.toOwnedSlice() catch @panic("OOM");
                break :blk std.mem.join(b.allocator, "|", nameSlices) catch @panic("OOM");
            },
            else => @tagName(val)
        };
    return valString;
}

fn formatProps(b: *std.Build, instance: anytype, comptime indentCount: usize) ![]const u8 {
        var propertiesString: []const u8 = "";
        var propCount: usize = 0;
        inline for(comptime std.meta.fieldNames(@TypeOf(instance))) |fieldName| {
            if(@field(instance, fieldName)) |val| {
                const valString = anyAsString(b, @TypeOf(instance), val, fieldName);
                propertiesString = try std.mem.concat(b.allocator, u8, &.{
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
    b: *std.Build,
    pub fn init(b: *std.Build, conf: ManifestConfig) !*Self {
        var self = try b.allocator.create(Self);
        self.conf = conf;
        self.b = b;
        return self;
    }
    pub fn addToApk(self: *Self, apk: *android.APK) !void {
        const conf = self.conf;
        const b = self.b;


        if(apk.java_files.items.len == 0) {
            if(conf.appProperties.hasCode) |hasCode| {
                if(hasCode) {
                    std.log.err("must add at least one java source file or configure the android manifest with hasCode=\"false\"", .{});
                    return error.MissingJavaFiles;
                }
            } else {
                    std.log.err("hasCode property should not be null", .{});
                    return error.InvalidProperty;
            }
        }
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
        \\<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        \\   xmlns:tools="http://schemas.android.com/tools"
        \\   package="{[packageName]s}">
        \\
        ;
        const renderedHeader = b.fmt(manifestHeaderTemplate, .{
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
            if(std.mem.containsAtLeast(u8, @embedFile("androidStrings/androidPermNames.txt"), 1, perm.name)) {
                permissionString = try std.mem.concat(b.allocator, u8, &.{
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
            if(std.mem.containsAtLeast(u8, @embedFile("androidStrings/androidFeatures.txt"), 1, feature.name)) {
                featureString = try std.mem.concat(b.allocator, u8, &.{
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

        featureString = try std.mem.concat(b.allocator, u8, &.{
            featureString,
            "<uses-feature android:glEsVersion=\"", conf.glEsVersion, "\" android:required=\"true\"",
            tagClose
        });

        const renderedFeatures = b.fmt(manifestFeaturesTemplate, .{
            .permissionString = permissionString,
            .featureString = featureString,
            .minSdkVersion = conf.apiLevel
        });

        var propertiesString: []const u8 = try formatProps(b, conf.appProperties, appPropIndent);
        for(conf.customAppProperties) |prop| {
            propertiesString = try std.mem.concat(b.allocator, u8, &.{
                propertiesString,
                (indent ** appPropIndent),
                prop.name, "=\"", prop.value, "\"", "\n"
            });
        }
        propertiesString = try std.mem.concat(b.allocator, u8, &.{
            (indent ** appPropIndent),
            propertiesString,
            (indent ** appPropIndent), ">\n"
        });

        var activitiesString: []const u8 = indent ** (activityPropIndent - 1);
        for(conf.activities, 1..) |activity, i| {
            var metaDataString: []const u8 = "";
            if(activity.metadata) |metadata| {
                for(metadata) |metaProp| {
                   metaDataString = try std.mem.concat(b.allocator, u8, &.{
                        indent ** activityPropIndent,
                        "<meta-data android:name=\"", metaProp.name, "\" ",
                        "android:value=\"", metaProp.value, "\"", tagClose, "\n"
                    }); 
                }
            }
            activitiesString = try std.mem.concat(b.allocator, u8, &.{
                activitiesString,
                "<activity\n", (indent ** activityPropIndent),
                try formatProps(b, activity.properties, activityPropIndent),
                (indent ** activityPropIndent), ">\n",
                metaDataString,
                \\      <intent-filter>
                \\          <action android:name="android.intent.action.MAIN" />
                \\          <category android:name="android.intent.category.LAUNCHER" />
                \\      </intent-filter>
                \\  </activity>
                , if(i != conf.activities.len) "\n" else ""
            });
        }

        const renderedManifest = try std.mem.concat(b.allocator, u8, &.{
            renderedHeader, 
            renderedFeatures, 
            indent, "<application\n",
            propertiesString,
            activitiesString, "\n",
            indent, "</application>\n",
            "</manifest>"
        });

        std.log.debug("{s}\n", .{renderedManifest});

        const wf = b.addWriteFiles();
        const printed = wf.add("AndroidManifest.xml", renderedManifest);
        apk.setAndroidManifest(printed);
    }
};
