load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "calendar_weather",
    module_name = "CalendarWeather",
    srcs = glob(["**/*.swift"]),
    visibility = ["//visibility:public"],
    private_deps = [
        "//Srcs/Common:common_tools",
    ]
)
