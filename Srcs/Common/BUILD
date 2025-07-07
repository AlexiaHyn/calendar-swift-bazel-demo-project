load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "CoreDataModel",
    srcs = glob(["Database/*.xcdatamodeld/**"]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "common_tools",
    module_name = "CommonTools",
    srcs = glob(["**/*.swift"]),
    data = [":CoreDataModel"],
    visibility = ["//visibility:public"],
)
