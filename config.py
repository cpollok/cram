#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import yaml
import xml.etree.ElementTree as et


FORMAT_1_DEPEND_TAGS = set([
    # "buildtool_depend",
    "build_depend",
    "run_depend",
    "test_depend"
])

FORMAT_2_DEPEND_TAGS = set([
    "depend",
    # "buildtool_depend",
    "build_depend",
    "exec_depend",
    "test_depend",
    "doc_depend"
])

# Packages in the source directory being configured, mapped to their path (relative from the cwd when executing)
pkg_paths = {}

# Obsolete
wl_stacks = []

# Packages to be whitelisted by config()
wl_packages = []




# def get_profiles():
#     """Open the profiles.yaml to read the profiles."""
#     with open('profiles.yaml', 'r') as stream:
#         try:
#             return yaml.load(stream)
#         except yaml.YAMLError as e:
#             print(e)

# def load_profile(profile_name):
#     """Fill wl_stacks and wl_packages with the whitelisted stacks/packages of the profile with the given name."""
#     profiles = get_profiles()
#     try:
#         global wl_stacks
#         global wl_packages
#         profile = profiles[profile_name]
#     except KeyError as e:
#         print(e)
#     if 'stacks' in profile.keys():
#         wl_stacks = profile['stacks']
#     if 'packages' in profile.keys():
#         wl_packages = profile['packages']


##################
# Help functions #
##################

def blacklist(dirpath):
    dir_content = os.listdir(dirpath)
    if 'CATKIN_IGNORE' not in dir_content:
        # open(os.path.join(dirpath, 'CATKIN_IGNORE'), 'w')
        pass
    print "Blacklisted: " + dirpath

def whitelist(dirpath):
    dir_content = os.listdir(dirpath)
    if 'CATKIN_IGNORE' in dir_content:
        # os.remove(os.path.join(dirpath, 'CATKIN_IGNORE'))
        pass
    print "Whitelisted: " + dirpath


def get_package_name(path):
    xml_path = os.path.join(path, 'package.xml')
    e = et.parse(xml_path).getroot()
    return e.find('name').text

def get_dependencies(xml):
    # Choose the right set of dependency tags
    depend_tags = set()
    if "format" in xml.attrib and xml.attrib["format"] == "2":
        depend_tags.update(FORMAT_2_DEPEND_TAGS)
    else:
        depend_tags.update(FORMAT_1_DEPEND_TAGS)

    # Find all elements containing dependencies
    dependency_elements = reduce(lambda x, y: x + xml.findall(y), depend_tags, [])

    # Map the elements to their content text, which is the name of the dependency
    dependencies = map(lambda x: x.text, dependency_elements)
    return dependencies


##################
# Main functions #
##################

def check_cwd():
    """Check if the script is run in the cram repository."""
    return True

def crawl():
    # walk over repo to collect all packages
    # parse package.xml of wanted packages
    # blacklist everything else :D
    global pkg_paths
    for dirpath, dirnames, filenames in os.walk('.'):
        if '.git' in dirnames:
            # don't look into .git directories
            del dirnames[dirnames.index('.git')]

        if 'CMakeLists.txt' in filenames and 'package.xml' in filenames:
            # found a package
            pkg_paths[get_package_name(dirpath)] = dirpath
            dirnames[:] = []

def check_package_names():
    """Check if any package name is different from name of the directory containing it."""
    for pkg_name, dirpath in pkg_paths.items():
        dirname = os.path.basename(dirpath)
        if pkg_name != dirname:
            print "WARNING: Package name and name of containing directory differ: Package '{}' in directory '{}'!".format(pkg_name, dirname)

def build_profile(*pkgs):
    global wl_packages
    wl_packages = set()
    wl_packages.update(pkgs)
    while len(pkgs) != 0:
        for pkg in pkgs:
            xml_path = os.path.join(pkg_paths[pkg], 'package.xml')
            pkg_xml = et.parse(xml_path).getroot()
            deps = get_dependencies(pkg_xml)
            wl_packages.update(deps)
        pkgs = set(deps).intersection(pkg_paths.keys())


def config():
    """Traverse the CRAM repository and whitelist all packages in the wl_packages and blacklist the rest."""
    for dirpath, dirnames, filenames in os.walk('.'):

        if dirpath == '.':
            whitelist(dirpath)
        elif any(map(lambda x: dirpath.endswith(x), wl_stacks)) or any([x in wl_packages for x in dirnames]):
            # found a whitelisted stack
            whitelist(dirpath)

        elif 'CMakeLists.txt' in filenames and 'package.xml' in filenames:
            # found a package, don't recurse deeper
            dirnames[:] = []
            basepath, dirname = os.path.split(dirpath)
            if any(map(lambda x: x == dirname, wl_packages)) or any(map(lambda x: basepath.endswith(x), wl_stacks)) :
                # found a whitelisted package
                whitelist(dirpath)
            else:
                blacklist(dirpath)
        else:
            blacklist(dirpath)

        if '.git' in dirnames:
            # don't look into .git directories
            del dirnames[dirnames.index('.git')]

def config_new():
    """Only on package level."""
    for dirpath, dirnames, filenames in os.walk('.'):


def usage():
    return """Usage:
    python config.py <profile>

    Profiles:
    minimal
    projection
    all
    """


if __name__ == '__main__':
    # if len(sys.argv) != 2:
    #     print(usage())
    #     sys.exit(0)
    # load_profile(sys.argv[1])
    if not check_cwd():
        print usage()
    crawl()
    check_package_names()

    # TODO: Add check whether the given packages are in the repo.

    # print pkg_paths
    build_profile(*sys.argv[1:])
    config()
