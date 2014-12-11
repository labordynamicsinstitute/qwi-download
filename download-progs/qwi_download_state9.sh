#!/bin/bash
# $Id$
if [[ -z $3 ]]
then
cat <<EOF

    $0 <state> <release> <type> <subtype> (x)

    Will download all QWI files for a particular state.

    See code for download locations.

    Type is sa, se, rh. 

    Subtype is f, fa, fs
EOF
exit 2
else
    state=$1
    release=$2
    type=$3
    [[ -z $4 ]] && subtype=f || subtype=$4
    [[ -z $5 ]] && localrelease=incoming || localrelease=$release
fi

#-------------------- definitions --------------------
SCRATCH=/data/archive/raw/qwipu/qwi.$localrelease
case $type in
    *)
	#http://lehd.ces.census.gov/php/inc_download.php?s=al&f=/R2013Q3/DVD-sa_fa/version_sa_fa.txt
     remote_root=/php/inc_download.php?s=${state}\&f=/$release/DVD-${type}_${subtype}
     local_root=$SCRATCH/$state/$type/$subtype
;;
esac
remote_url=http://lehd.ces.census.gov
perms=555
wget_opts="-N -nv --no-check-certificate"
tmpdir=$(mktemp -d)
manifest=qwipu_${state}_manifest_${type}_${subtype}.txt
version_txt=version_${type}_${subtype}.txt

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

my_wget ${version_txt} $tmpdir

# compare the version file to the old one

if [[ -f $local_root/${version_txt} && -f $tmpdir/${version_txt} ]]
then
    diff -q $local_root/${version_txt} \
    $tmpdir/${version_txt} \
    1>/dev/null 2>/dev/null
    versions_differ=$?
else
    versions_differ=1
fi

if [[ "$versions_differ" = "1" ]]
then
  # maybe the previous download did not complete
  if [[ -f $(basename $manifest .txt).md5 ]]
  then
     # move old dir out of the way
     [[ -d ${local_root}.prev && -d ${local_root} ]] && \rm -rf ${local_root}.prev
     [[ -d $local_root ]] && mv $local_root ${local_root}.prev
  fi
  # set up download locations
  [[ -d $local_root ]] || mkdir -p $local_root

  # copy the ${version_txt} file
  cp $tmpdir/${version_txt} $local_root/
  # start off by getting the manifest
  
  my_wget $manifest

  # copy manifest to tmpdir, adding the URL
#  cat $local_root/$manifest | \
#      awk -v url="${remote_url}${remote_root}/" \
#          ' { print url $1 } ' > $tmpdir/$manifest

  # download all files on the manifest
  cd $local_root  
  echo "$(pwd)" 
  printf "============= %10s" "starting"
  date
  time (
	for file in $(cat $manifest | grep -vE "version|manifest" | awk ' { print $1 } ')
        do 
	   wget $wget_opts -O $file ${remote_url}${remote_root}/$file 
         done
	)
  printf "============= %10s" "finished"
  date
  # create md5sums of all files
  md5sum * > $(basename $manifest .txt).md5

  # adjust permissions
  #chmod 555 * .
else
  echo "No download necessary - same version."
fi

#\rm -rf $tmpdir
