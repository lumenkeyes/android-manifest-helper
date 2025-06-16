A small project to automatically generate android manifest and resource files. This is a work in progress, I make no guarantees about its usability. Meant to be used with https://github.com/silbinarywolf/zig-android-sdk

Install with `zig fetch --save git+https://github.com/lumenkeyes/android-manifest-helper`

Example usage in `build.zig`:
```zig
const manifestHelper = @import("android_manifest_helper")

// ...
// set up apk, etc.
// ...

// ...
// add artifacts to apk
// ...

const manifest = try manifestHelper.createManifest(.{
    .b = b,
    .sdkPath = "<path_to_sdk>"
    .manifest_conf = .{
        .apiLevel = <APPROPRIATE_API_LEVEL>,
        .packageName = "com.zig.<EXE_NAME>",
        .permissions = &.{
            .{.name = "ACCESS_NETWORK_STATE"}, 
            .{.name = "INTERNET"},
        },
        .appProperties = .{ .hasCode = false },
        .activities =  &.{
            .{
                .properties = .{
                    .launchMode = .singleInstance,
                    .name = "android.app.NativeActivity",
                    .configChanges = &.{.layoutDirection, .locale, .orientation, .uiMode, .screenLayout, .screenSize, .smallestScreenSize, .keyboard, .keyboardHidden, .navigation}
                },
            }
        },
        .customAppProperties = &.{
            .{
                .name = "tools:targetApi",
                .value = b.fmt("{d}", .{<APPROPRIATE_API_LEVEL>})
            }
        },
        .glEsVersion = "0x00020000"
    }
});
try apk.setAndroidManifest(manifest);

// ...
// install apk, etc..
// ...
