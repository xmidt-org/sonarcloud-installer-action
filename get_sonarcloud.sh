#!/bin/bash
# SPDX-FileCopyrightText: 2021 Comcast Cable Communications Management, LLC
# SPDX-License-Identifier: Apache-2.0

getwrapper() {
    # Sadly sonarcloud doesn't provide any way to validate the integrity of this zip
    # file: https://community.sonarsource.com/t/sha256-checksum-for-build-wrapper-linux-x86-zip/43357/10
    curl -s -L -O https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip
    if [[ $? -ne 0 ]]; then
        echo "Unable to download the build-wrapper-linux-x86.zip file."
        exit 1
    fi
    unzip -q -o build-wrapper-linux-x86.zip
    if [[ $? -ne 0 ]]; then
        echo "Unable to unzip the build-wrapper-linux-x86.zip file."
        exit 1
    fi
}

getcli() {
    # Since sonar doesn't provide a formal way of getting all the versions, this
    # appears to be the best way foward.
    # https://community.sonarsource.com/t/downloading-latest-version-of-tools/58956

    # Determine the bucket we can examine for file versions
    sonarBucket=$(curl -sSL https://binaries.sonarsource.com | awk -F\' '/BUCKET_URL/{print $2}')

    # Get the latest cli_version of the scanning tool
    SONAR_VERSION=`curl -sSL ${sonarBucket}\?prefix=Distribution/sonar-scanner-cli/ |grep -o "sonar-scanner-cli-[0-9.]*-linux.zip"|grep ".*-cli-$cli_version.*-linux.zip"|sort -r|uniq|head -n 1`
    echo "Sonar-scanner-cli cli_version: ${SONAR_VERSION}"
    if [[ -z $SONAR_VERSION ]]; then
        echo "Unable to find any versions that match the specified version '${cli_version}'"
        exit 1
    fi

    curl -s -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/$SONAR_VERSION
    if [[ $? -ne 0 ]]; then
        echo "Unable to download the sonar-scanner-cli."
        exit 1
    fi

    # Get the sha256sum and validate the download
    curl -s -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/$SONAR_VERSION.sha256
    if [[ $? -ne 0 ]]; then
        echo "Unable to download the sonar-scanner-cli sha256 file."
        exit 1
    fi

    echo "  $SONAR_VERSION" >> $SONAR_VERSION.sha256
    sha256sum -c $SONAR_VERSION.sha256
    if [[ $? -ne 0 ]]
    then
        exit 1
    fi
    unzip -q $SONAR_VERSION
    if [[ $? -ne 0 ]]; then
        echo "Unable to unzip the sonar-scanner-cli file."
        exit 1
    fi

    # Rename the resulting file to a common file name 'sonar-scanner' for simplicty.
    output=`ls | grep -o "sonar-scanner-[0-9.]*-linux"`
    echo "Using $output"
    mv $output sonar-scanner
}

# main() starts here

#-------------------------------------------------------------------------------

# Exit on any error
set -e

# Change directories into the working directory
pushd $1

# Process the cli version passed in
cli_version=$2
cli_version=${cli_version//\./\\\.}
cli_version=${cli_version//\*/\\\.\*}

# Run the downloads in parallel
( getwrapper ) &
wrap_pid=$!

( getcli ) &
cli_pid=$!

# Wait for both downloads to complete
wait $wrap_pid
wait $cli_pid

# exit out of the working directory
popd
