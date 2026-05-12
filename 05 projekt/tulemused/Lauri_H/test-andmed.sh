#!/bin/bash

BASE="/c/tmp/test-puhastus"

echo "Loon testkausta: $BASE"
mkdir -p "$BASE"

# vanad failid
for i in 1 2 3 4 5; do
    echo "Vana fail $i" > "$BASE/vana_$i.log"
    touch -d "10 days ago" "$BASE/vana_$i.log"
done

# värsked failid
for i in 1 2 3; do
    echo "Värske fail $i" > "$BASE/varske_$i.txt"
done

echo "Valmis!"
ls -la "$BASE"