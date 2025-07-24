#!/bin/bash

# Backup the project file
cp ./Fake-Store.xcodeproj/project.pbxproj ./Fake-Store.xcodeproj/project.pbxproj.bak2

# Add Info.plist reference to PBXFileReference section
sed -i '' '/End PBXFileReference section/i\
                AA9D79C02E30D39F0006E1E9 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
' ./Fake-Store.xcodeproj/project.pbxproj

# Add INFOPLIST_FILE reference to the build settings
sed -i '' 's/GENERATE_INFOPLIST_FILE = YES;/GENERATE_INFOPLIST_FILE = YES;\
                                INFOPLIST_FILE = "Fake-Store\/Info.plist";/g' ./Fake-Store.xcodeproj/project.pbxproj

echo "Project file updated to reference Info.plist"
