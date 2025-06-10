#!/bin/bash                                                                                                                                                                                    
while getopts i:o:dhs: flag                                                                                                                                                                    
do                                                                                                                                                                                             
    case "${flag}" in                                                                                                                                                                          
        i) inputdisk=${OPTARG};;                                                                                                                                                               
        o) outputdisk=${OPTARG};;                                                                                                                                                              
        d) dryrun=true;;                                                                                                                                                                       
        s) startskip=${OPTARG};;                                                                                                                                                               
        h) helpoption=true;;                                                                                                                                                                   
    esac                                                                                                                                                                                       
done                                                                                                                                                                                           
if [ -n "$helpoption" ]; then                                                                                                                                                                  
        echo 'Use: dd-chunk -i /dev/sda/ -o /dev/sdb -s 100'
        echo ''
        echo 'Options:'
        echo '-i inputdisk eg. /dev/sda (mandatory)'
        echo '-o outputdisk eg. /dev/sdb (mandatory)'
        echo '-d dryrun'
        echo '-s skip value (when not start from the beginning)'
        echo '-h help' 
        exit 1
fi

if [ -z "$inputdisk" ] || [ -z "$outputdisk" ]; then
        echo 'Missing -i (inputdisk) or -o (outputdisk)' >&2
        exit 1
fi

startskip="${startskip:-0}"
starttimestamp=`date +%s`
disksize=`blockdev --getsize64 $inputdisk`
#blocksize=$((1024*4096))
blocksize=$((1024*1024*256))
chunks=$(($disksize/$blocksize))
#inputdisk=/dev/sdf
#outputdisk=/dev/sdd
echo "disksize $disksize"
echo "chunks:  $chunks of $blocksize bytes"
echo "command: dd if=$inputdisk of=$outputdisk bs=$blocksize skip=$startskip seek=$startskip count=1"
for((i=$startskip;i<=$chunks;i++))
do
    if ! [[ $dryrun == true ]]; then
        ddcommand=`dd if=$inputdisk of=$outputdisk bs=$blocksize skip=$i seek=$i count=1 2> >( grep /s )`
        sizedone=$(($i*$blocksize))
        echo "chunk $i/$chunks = $sizedone/$disksize done -> $ddcommand" >> /root/dd-chunk-$starttimestamp
    else
        sizedone=$(($i*$blocksize))
        echo "chunk $i/$chunks = $sizedone/$disksize SKIPPED -> dryrun" >> /root/dd-chunk-$starttimestamp
    fi
done
