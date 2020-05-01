import strutils
import sets
import tables

proc get_input(): seq[string] =
    let file_str = strip(readFile("input.txt"))
    return split_lines(file_str)

proc max[T](S: HashSet[T]): T =
    var m = low(T)
    for item in S:
        if item > m:
            m = item
    return m

let arg = get_input()

var regs = init_table[string, int]()
var all_values = init_hashset[int]()
all_values.incl(0)

for line in arg:
    var l = line.split(" ")
    
    var r1 = l[0]
    var r2 = l[4]
    if not (r1 in regs):
        regs[r1] = 0
    if not (r2 in regs):
        regs[r2] = 0
    
    let sign =
        if l[1] == "dec": -1
        else: 1
    
    var c = parse_int(l[^1])
    let b = (l[^2] == "!=" and regs[r2] != c) or
            (l[^2] == "==" and regs[r2] == c) or
            (l[^2] == "<=" and regs[r2] <= c) or
            (l[^2] == ">=" and regs[r2] >= c) or
            (l[^2] == "<" and regs[r2] < c) or
            (l[^2] == ">" and regs[r2] > c)
    if b:
        regs[r1] += sign * parse_int(l[2])
        all_values.incl(regs[r1])

var values = new_seq[int](0)
for v in regs.values:
    values.add(v)

echo max(values)
echo max(all_values)