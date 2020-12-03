import strutils
import sets
import tables

proc get_input(): seq[string] =
    let file_str = strip(readFile("input.txt"))
    return splitLines(file_str)

let arg = get_input()

var weights = initTable[string, int]()
var tree = initTable[string, seq[string]]()
var not_root = initHashSet[string]()

for line in arg:
    if "->" in line:
        let l = line.split(" -> ")
        let ll = l[0].split(" ")
        weights[ll[0]] = parse_int(ll[1][1 .. ^2])
        tree[ll[0]] = l[1].split(", ")
        not_root = not_root + toHashSet(l[1].split(", "))
    else:
        let ll = line.split(" ")
        weights[ll[0]] = parseInt(ll[1][1 .. ^2])
   
var root = ""
for name in weights.keys:
    if not (name in not_root):
        echo name
        root = name

proc total_weight(name: string): int =
    if not (name in tree):
        return weights[name]
    var children = newSeq[int](0)
    for child in tree[name]:
        children.add(total_weight(child))
    let n = len(children)
    var s = 0
    for i in 0 .. n-1:
        s += children[i]
        if children[i] != children[0]:
            if children[i] != children[1]:
                echo weights[tree[name][i]] + children[0] - children[i]
            else:
                echo weights[tree[name][0]] + children[i] - children[0]
    return s + weights[name]

echo total_weight(root)