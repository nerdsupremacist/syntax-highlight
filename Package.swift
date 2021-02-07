// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "syntax-highlight",
    products: [
        .library(name: "SyntaxHighlight",
                 targets: ["SyntaxHighlight"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/SyntaxTree.git", .branch("main")),
    ],
    targets: [
        .target(name: "SyntaxHighlight",
                dependencies: ["SyntaxTree"]),
    ]
)
