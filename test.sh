#!/bin/bash
i=0;
while (( i < 5 ));
do echo $((i++));
done;

trap 'echo "exiot detected"' 0
echo "before ecit"
exit 0
