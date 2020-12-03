import strutils
import sets
import tables

proc get_input(): seq[string] =
    let file_str = strip(readFile("input.txt"))
    return splitLines(file_str)

let arg = get_input()

var L = newSeq[int](0)

for num in arg[0].split("\t"):
    L.add(parseInt(num))

let n = len(L)
#~ var seen = initHashSet[seq[int]]()
var seen = initTable[seq[int], int]()

var k = 0
while not(L in seen):
    seen[L] = k
    k += 1
    
    var m = L[0]
    var index_max = 0
    for k in 0 .. n-1:
        if L[k] > m:
            m = L[k]
            index_max = k
    
    var to_distribute = L[index_max]
    L[index_max] = 0
    for k in 1 .. to_distribute mod n:
        L[(index_max + k) mod n] += 1
    for k in 0 .. n-1:
        L[k] += to_distribute div n

echo len(seen)
echo k - seen[L]