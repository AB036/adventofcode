import strutils

proc get_input(): seq[string] =
    let file_str = strip(readFile("input.txt"))
    return splitLines(file_str)

let arg = get_input()

var s = 0
var s2 = 0

for line in arg:
    var l = newSeq[int](0)
    for number in line.split("\t"):
        l.add(parseInt(number))
    s += max(l) - min(l)
    let n = len(l)
    for i in 0 .. n-2:
        for j in i+1 .. n-1:
            if l[i] mod l[j] == 0:
                s2 += l[i] div l[j]
            if l[j] mod l[i] == 0:
                s2 += l[j] div l[i]

echo s
echo s2