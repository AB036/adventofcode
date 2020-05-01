import strutils
import sets
import tables

proc get_input(): seq[string] =
    let file_str = strip(readFile("input.txt"))
    return splitLines(file_str)

let arg = get_input()

var L = newSeq[int](0)

for line in arg:
    L.add(parseInt(line))

let n = len(L)
var k = 0
var steps = 0

while k < n:
    var offset = L[k]
    if offset >= 3:
        L[k] -= 1
    else:
        L[k] += 1
    k += offset
    steps += 1

echo steps