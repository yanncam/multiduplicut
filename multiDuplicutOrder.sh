#!/bin/bash
echo "
  __  __       _ _   _ _____              _ _            _
 |  \/  |     | | | (_)  __ \            | (_)          | |
 | \  / |_   _| | |_ _| |  | |_   _ _ __ | |_  ___ _   _| |_
 | |\/| | | | | | __| | |  | | | | | '_ \| | |/ __| | | | __|
 | |  | | |_| | | |_| | |__| | |_| | |_) | | | (__| |_| | |_
 |_|  |_|\__,_|_|\__|_|_____/ \__,_| .__/|_|_|\___|\__,_|\__|
                                   | |
                                   |_|    v 1.0
Duplicut (https://github.com/nil0x42/duplicut) wrapper for
Multi (huge) wordlists, fast deduplication and keep order.

Credits:
        - Duplicut @nil0x42
        - MultiDuplicut wrapper @ycam (Yann CAM / asafety.fr)

How to use ?
Install Duplicut, place your wordlists with *.txt extension
into a new folder and add the MultiDuplicut script in it.
Then just run MultiDuplicut script.
"
DUPLICUTBINARY=`which duplicut`

START_TIME=$SECONDS
arrWordlistsOrderedBySize=( $(ls -Sr *.txt) )
echo -e "[*] ${#arrWordlistsOrderedBySize[@]} wordlists identified !"
echo -e "[*] Each wordlist will be cleaned in the following order (only first word appearence in the first wordlist will be kept)."
for wordlisti in "${arrWordlistsOrderedBySize[@]}"
do
	FILESIZE=$(stat -c%s "$wordlisti")
	FILENBLINE=$(wc -l "$wordlisti" | cut -d' ' -f1)
	echo -e "\t[+] [$wordlisti] ($FILESIZE B | $FILENBLINE words)"
done

NBTMPFILE=`expr ${#arrWordlistsOrderedBySize[@]} - 1`
echo -e "[*] $NBTMPFILE temp-files will be created."

TMPVALUES=()
TMPFILES=()
for (( v=0; v<$NBTMPFILE; v++ )); do
	RANDVAL=`tr -dc A-Za-z0-9 </dev/urandom | head -c 100`
	TMPVALUE=`echo $RANDVAL`
	TMPVALUES[$v]="$TMPVALUE"
	TMPFILE=$(mktemp $v.XXXXXXX.tmp)
	TMPFILES[$v]="$TMPFILE"
	echo $TMPVALUE > $TMPFILE
done

FILESTOCONCAT=""
for (( w=0; w<=$v; w++ )); do
#	echo -n "${arrWordlistsOrderedBySize[$w]} ${TMPFILES[$w]} "
	FILESTOCONCAT+="${arrWordlistsOrderedBySize[$w]} ${TMPFILES[$w]} "
done

BIGFILECONCATENATED=$(mktemp FULL.XXXXXXX.tmp)
echo -e "[*] Full-concatenation of wordlists with separators started into $BIGFILECONCATENATED."
cat $FILESTOCONCAT > $BIGFILECONCATENATED
for tmpi in "${TMPFILES[@]}"; do
        rm -f $tmpi
done

echo -e "[*] Run full-duplicut over full-concatened-wordlist $BIGFILECONCATENATED (press ENTER to see status)"
$DUPLICUTBINARY -l 255 $BIGFILECONCATENATED -o $BIGFILECONCATENATED.duplicuted
rm -f $BIGFILECONCATENATED

headline=0
tailline=0
valkeeped=0
echo -e "[*] Regenerate initial wordlists multiduplicuted."
for vali in "${TMPVALUES[@]}"; do
	LINENB=`awk "/$vali/{ print NR; exit }" $BIGFILECONCATENATED.duplicuted`
	echo -e "\t[*] Value [$vali] found at line $LINENB !"
	tailline=`expr $LINENB - 1`
	headline=`expr $tailline - $valkeeped`
	head -n $tailline $BIGFILECONCATENATED.duplicuted | tail -n $headline > $vali
	valkeeped=$LINENB
#	echo "head -n $tailline $BIGFILECONCATENATED.duplicuted | tail -n $headline"
done
totalnbline=$(wc -l $BIGFILECONCATENATED.duplicuted | cut -d' ' -f1)
lasttail=`expr $totalnbline - $valkeeped`
tail -n $lasttail $BIGFILECONCATENATED.duplicuted > lasttail

echo -e "[*] Rename final wordlists multiduplicuted."
for (( i=0; i<${#TMPVALUES[@]}; i++ )); do
	mv ${TMPVALUES[$i]} ${arrWordlistsOrderedBySize[$i]}.multiduplicut
done
mv lasttail ${arrWordlistsOrderedBySize[$i]}.multiduplicut

#echo "${TMPVALUES[@]}"
#echo "${TMPFILES[@]}"

rm -f $BIGFILECONCATENATED.duplicuted

GLOBALSIZE=0
GLOBALLINE=0
GLOBALSIZEDUPLICUTED=0
GLOBALLINEDUPLICUTED=0
for wordlisti in "${arrWordlistsOrderedBySize[@]}"
do
        FILESIZE=$(stat -c%s "$wordlisti")
	FILESIZEDUPLICUTED=$(stat -c%s "$wordlisti.multiduplicut")
        FILENBLINE=$(wc -l "$wordlisti" | cut -d' ' -f1)
	FILENBLINEDUPLICUTED=$(wc -l "$wordlisti.multiduplicut" | cut -d' ' -f1)
        echo -ne "\t[+] [$wordlisti] ($FILESIZE B | $FILENBLINE words) => [$wordlisti.multiduplict] ($FILESIZEDUPLICUTED B | $FILENBLINEDUPLICUTED words) "
	REDUCEDLINE=`expr $FILENBLINE - $FILENBLINEDUPLICUTED`
	REDUCEDBYTE=`expr $FILESIZE - $FILESIZEDUPLICUTED`
	PERCENTOPTI=$(( 100-(100*FILESIZEDUPLICUTED / FILESIZE) ))
	echo -e "$REDUCEDLINE words deleted, $REDUCEDBYTE bytes reducted, optimization : $PERCENTOPTI%"
	GLOBALSIZE=$(( GLOBALSIZE+FILESIZE ))
	GLOBALSIZEDUPLICUTED=$(( GLOBALSIZEDUPLICUTED+FILESIZEDUPLICUTED ))
	GLOBALLINE=$(( GLOBALLINE+FILENBLINE ))
	GLOBALLINEDUPLICUTED=$(( GLOBALLINEDUPLICUTED+FILENBLINEDUPLICUTED ))
done
GLOBALREDUCEDSIZE=$(( GLOBALSIZE-GLOBALSIZEDUPLICUTED ))
PERCENTOPTI=$(( 100-(100*GLOBALSIZEDUPLICUTED / GLOBALSIZE) ))
echo -e "[*] Global : Wordlists size $GLOBALSIZE ($(((GLOBALSIZE/1024)/1024))MB) reduce to $GLOBALSIZEDUPLICUTED (-$GLOBALREDUCEDSIZE (-$(((GLOBALREDUCEDSIZE/1024)/1024))MB)) (Optimization $PERCENTOPTI%)"
GLOBALREDUCEDLINE=$(( GLOBALLINE-GLOBALLINEDUPLICUTED ))
PERCENTOPTI=$(( 100-(100*GLOBALLINEDUPLICUTED / GLOBALLINE) ))
echo -e "[*] Global : Wordlists line $GLOBALLINE reduce to $GLOBALLINEDUPLICUTED (-$GLOBALREDUCEDLINE) (Optimization $PERCENTOPTI%)"


ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "[*] All done in $ELAPSED_TIME seconds ($(($ELAPSED_TIME/3600)) hour $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec) !"
