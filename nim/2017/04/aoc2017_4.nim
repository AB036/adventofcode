import strutils
import sets
import tables

proc get_input(): seq[string] =
    let file_str = strip(readFile("input.txt"))
    return splitLines(file_str)

let arg = get_input()

var s = 0
var s2 = 0

for line in arg:
    var l = line.split(" ")
    if len(toHashSet(l)) == len(l):
        s += 1
    let n = len(l)
    var anagrams = false
    for i in 0 .. n-2:
        for j in i+1 .. n-1:
            if toCountTable(l[i]) == toCountTable(l[j]):
                anagrams = true
    if not anagrams:
        s2 += 1

echo s
echo s2