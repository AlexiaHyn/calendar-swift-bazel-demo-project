load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "calendar_agenda",
    module_name = "CalendarAgenda",
    srcs = glob(["**/*.swift"]),
    visibility = ["//visibility:public"],
    private_deps = [
        "//Srcs/Calendar:calendar_calendar",
        "//Srcs/Common:common_tools",
        "//Srcs/Events:calendar_events",
        "//Srcs/Weather:calendar_weather"
    ]
)
