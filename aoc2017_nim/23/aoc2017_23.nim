import strutils
import tables
import sets
import ../advent

let arg = get_input()
let n = len(arg)

var regs = init_table[string, int]()
for c in "abcdefgh":
    regs[$c] = 0

proc value(s: string): int =
    if s in regs:
        return regs[s]
    return int(parse_int(s))

var i = 0
var mul = 0
while i < n:
    let l = arg[i].split(" ")
    case l[0]:
        of "set":
            regs[l[1]] = value(l[2])
        of "sub":
            regs[l[1]] -= value(l[2])
        of "mul":
            regs[l[1]] *= value(l[2])
            mul += 1
        of "jnz":
            if value(l[1]) != 0:
                i += value(l[2]) - 1
    i += 1

echo mul

var h = 0
var b = 67
var c = b
b *= 100
b -= -100000
c = b
c -= -17000

while true:
    for dd in 2 .. b-1:
        if (b mod dd) == 0:
            h += 1
            break
    if b == c:
        break
    b += 17

echo h