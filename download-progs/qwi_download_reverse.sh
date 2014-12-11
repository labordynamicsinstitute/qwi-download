#!/bin/bash
states="wi wv wa va vt ut tx tn sc pa or ok nc nm nj nv mo ms mn me ky ks ia in il id hi ga fl"
for arg in $states
do
echo "Downloading state $arg"
./qwi_download_state2.sh $arg
done

