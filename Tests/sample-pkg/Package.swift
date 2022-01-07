// swift-tools-version:5.5.0

import PackageDescription

let package = Package(
   name: "HelloJNI",
   platforms: [.iOS(.v13), .macOS(.v12)],
   products: [
      // See: https://theswiftdev.com/2019/01/14/all-about-the-swift-package-manager-and-the-swift-toolchain/
      .library(name: "Lib", type: .dynamic, targets: ["Lib"]),
      .library(name: "CLib", targets: ["CLib"]),
      .library(name: "CppLib", targets: ["CppLib"]),
   ],
   targets: [
      .target(name: "Lib", dependencies: ["CLib", "CppLib", "CStdLib", "StdLib"]),
      .executableTarget(name: "Exe", dependencies: ["Lib"]),
      .target(name: "CLib"),
      .target(name: "CppLib"),
      .target(name: "CStdLib"),
      .target(name: "StdLib")
   ]
)
package.platforms = [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)]
