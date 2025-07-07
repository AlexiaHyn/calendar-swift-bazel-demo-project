# This file marks the root of the Bazel workspace.
# See MODULE.bazel for external dependencies setup.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_xcodeproj",
    integrity = "sha256-b+AKGo9kJFkcN52bTraVuIu6hKlTEe/Y+LAHkhXs29o=",
    url = "https://github.com/MobileNativeFoundation/rules_xcodeproj/releases/download/2.7.0/release.tar.gz",
)

load(
    "@rules_xcodeproj//xcodeproj:repositories.bzl",
    "xcodeproj_rules_dependencies",
)

xcodeproj_rules_dependencies()

load("@bazel_features//:deps.bzl", "bazel_features_deps")

bazel_features_deps()