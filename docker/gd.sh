#!/bin/bash

# Setup variables
ggID=$1
ggURL='https://drive.google.com/uc?export=download'
cookiejar="/tmp/gcookie-${1}"
# Download metadata. Extract filename and cookiejar.
filename="$(curl -sc "${cookiejar}" "${ggURL}&id=${ggID}" | grep -o '="uc-name.*</span>' | sed 's/.*">//;s/<.a> .*//')"


outfile="${2:-${filename}}"

getcode="$(awk '/_warning_/ {print $NF}' "${cookiejar}")"

# Download file
curl -Lb "${cookiejar}" "${ggURL}&confirm=${getcode}&id=${ggID}" -o "${outfile}"

