load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load(
    "@rules_xcodeproj//xcodeproj:defs.bzl",
    "top_level_target",
    "xcodeproj",
)

swift_library(
    name = "calendar_lib",
    srcs = glob(["Srcs/*.swift"]),
    private_deps = [
        "//Srcs/CalendarMain:calendar_main_view",
        "//Srcs/Calendar:calendar_calendar",
        "//Srcs/Agenda:calendar_agenda",
        "//Srcs/Weather:calendar_weather",
        "//Srcs/Events:calendar_events",
        "//Srcs/Common:common_tools",
    ],
)


ios_application(
    name = "calendarDemoApp",
    bundle_id = "Alexia.CalendarProject",
    families = [
        "iphone",
        "ipad",
    ],
    provisioning_profile = "//:calendar.mobileprovision",
    infoplists = ["Resources/Info.plist"],
    minimum_os_version = "16.0",
    visibility = ["//visibility:public"],
    deps = [":calendar_lib"],
)

xcodeproj(
    name = "xcodeproj",
    build_mode = "bazel",
    project_name = "CalendarProject",
    top_level_targets = [
        top_level_target(":calendarDemoApp", target_environments = ["device", "simulator"]),
    ],
)
