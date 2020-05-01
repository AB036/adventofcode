import strutils
import tables
import sets
import ../advent

let arg = get_input()
let n = len(arg)

var p = new_seq[array[3, int]](n)
var v = new_seq[array[3, int]](n)
var a = new_seq[array[3, int]](n)

for k in 0 ..< n:
    let l = arg[k].split(">, ")
    let pl = l[0][3 .. ^1].split(",")
    let vl = l[1][3 .. ^1].split(",")
    let al = l[2][3 .. ^2].split(",")
    for i in 0 .. 2:
        p[k][i] = parse_int(pl[i])
        v[k][i] = parse_int(vl[i])
        a[k][i] = parse_int(al[i])

var a_min = high(int)
var k_min = -1
for k in 0 ..< n:
    let abs_a = abs(a[k][0]) + abs(a[k][1]) + abs(a[k][2])
    if abs_a < a_min:
        a_min = abs_a
        k_min = k

echo k_min
        
var removed = init_hashset[int]()
let t_max = int(2 * (abs(v[k_min][0]) + abs(v[k_min][1]) + abs(v[k_min][2])) / a_min) + 1

for t in 0 .. t_max:
    var coords = init_table[array[3, int], int]()
    for k in 0 ..< n:
        if k notin removed:
            if p[k] in coords:
                removed.incl(k)
                removed.incl(coords[p[k]])
            else:
                coords[p[k]] = k
    
    for k in 0 ..< n:
        for i in 0 .. 2:
            v[k][i] += a[k][i]
            p[k][i] += v[k][i]
    
echo n - len(removed)
        








