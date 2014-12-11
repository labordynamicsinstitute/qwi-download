#!/bin/bash
# number of threads for pbzip2
threads=4
if [[ -z $2 ]]
then
cat << EOF
 
  $0 (release) (type) [(state)]

  will rezip (bzip2) all .gz files under qwi.(release)/[(state)/](type)
 
  type defaults to wia. State is optional
EOF
exit 2
fi

BASE=/ssgprojects/qwipu/csv
release=$1
[[ -z $2 ]] && type=wia || type=$2
[[ -z $3 ]] || state=$3
case $type in
	*fa|*fs|opm)
	typedir=beta/$type
	;;
	*)
	typedir=$type
	;;
esac
cd $BASE/qwi.$release/
cd1=$?
pwd
mycwd=$(pwd)
case $cd1 in
  0) 
  [[ -z $state ]] && states=$(ls -1d ??) || states=$state
  for dir in $states
  do
    chmod u+rw $dir
    cd $dir/$typedir
    cd2=$?
    pwd
    case $cd2 in
    0) 
    echo "Processing $dir/$type"
    chmod u+rw *gz
    for file in $(ls -1 *gz)
    do
       gunzip $file
       bzip2 -f $(basename $file .gz)
    done
    chmod a-w *bz2
    echo "Recreating MD5 and manifest"
    ls -1 * > qwipu_${dir}_manifest_${type}.txt
    md5sum *bz2 > qwipu_${dir}_manifest_${type}_bz2.md5
    cd $mycwd
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

