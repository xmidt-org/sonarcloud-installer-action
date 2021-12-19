#!/bin/bash
# SPDX-FileCopyrightText: 2021 Comcast Cable Communications Management, LLC
# SPDX-License-Identifier: Apache-2.0

# Sadly sonarcloud doesn't provide any way to validate the integrity of this zip
# file: https://community.sonarsource.com/t/sha256-checksum-for-build-wrapper-linux-x86-zip/43357/10
curl -s -L -O https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip
unzip -q -o build-wrapper-linux-x86.zip

# Get the latest version of the scanning tool
SONAR_VERSION=`curl -s https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/ |grep -o "sonar-scanner-cli-[0-9.]*-linux.zip"|sort -r|uniq|head -n 1`
curl -s -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/$SONAR_VERSION

# Get the sha256sum and validate the download
curl -s -L -O https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/$SONAR_VERSION.sha256
echo "  $SONAR_VERSION" >> $SONAR_VERSION.sha256
sha256sum -c $SONAR_VERSION.sha256
if [[ $? -ne 0 ]]
then
    exit 1
fi
unzip -q $SONAR_VERSION

# Rename the resulting file to a common file name 'sonar-scanner' for simplicty.
output=`ls | grep -o "sonar-scanner-[0-9.]*-linux"`
echo "Using $output"
mv $output sonar-scanner
