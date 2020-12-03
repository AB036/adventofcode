import strutils
import sequtils
import tables
import sets

proc get_input(): seq[string] =
    let file_str = strip(read_file("input.txt"))
    return split_lines(file_str)

let arg = get_input()

var graph = init_ordered_table[int, seq[int]]()

for line in arg:
    let l = line.split(" <-> ")
    graph[parse_int(l[0])] = map(l[1].split(", "), parse_int)


var groups = 0
var seen = init_hashset[int]()

for program in graph.keys:
    if program in seen:
        continue
        
    var fifo = @[program]
    
    while len(fifo) != 0:
        let pid = fifo.pop()
        if pid in seen:
            continue
        seen.incl(pid)
        for pid2 in graph[pid]:
            fifo.add(pid2)
    if program == 0:
        echo len(seen)
    groups += 1

echo groups
    