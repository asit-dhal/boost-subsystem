#!/bin/bash

if [ $# -lt 2 ]; then 
	echo "Usages: bcp_gen ouput_path module_list"
	echo "  e.g.: gen /some/path scoped_ptr"
	exit 1
fi

output_path=$1
  
if [ -f $output_path ]; then
	echo "$output_path is not a directory. Please provide a path."
	exit 1
fi

mkdir -p $output_path

bcp --boost=/work/boost_src/boost_1_75_0 build bootstrap.bat bootstrap.sh b2 boostcpp.jam boost-build.jam ${@:2} $output_path
