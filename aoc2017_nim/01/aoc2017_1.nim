import strutils

proc get_input(): string =
    result = strip(readFile("input.txt"))

let file = get_input()
let n = len(file)

var L = newSeq[int](0)
for c in file:
    L.add(int(c) - int('0'))

var s = 0
for k in 0 .. n-1:
    if L[k] == L[(k + n div 2) mod n]:
        s += L[k]

echo s