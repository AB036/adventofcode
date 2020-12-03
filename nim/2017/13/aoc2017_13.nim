import strutils
import sequtils
import tables
import sets

proc get_input(): seq[string] =
    let file_str = strip(read_file("input.txt"))
    return split_lines(file_str)

let arg = get_input()

var firewall = init_table[int, int]()
var n = 0

for line in arg:
    let l = line.split(": ")
    firewall[l[0].parse_int()] = parse_int(l[1])
    n = max(n, l[0].parse_int())

var delay = 0

while true:
    var success = true
    for depth in 0 .. n:
        if depth in firewall:
            if (depth + delay) mod (2*(firewall[depth] - 1)) == 0:
                success = false
                break
    if success:
        break
    delay += 1

echo delay