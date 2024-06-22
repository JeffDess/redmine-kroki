#!/bin/bash

FILE=data/_all_diagrams.md
echo -e "# All Diagrams" > $FILE
find data ! -name '_*' -type f | sort | xargs cat >> $FILE
sed -i '/^$/N;/^\n$/D' $FILE
