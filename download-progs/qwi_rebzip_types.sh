#!/bin/bash
# number of threads for pbzip2
threads=4
if [[ -z $1 ]]
then
cat << EOF
 
  $0 (release) (type) [(state)]

  will rezip (non-parallel bzip2) all .bz2 files under qwi.(release)/[(state)/](type)
 
  type defaults to wia. State is optional
EOF
exit 2
fi

BASE=/ssgprojects/qwipu/csv
release=$1
[[ -z $2 ]] && type=wia || type=$2
[[ -z $3 ]] || state=$3

cd $BASE/qwi.$release/
cd1=$?
pwd
case $cd1 in
  0) 
  [[ -z $state ]] && states=$(ls -1d ??) || states=$state
  for dir in $states
  do
    chmod u+rw $dir
    cd $dir/$type
    cd2=$?
    pwd
    case $cd2 in
    0) 
    echo "Processing $dir/$type"
    chmod u+rw *bz2
    for file in $(ls -1 *bz2)
    do
       bunzip2 $file
       bzip2 -9 $(basename $file .bz2)
    done
    chmod a-w *bz2
    echo "Recreating MD5 and manifest"
    ls -1 * > qwipu_${dir}_manifest_${type}.txt
    md5sum *bz2 > qwipu_${dir}_manifest_${type}_bz2.md5
    cd ../..
    ;;
    *)
	echo "problem with $dir/$type"
	;;
    esac
  done
  ;;
 *)
  echo "Problem with $BASE/qwi.$release"
  exit 2
  ;;
esac

