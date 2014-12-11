#!/bin/bash
# $Id$
test=no
if [[ -z $3 ]]
then
cat <<EOF

    $0 <state> <release> <type> (x)

    Will download all QWI files for a particular state.

    See code for download locations.

    Type is wia, se, rh. Defaults to wia

EOF
exit 2
else
    state=$1
    release=$2
    type=$3
    [[ -z $4 ]] && localrelease=incoming || localrelease=$release
    if [[ "$localrelease" = "test" ]] 
	then
		localrelease=incoming
		test=yes
    fi
fi

#-------------------- definitions --------------------
SCRATCH=/ssgprojects/qwipu/csv/qwi.$localrelease
case $type in
    *fa|*fs|opm)
     remote_root=/pub/$state/$release/beta/DVD-$type
     local_root=$SCRATCH/$state/beta/$type
    ;;
    *)
     remote_root=/pub/$state/$release/DVD-$type
     local_root=$SCRATCH/$state/$type
;;
esac
remote_url=http://lehd.ces.census.gov
perms=555
wget_opts="-N -nv --no-check-certificate"
tmpdir=$(mktemp -d)
manifest=qwipu_${state}_manifest_$type.txt

function my_wget
{
if [[ ! -z $1 ]]
then
 [[ -z $2 ]] && dest=$local_root || dest=$2

 [[ -d $dest ]] || mkdir -p $dest
 wget $wget_opts \
      -O $dest/$1 \
      ${remote_url}$remote_root/$1
fi
}


# get the version file, if it is there

my_wget version.txt $tmpdir

# compare the version file to the old one

if [[ -f $local_root/version.txt && -f $tmpdir/version.txt ]]
then
    diff -q $local_root/version.txt \
    $tmpdir/version.txt \
    1>/dev/null 2>/dev/null
    versions_differ=$?
else
    versions_differ=1
fi

if [[ "$versions_differ" = "1" ]]
then
  echo "  $state $release differs" 
  echo "  Version on server is:"
  cat $tmpdir/version.txt
else
  echo "  $state $release is already downloaded" 
fi
