#!/bin/bash

# Copyright 2021 Asit Dhal
#
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)

WORK_DIR=""
VERSION=""
SUB_SYSTEM=""
EXTRACT=""

while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    --help | --help | -h)
      want_help=yes
      shift
      ;;
    --work-dir)
      WORK_DIR="$2"
      shift
      shift
      ;;
    --version)
      VERSION="$2"
      shift
      shift
      ;;
    --sub-system)
      SUB_SYSTEM="$2"
      shift
      shift
      ;;
    --extract)
      EXTRACT="$2"
      shift
      shift
      ;;
    *)
      { echo "error: unrecognized option: $option
Try \`$0 --help' for more information." >&2
      { (exit 1); exit 1; }; }
      ;; 
    esac
done

if test -z $VERSION; then
  VERSION="1.75.0"
fi

if test -z $SUB_SYSTEM; then
  want_help=yes
fi

if test -z $EXTRACT; then
  want_help=yes
fi

if test "x$want_help" = xyes; then
  cat <<EOF
\`./generate.sh' generates subsystem of Boost.
Usage: $0 [OPTION]... 
Defaults for the options are specified in brackets.
Configuration:
  -h, --help                display this help and exit
  --work-dir                working directory. if not specified, platform specific temporary
                            directory will be created.                            
  --version                 use boost version in the format major.minor.patch(e.g. 1.75.0)
  --sub-system              subsystems you want to separate
  --extract                 the directory in which the subsystem should be created
EOF
fi

test -n "$want_help" && exit 0

if test -f $EXTRACT; then
  echo "extract directory $EXTRACT is not empty. Please specify an empty directory"
  exit 1
fi

function download {
  url=$1
  filename=$2

  if [ -x "$(which wget)" ] ; then
    wget $url -P $2
  #elif [ -x "$(which curl)" ]; then
  #  curl -o $2 -sfL $url
  else
    echo "Could not find wget, please install." >&2
  fi
}

file_name_version=${VERSION//\./_}
file_name="boost_${file_name_version}"
download_file_name="${file_name}.tar.gz"
url="https://dl.bintray.com/boostorg/release/${VERSION}/source/${download_file_name}"

tmp_dir=$(mktemp -d -t $file_name-XXXXXXXXXX)

download $url $tmp_dir 
tar -zxvf $tmp_dir/$download_file_name --directory $tmp_dir
cd $tmp_dir/$file_name
./bootstrap.sh
./b2 tools/bcp

./dist/bin/bcp --version 
./dist/bin/bcp build bootstrap.bat bootstrap.sh boostcpp.jam boost-build.jam $SUB_SYSTEM $EXTRACT
echo "Subsystem is extracted at $EXTRACT"