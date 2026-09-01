#!/usr/bin/env python3
"""Generate Xcode project.pbxproj for AILifeOS."""

import os
import uuid
import hashlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IOS_DIR = os.path.join(ROOT, "ios")
PROJECT_DIR = os.path.join(IOS_DIR, "AILifeOS.xcodeproj")

def gen_id(name: str) -> str:
    h = hashlib.md5(name.encode()).hexdigest()[:24].upper()
    return h

swift_files = []
for dirpath, _, filenames in os.walk(IOS_DIR):
    if "AILifeOS.xcodeproj" in dirpath or "/Tests" in dirpath.replace("\\", "/") or dirpath.endswith("Tests"):
        continue
    for f in filenames:
        if f.endswith(".swift"):
            rel = os.path.relpath(os.path.join(dirpath, f), ROOT).replace("\\", "/")
            swift_files.append(rel)

swift_files.sort()

# Fixed IDs
PROJECT_ID = "A1B2C3D401234567890ABCD"
TARGET_ID = "A1B2C3D402234567890ABCD"
MAIN_GROUP = "A1B2C3D403234567890ABCD"
PRODUCTS_GROUP = "A1B2C3D404234567890ABCD"
SOURCES_PHASE = "A1B2C3D405234567890ABCD"
FRAMEWORKS_PHASE = "A1B2C3D406234567890ABCD"
RESOURCES_PHASE = "A1B2C3D407234567890ABCD"
PRODUCT_REF = "A1B2C3D408234567890ABCD"
PROJECT_CONFIG_LIST = "A1B2C3D409234567890ABCD"
TARGET_CONFIG_LIST = "A1B2C3D40A234567890ABCD"
DEBUG_PROJECT = "A1B2C3D40B234567890ABCD"
RELEASE_PROJECT = "A1B2C3D40C234567890ABCD"
DEBUG_TARGET = "A1B2C3D40D234567890ABCD"
RELEASE_TARGET = "A1B2C3D40E234567890ABCD"

file_refs = {}
build_files = {}
for sf in swift_files:
    fid = gen_id("ref_" + sf)
    bid = gen_id("build_" + sf)
    file_refs[sf] = fid
    build_files[sf] = bid

# Build groups from paths
groups = {"": MAIN_GROUP}
group_children = {MAIN_GROUP: []}

def ensure_group(path_parts):
    current = ""
    parent = MAIN_GROUP
    for part in path_parts:
        key = current + "/" + part if current else part
        if key not in groups:
            gid = gen_id("group_" + key)
            groups[key] = gid
            group_children[gid] = []
            group_children[parent].append(gid)
        parent = groups[key]
        current = key
    return parent

group_children[MAIN_GROUP].append(PRODUCTS_GROUP)

for sf in swift_files:
    parts = sf.split("/")
    parent_gid = ensure_group(parts[:-1])
    fid = file_refs[sf]
    group_children[parent_gid].append(fid)

def group_block(gid, name, children_ids, path=None):
    lines = [f"\t\t{gid} = {{"]
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    for c in children_ids:
        if c in groups.values() or c in file_refs.values() or c == PRODUCT_REF:
            lines.append(f"\t\t\t\t{c} /* ... */,")
    lines.append("\t\t\t);")
    if path:
        lines.append(f'\t\t\tpath = "{path}";')
    lines.append(f'\t\t\tsourceTree = "<group>";')
    lines.append("\t\t};")
    return "\n".join(lines)

# Simpler approach: flat group structure
pbx = f'''// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
'''
for sf, bid in build_files.items():
    fname = os.path.basename(sf)
    pbx += f'\t\t{bid} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[sf]} /* {fname} */; }};\n'

pbx += '''/* End PBXBuildFile section */

/* Begin PBXFileReference section */
'''
pbx += f'\t\t{PRODUCT_REF} /* AILifeOS.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = AILifeOS.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n'

for sf, fid in file_refs.items():
    fname = os.path.basename(sf)
    pbx += f'\t\t{fid} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {fname}; sourceTree = "<group>"; }};\n'

pbx += '''/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
'''
pbx += f'''\t\t{FRAMEWORKS_PHASE} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{PRODUCTS_GROUP} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{PRODUCT_REF} /* AILifeOS.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
'''

# Recursive group builder
def write_groups(dir_rel, parent_list):
    global pbx
    full = os.path.join(ROOT, dir_rel) if dir_rel else ROOT
    gid = gen_id("grp_" + (dir_rel or "root"))
    
    children = []
    if dir_rel == "":
        children = [gen_id("grp_ios"), PRODUCTS_GROUP]
    elif dir_rel == "ios":
        children = []
        for item in sorted(os.listdir(full)):
            p = os.path.join(full, item)
            if os.path.isdir(p) and item != "AILifeOS.xcodeproj":
                children.append(gen_id("grp_ios/" + item))
            elif item.endswith(".swift"):
                rel = "ios/" + item
                if rel in file_refs:
                    children.append(file_refs[rel])
    else:
        for item in sorted(os.listdir(full)):
            p = os.path.join(full, item)
            if os.path.isdir(p):
                children.append(gen_id("grp_" + dir_rel + "/" + item))
            elif item.endswith(".swift"):
                rel = dir_rel + "/" + item
                if rel in file_refs:
                    children.append(file_refs[rel])
    
    return gid, children

# Build all groups
all_groups = {}

def build_group_tree(dir_rel):
    full = os.path.join(ROOT, dir_rel) if dir_rel else None
    gid = gen_id("grp_" + (dir_rel or "root"))
    children = []
    
    if dir_rel is None or dir_rel == "":
        children = [gen_id("grp_ios"), PRODUCTS_GROUP]
    else:
        for item in sorted(os.listdir(full)):
            item_path = os.path.join(full, item)
            rel = f"{dir_rel}/{item}" if dir_rel else item
            if os.path.isdir(item_path):
                if "AILifeOS.xcodeproj" in item_path:
                    continue
                children.append(gen_id("grp_" + rel))
            elif item.endswith(".swift"):
                if rel in file_refs:
                    children.append(file_refs[rel])
    
    all_groups[dir_rel or ""] = (gid, children)
    
    if dir_rel == "":
        build_group_tree("ios")
    elif dir_rel == "ios":
        for item in sorted(os.listdir(full)):
            if os.path.isdir(os.path.join(full, item)) and item != "AILifeOS.xcodeproj":
                build_group_tree(f"ios/{item}")
    else:
        for item in sorted(os.listdir(full)):
            if os.path.isdir(os.path.join(full, item)):
                build_group_tree(f"{dir_rel}/{item}")

build_group_tree("")

for dir_rel, (gid, children) in sorted(all_groups.items(), key=lambda x: x[0]):
    name = os.path.basename(dir_rel) if dir_rel else ""
    path_attr = ""
    if dir_rel == "ios":
        path_attr = '\n\t\t\tpath = ios;'
    elif dir_rel and "/" in dir_rel:
        path_attr = f'\n\t\t\tpath = {os.path.basename(dir_rel)};'
    
    pbx += f'\t\t{gid} = {{\n'
    pbx += '\t\t\tisa = PBXGroup;\n'
    pbx += '\t\t\tchildren = (\n'
    for c in children:
        pbx += f'\t\t\t\t{c},\n'
    pbx += '\t\t\t);\n'
    if dir_rel == "":
        pbx += '\t\t\tsourceTree = "<group>";\n'
    elif dir_rel == "ios":
        pbx += '\t\t\tpath = ios;\n\t\t\tsourceTree = "<group>";\n'
    elif dir_rel.count("/") == 1:
        pbx += f'\t\t\tpath = {os.path.basename(dir_rel)};\n\t\t\tsourceTree = "<group>";\n'
    else:
        pbx += f'\t\t\tpath = {os.path.basename(dir_rel)};\n\t\t\tsourceTree = "<group>";\n'
    pbx += '\t\t};\n'

root_gid = all_groups[""][0]

pbx += f'''/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{TARGET_ID} /* AILifeOS */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {TARGET_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "AILifeOS" */;
\t\t\tbuildPhases = (
\t\t\t\t{SOURCES_PHASE} /* Sources */,
\t\t\t\t{FRAMEWORKS_PHASE} /* Frameworks */,
\t\t\t\t{RESOURCES_PHASE} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = AILifeOS;
\t\t\tproductName = AILifeOS;
\t\t\tproductReference = {PRODUCT_REF} /* AILifeOS.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PROJECT_ID} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{TARGET_ID} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {PROJECT_CONFIG_LIST} /* Build configuration list for PBXProject "AILifeOS" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {root_gid};
\t\t\tproductRefGroup = {PRODUCTS_GROUP} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{TARGET_ID} /* AILifeOS */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{RESOURCES_PHASE} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{SOURCES_PHASE} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
'''
for sf, bid in build_files.items():
    fname = os.path.basename(sf)
    pbx += f'\t\t\t\t{bid} /* {fname} in Sources */,\n'

pbx += f'''\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{DEBUG_PROJECT} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_PROJECT} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{DEBUG_TARGET} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "AI LifeOS";
\t\t\t\tINFOPLIST_KEY_NSUserNotificationsUsageDescription = "Used to remind you about tasks, routines, and your daily briefing.";
\t\t\t\tINFOPLIST_KEY_UIBackgroundModes = audio;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.ailifeos.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_TARGET} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = Info.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "AI LifeOS";
\t\t\t\tINFOPLIST_KEY_NSUserNotificationsUsageDescription = "Used to remind you about tasks, routines, and your daily briefing.";
\t\t\t\tINFOPLIST_KEY_UIBackgroundModes = audio;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.ailifeos.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{PROJECT_CONFIG_LIST} /* Build configuration list for PBXProject "AILifeOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_PROJECT} /* Debug */,
\t\t\t\t{RELEASE_PROJECT} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{TARGET_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "AILifeOS" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_TARGET} /* Debug */,
\t\t\t\t{RELEASE_TARGET} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {PROJECT_ID} /* Project object */;
}}
'''

os.makedirs(PROJECT_DIR, exist_ok=True)
with open(os.path.join(PROJECT_DIR, "project.pbxproj"), "w", newline="\n") as f:
    f.write(pbx)

print(f"Generated project with {len(swift_files)} Swift files at {PROJECT_DIR}")
