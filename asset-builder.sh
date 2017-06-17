#!/bin/bash
##
# This script installs npm and builds webpack in all directories given as argument
##

# Installs stuff from package.json and bower.json 
# $1 - build directory
function install_all_assets() {
    local build_dir=$1

    cd $build_dir

    if [ -f package.json ]; then
        if [[ "$PACKAGE_INSTALLER" == "yarn" ]]; then
            if ! is_cmd_installed yarn; then
                npm install -g yarn
            fi
            yarn install
        else
            npm install
        fi
    fi

    if [ -f bower.json ]; then

        if ! is_cmd_installed bower; then
            npm install -g bower
        fi

        bower install --allow-root
    fi
}

# Builds assets defined in Gruntfile.js, Gulpfile.js or webpack.js
# $1 - build directory
function build_all_assets() {
    local build_dir=$1

    cd $build_dir

    # Match any file case insensitively
    shopt -s nocasematch
    for file in * ; do
        case "$file" in
            "gruntfile.js" )
                run_local_module grunt
            ;;
            "webpack.js" )
                run_local_module webpack
            ;;
            "gulpfile.js" )
                run_local_module gulp
            ;;
        esac
    done
}

# Uses local node binary from node_modules if it's available
# Fallbacks to global bin
function run_local_module() {
    local bin=$1

    if [ -f ./node_modules/$bin/bin/$bin.js ]; then
        ./node_modules/$bin/bin/$bin.js
    else
        $bin
    fi
}

# Finds and returns paths with package.json or bower.json
function collect_asset_directories() {
    local find_from_path=$1
    local find_max_depth=$2

    declare -a build_locations

    # Find all paths with package.json/bower.json and append their relative path to absolute path
    for package in $(find $find_from_path  -maxdepth $find_max_depth \( -name "package.json" -o -name "bower.json" \) ); do
        build_locations+=($(realpath $(dirname $package)))
    done

    # This a bit hacky way to only echo unique elements
    # This is useful so that we don't do double amount of work if both package.json and bower.json are present
    echo "${build_locations[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Use the node version user provided as $NODE_VERSION env
function prepare_node_version() {
    local version=$1

    source $NVM_DIR/nvm.sh
    nvm install $version
    nvm alias default $version
    nvm use $version
}

# Checks if command is installed and is in $PATH
function is_cmd_installed() {
    local cmd=$1

    command -v $cmd >/dev/null 2>&1

    return $?
}

# Installs and activates the wanted node version
prepare_node_version $NODE_VERSION


# Set default variables for asset builder
MAX_DEPTH=${MAX_DEPTH-1}
BUILD_DIR=${1-/build}

# Loop only unique items from build locations
for build_dir in $(collect_asset_directories $BUILD_DIR $MAX_DEPTH); do

    # Installs all stuff from package.json/bower.json
    install_all_assets $build_dir

    # Builds Gruntfile.js, gulpfile.js and webpack.js
    build_all_assets $build_dir
done