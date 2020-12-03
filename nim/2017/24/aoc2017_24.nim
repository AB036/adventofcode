import strutils
import tables
import sets
import deques
import ../advent

let arg = get_input()
let n = len(arg)

var ports = new_seq[(int,int)]()

for line in arg:
    let l = line.split("/")
    ports.add((parse_int(l[0]), parse_int(l[1])))

var best_strength = 0
var best_length = 0

var pile = init_deque[(int, seq[int])]()
pile.add_last((0, @[]))

while len(pile) > 0:
    let (p, l) = pile.pop_last()
    var added_something = false
    for i in 0 ..< n:
        if i in l:
            continue
        let (a,b) = ports[i]
        if a == p:
            pile.add_last((b, l & @[i]))
            added_something = true
        if b == p:
            pile.add_last((a, l & @[i]))
            added_something = true
    if not added_something:
        if len(l) > best_length:
            best_strength = 0
            best_length = len(l)
        if len(l) == best_length:
            var s = 0
            for i in l:
                s += ports[i][0] + ports[i][1]
            best_strength = max(best_strength, s)

echo best_strength