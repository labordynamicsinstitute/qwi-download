#!/bin/bash
# $Id: check_status.sh 476 2013-04-19 13:15:39Z vilhu001 $
if [[ -z $1 ]]
then
cat << eof
 $0 (RyyyyQz| incoming RyyyyQz)

will check for all version files, identify the revision.

eof
exit 0
fi
#releasedir=../qwi.$1
releasedir=../../../raw/qwipu/qwi.$1
[[ "$1" = "incoming" ]] && release=$2 || release=$1
_tmp=$(mktemp)


function check_version {
	if [[ -f $1 ]] 
	then
		cat $1 > $_tmp
		dos2unix $_tmp 2>/dev/null
		_version=$(head -1 $_tmp |  grep V4.0  | awk  ' { print $6 } ' )
		_version=$(echo $_version)
		#echo "x${_version}x y${release}y"
		[[ "$_version" == "$release" ]] && echo "OK" || echo "Old"
	else
		echo " Missing" 
	fi

}

echo " ======== checking release $release =======" 
for state in $(cd $releasedir ; ls -1d ??)
do
  echo " ------- State $state, release $release ----------"
  for type in sa rh se
  do
       for subtype in f fa fs
       do 
	printf "%20s :" "$type/$subtype" 
	check_version $releasedir/$state/$type/${subtype}/version_${type}_${subtype}.txt
       done
  done
done
echo $_tmp
rm -f $_tmp
