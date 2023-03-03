#! /bin/bash -e

usage() {
    # `cat << EOF` This means that cat should stop reading when EOF is detected
    cat << EOF  
Usage: ./download.sh [--audiotrack=0x103] <mlbplay params>


-h, -help,          --help                  Display help

--audiotrack  - The track id of the audio track to use

-V --verbose - verbose mode

EOF
    # EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}


export audiotrack=0x103
export verbose=0

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
options=$(getopt -l "help,audiotrack:,verbose" -o "hV" -- "$@")

# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters 
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"

while true
do
    case $1 in
	-h|--help) 
	    usage
	    exit 0
	    ;;
	--audiotrack) 
	    shift
	    export audiotrack="$1"
	    ;;
	-V|--verbose)
	    export verbose=1
	    set -xv  # Set xtrace and verbose mode.
	    ;;
	-r|--rebuild)
	    export rebuild=1
	    ;;
	--)
	    shift
	    break;;
    esac
    shift
done

TMPDIR=$(mktemp -d tmpdir.XXXXXX)

mlbplay -s "$TMPDIR" $@
TSFILE=$(cd "$TMPDIR" && ls *.ts)
mv "$TMPDIR/$TSFILE" .
rm -rf "$TMPDIR"

transcode.py --audiotrack="$audiotrack" "$TSFILE"

podcast.py
