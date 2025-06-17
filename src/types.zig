/// https://developer.android.com/guide/topics/manifest/manifest-intro
pub const ManifestConfig = struct {
    // androidPermNames: []const u8,
    // androidFeatures: []const u8,
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
    /// first digit is major version, second is minor
    glEsVersion: [2]u16 = .{2, 0}
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
