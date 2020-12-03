import strutils
import tables
import deques
import math
import ../advent

let arg = get_input()

var index = @[0, 0]

var regs = @[init_table[string, int](), init_table[string, int]()]
for c in abc:
    regs[0][$c] = 0
    regs[1][$c] = 0
regs[1]["p"] = 1

var q = @[init_deque[int](), init_deque[int]()]

proc value(s: string, k: int): int =
    if s in regs[k]:
        return regs[k][s]
    return int(parse_int(s))

let n = len(arg)

var answer = 0

proc music(k: int): void =
    while index[k] < n:
        let l = arg[index[k]].split(" ")
        case l[0]:
            of "snd":
                if k == 1:
                    answer += 1
                q[1-k].add_last(value(l[1],k))
            of "set":
                regs[k][l[1]] = value(l[2],k)
            of "add":
                regs[k][l[1]] += value(l[2],k)
            of "mul":
                regs[k][l[1]] *= value(l[2],k)
            of "mod":
                regs[k][l[1]] = regs[k][l[1]] mod value(l[2],k)
            of "rcv":
                if q[k].len == 0:
                    return
                regs[k][l[1]] = q[k].pop_first()
            of "jgz":
                if value(l[1],k) > 0:
                    index[k] += value(l[2],k) - 1
        index[k] += 1

while true:
    music(0)
    music(1)
    if len(q[0]) + len(q[1]) == 0:
        break

echo answer










