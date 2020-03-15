// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "HTTP Response Date",
	products: [
		.library(name: "HTTPResponseDate", targets: ["HTTPResponseDate"])
	],
	targets: [
		.target(name: "HTTPResponseDate"),
		.testTarget(name: "HTTPResponseDateTests", dependencies: ["HTTPResponseDate"]),
	]
)
