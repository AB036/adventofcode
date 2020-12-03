import strutils
import tables
import sets

proc get_input(): seq[string] =
    let file_str = strip(read_file("input.txt"))
    return split_lines(file_str)

proc max[T](S: HashSet[T]): T =
    var m = low(T)
    for item in S:
        if item > m:
            m = item
    return m

let arg = get_input()[0]

let d = {"n": (-1,0,1),
         "s": (1,0,-1),
         "ne":(-1,1,0),
         "nw":(0,-1,1),
         "sw":(1,-1,0),
         "se":(0,1,-1)}.toTable
var x = 0
var y = 0
var z = 0

var dist = init_hashset[int]()

for dir in arg.split(","):
    let (dx,dy,dz) = d[dir]
    x += dx
    y += dy
    z += dz
    dist.incl((abs(x) + abs(y) + abs(z)) div 2)

echo (abs(x) + abs(y) + abs(z)) div 2
echo max(dist)