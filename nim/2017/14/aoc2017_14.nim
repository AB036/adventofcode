import strutils
import sequtils
import tables
import sets
import ../10/aoc2017_10

proc get_input(): seq[string] =
    let file_str = strip(read_file("input.txt"))
    return split_lines(file_str)

let arg = get_input()[0]
#~ let arg = "flqrgnkx"

# var grid : array[128, array[128, int]]

var grid = init_hashset[(int,int)]()

for y in 0 .. 127:
    let hash = knot_hash(arg & "-" & $y)
    for k in 0 .. 31:
        let b = parse_hex_int($hash[k])
        for kk in 0 .. 3:
            if ((b shr (3 - kk)) and 1) == 1:
                grid.incl((4*k + kk, y)) 

echo len(grid)

var seen = init_hashset[(int,int)]()

var groups = 0

for (x,y) in grid:
    if (x,y) in seen:
        continue
    var fifo = new_seq[(int,int)]()
    fifo.add((x,y))
    while len(fifo) != 0:
        let (xx,yy) = fifo.pop()
        if (xx,yy) in seen:
            continue
        seen.incl((xx,yy))
        for (xxx,yyy) in [(xx+1,yy), (xx-1,yy), (xx,yy+1), (xx,yy-1)]:
            if (xxx, yyy) in grid:
                fifo.add((xxx,yyy))
    groups += 1

echo groups