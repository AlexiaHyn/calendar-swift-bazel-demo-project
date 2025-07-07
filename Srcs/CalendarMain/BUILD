load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "calendar_main_view",
    module_name = "CalendarMainView",
    srcs = glob(["**/*.swift"]),
    visibility = ["//visibility:public"],
    private_deps = [
        "//Srcs/Weather:calendar_weather",
        "//Srcs/Events:calendar_events",
        "//Srcs/Common:common_tools",
        "//Srcs/Agenda:calendar_agenda",
        "//Srcs/Calendar:calendar_calendar"
    ]
)
