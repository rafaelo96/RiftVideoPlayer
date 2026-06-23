#!/bin/bash
# Sentry Crash Reporting Setup
# 
# This script adds Sentry SDK to the project.
# Prerequisites:
#   1. Create a Sentry account at https://sentry.io
#   2. Create a macOS project and get your DSN
#   3. Set SENTRY_DSN environment variable
#
# After running this, add the DSN at app launch:
#
#   import Sentry
#   
#   // In AppDelegate.applicationDidFinishLaunching:
#   SentrySDK.start { options in
#       options.dsn = ProcessInfo.processInfo.environment["SENTRY_DSN"]
#           ?? "https://your-dsn@sentry.io/project-id"
#       options.environment = "production"
#   }

echo "Sentry integration requires manual steps:"
echo "1. Add to Package.swift:"
echo '   .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.0.0")'
echo "2. Add to target dependencies:"
echo '   .product(name: "Sentry", package: "sentry-cocoa")'
echo "3. Initialize SentrySDK in AppDelegate"
echo "4. Set SENTRY_DSN in your CI/CD environment"
