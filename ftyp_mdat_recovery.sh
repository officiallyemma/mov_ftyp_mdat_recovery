#!/bin/bash
set -e # exit on non-zero exit codes

DEBUG=false
DO_CLEANUP=true # do delete files after screenshot creation failure?

# create outfile
do_create() {
    outfile=$1
    ftyp=$2
    mdat=$3
    
    printf "Testing $i/$total_combinations from ${ftyp}_ftyp.mov ${mdat}_mdat.mov\n"
    dest="output/$outfile"
    mkdir -p output
    cat $ftyp"_ftyp.mov" $mdat"_mdat.mov" > $dest
    
    # print "Trying to create screenshot to test video\n"
    jpeg="output/${outfile}.jpg"
    set +e
    ffmpeg -i $dest -vframes 1 -f image2 $jpeg -nostats -loglevel 0
    
    if [ "$?" == "0" ]; then
        printf "Screenshot creation successful. $? Check $dest\n" >> output/successes
        
    else
        print "Failed to create screenshot, Exit Code: $?. cleaning up.\n"
        safe_rm $dest
        echo "${ftyp}_${mdat}.mov" >> output/failures 2>/dev/null
    fi
    set -e
}

# check if recovery file already exists, if not, attempt to create it
create () {
    ((i=i+1))
    ftyp=${1%_*.*}
    mdat=${2%_*.*}
    # printf "$ftyp $mdat \n"
    outfile=$ftyp"_"$mdat".mov"
    if exists output/*${ftyp}_*.mov.jpg; then
        print "Skipping $outfile because result already found for ftyp: $ftyp\n"
        return
    fi
    if exists output/*_${mdat}*.mov.jpg; then
        print "Skipping $outfile because result already found for mdat: $mdat\n"
        return
    fi
    
    if grep -Fxq "$outfile" "output/failures"; then
        print "Already tried ${outfile} combination, skipping.\n"
        
        if exists output/$outfile; then
            # clean up
            safe_rm output/$outfile
        fi
        return
    else
        do_create $outfile $ftyp $mdat
    fi
}

# removes a file, preventing wildcard issues so I don't lose any more files
safe_rm(){
    if $DO_CLEANUP; then
        outfile_abs=$(realpath "$1") # for my sanity
        current=$(pwd)
        if [[ $outfile_abs = $current/* ]]
        then 
            rm "$outfile_abs"
        fi         
    fi
}

print (){
    if $DEBUG; then
        printf "$1"
    fi
}

# check if a file exists
exists () {
    # printf "Checking if result already exists for $1\n"
    for f in $1; do
        if [ -e "$f" ]; then
            #    printf "Found: $f\n"
            return 0
        fi
        # printf "Didn't find: $f\n"
    done
    return 1
}


# for each combination of ftyp and mdat files, attempt to recover
i=0
total_file_count=0
for file_ftyp in *"_ftyp.mov"; do
    for file_mdat in *"_mdat.mov"; do
        ((total_combinations = total_combinations + 1))
    done
done

printf "There are $total_combinations total possible combinations. Work to be done: 1) concatenate files 2) attempt to create screenshot 3) repeat for all combinations, in order\n"

for file_ftyp in *"_ftyp.mov"; do
    for file_mdat in *"_mdat.mov"; do
        create $file_ftyp $file_mdat
    done
done
