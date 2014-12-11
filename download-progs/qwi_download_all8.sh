#!/bin/bash
if [[ -z $1 ]]
then
cat << EOF
  $0 release type (override dir)

will use the specified release and type (sa,se,rh,opm)
 
type = all will cycle through sa se rh

EOF
exit 2
fi
release=$1
[[ -z $2 ]] && type=sa || type=$2
[[ -z $3 ]] && localrelease=incoming || localrelease=$3

states="al ak ar az ca co ct dc de fl ga hi id il in ia ks ky la ma me md mi mn ms mo mt ne nv nj nm ny nc nd oh ok or pa ri sc sd tn tx ut vt va wa wv wi wy"
#states=$(cd ../qwi.$localrelease; ls -1d ??)
[[ "$localrelease"  = "incoming" ]] || extraarg=$localrelease
# call back to ourselves
if [[ "$type" = "all" ]]
then
   for subtype in sa rh se
   do
           $0 $release $subtype $extraarg
   done
   exit 0
fi

# actual state-by-state call
for state in $states
do
 echo "Downloading state $state release $release type $type"
 for subtype in f fa fs
  do
 ./qwi_download_state9.sh $state $release $type $subtype
  done
done

