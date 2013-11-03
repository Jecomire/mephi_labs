#!/bin/bash
#
# Date: 2013/11/03
# Author: Christian
# License: gpl_v3
# Product: tcp2graphviz
# ------------------------------------------------------------------------
# tcp2graphviz : v0.0 : convert tcpdump into graphviz-dot-format file
#   for visualisation of network communiation.
# Description:
#   tcp2graphviz takes source IP(4/6) and destination IP(4/6) from tcpdump
#   and outdut them in graphviz-dot-syntax to draw a graph.
# ------------------------------------------------------------------------
# works for simple tcpdumps, like,
#   tcpdump -nS -i eth0     (on tcpdump v 4.1.1)
# i.e.:
#   3rd column : source IP
#   5th columnt: destination IP
# if you have another log format, you need to edit script by yourself
# ------------------------------------------------------------------------
# args:
# first:  path/to/tcpdump file (not raw/binary one)
# second: path/to/output file. IPV4 and IPV6 will be in different files,
# like: <path/to/output/file>.ip4.dot and <path/to/output/file>.ip6.dot
# Since it makes no sense to draw them on the same graph.
# ------------------------------------------------------------------------
#TODO:
# * need to add colors for graphviz
# * may be some setting, like font and scale
#-------------------------------------------------------------------------


if [[ $# -ne 2 ]]; then
    app_name=$(basename $0)
    echo "usage: $app_name <INPUT TCPDUMP FILE> <OUTPUT GRAPHVIZ-FILE>"
    exit 1;
fi

FILE=$1
RESULT_IP4="$2.ip4.dot"
RESULT_IP6="$2.ip6.dot"
TMP=$(mktemp)


echo "digraph tcpdump_graph_ip4 {" > $RESULT_IP4
echo "digraph tcpdump_graph_ip6 {" > $RESULT_IP6


# IPv4 --------------------------------------------------------------
echo -n "" > $TMP

grep -E "IP\ " $FILE | awk '{ printf "\"%s\" -> \"%s\";\n", gensub(/(([0-9]{1,3}.){3})([0-9]{1,3}).*/, "\\1\\3", "1", $3), gensub(/(([0-9]{1,3}.){3})([0-9]{1,3}).*/, "\\1\\3", "1", $5)  }' >> $TMP

sort -u $TMP >> $RESULT_IP4
echo "}" >> $RESULT_IP4


# IPv6 --------------------------------------------------------------
echo -n "" > $TMP

grep -E "IP6" $FILE | awk 'BEGIN {e="(([0-9a-fA-F:]{1,5}){1,5}):([0-9a-fA-F]{1,4}).*";} { printf "\"%s\" -> \"%s\";\n", gensub(e, "\\1:\\3", "1", $3), gensub(e, "\\1:\\3", "1", $5) }' >> $TMP

sort -u $TMP >> $RESULT_IP6
echo "}" >> $RESULT_IP6



# Remove TMP file!
rm $TMP





# useful data:
# $ echo "192.168.1.2" | awk '{ split ($1, a, "."); print a[1]  }'
# cat test-dot.dot |dot -Tsvg -o test-dot.svg

# time egrep "IP\ " /tmp/tcpdump/dump/tcp_all_2013_06_11.log | awk '{ print gensub(/(([0-9]{1,3}.){3})([0-9]{1,3}).*/, "[\\1\\3]", "1", $3), " -> " , gensub(/(([0-9]{1,3}.){3})([0-9]{1,3}).*/, "[\\1\\3]", "1", $5)  }'

# http://stackoverflow.com/questions/8009664/split-string-to-array-using-awk
# http://regex101.com

# http://snipplr.com/view/43003/

