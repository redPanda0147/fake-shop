#!/bin/bash

# Backup the project file
cp ./Fake-Store.xcodeproj/project.pbxproj ./Fake-Store.xcodeproj/project.pbxproj.bak

# Replace INFOPLIST_FILE with INFOPLIST_KEY_UIApplicationSceneManifest_Generation
sed -i '' 's/INFOPLIST_FILE = "Fake-Store\/Info.plist";//g' ./Fake-Store.xcodeproj/project.pbxproj

echo "Project file updated. Original backed up to project.pbxproj.bak"
