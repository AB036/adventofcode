import strutils
import tables
import sets
import ../advent

let arg = get_input()

proc print(s: string): void =
    echo "-------------------------"
    for line in s.split("/"):
        echo line

proc flip(s: string) : string =
    let w = if len(s) == 11: 3 else: 2
    result = s
    for x in 0 ..< w:
        for y in 0 ..< w:
            result[(w+1)*y + x] = s[(w+1)*(w-1-y) + x]

proc rot(s: string) : string =
    let w = if len(s) == 11: 3 else: 2
    result = s
    for x in 0 ..< w:
        for y in 0 ..< w:
            result[(w+1)*y + x] = s[(w+1)*x + (w-1-y)]

var tr = init_table[string, string]()

for line in arg:
    let l = line.split(" => ")
    tr[l[0]] = l[1]
    tr[rot(l[0])] = l[1]
    tr[rot(rot(l[0]))] = l[1]
    tr[rot(rot(rot(l[0])))] = l[1]
    tr[flip(l[0])] = l[1]
    tr[rot(flip(l[0]))] = l[1]
    tr[rot(rot(flip(l[0])))] = l[1]
    tr[rot(rot(rot(flip(l[0]))))] = l[1]

var pattern = ".#./..#/###"
#~ print(pattern)

for i in 0 .. 17:
    let w = pattern.find('/')
    var next_pattern = ""
    if (w mod 2) == 0:
        for line in 0 ..< 3*(w div 2):
            next_pattern &= '_'.repeat(3*(w div 2))
            if line != 3*(w div 2) - 1:
                next_pattern &= "/"
        for X in 0 ..< (w div 2):
            for Y in 0 ..< (w div 2):
                var sub_pattern = "__/__"
                for x in 0 ..< 2:
                    for y in 0 ..< 2:
                        sub_pattern[3*y + x] = pattern[(w+1)*(2*Y + y) + (2*X + x)]
                sub_pattern = tr[sub_pattern]
                for x in 0 ..< 3:
                    for y in 0 ..< 3:
                        next_pattern[(3*(w div 2) + 1) * (3*Y + y) + (3*X + x)] = sub_pattern[4*y + x]
    elif (w mod 3) == 0:
        for line in 0 ..< 4*(w div 3):
            next_pattern &= '_'.repeat(4*(w div 3))
            if line != 4*(w div 3) - 1:
                next_pattern &= "/"
        for X in 0 ..< (w div 3):
            for Y in 0 ..< (w div 3):
                var sub_pattern = "___/___/___"
                for x in 0 ..< 3:
                    for y in 0 ..< 3:
                        sub_pattern[4*y + x] = pattern[(w+1)*(3*Y + y) + (3*X + x)]
                sub_pattern = tr[sub_pattern]
                for x in 0 ..< 4:
                    for y in 0 ..< 4:
                        next_pattern[(4*(w div 3) + 1) * (4*Y + y) + (4*X + x)] = sub_pattern[5*y + x]
    else:
        echo "invalid width: ", w
    #~ print(next_pattern)
    pattern = next_pattern
    if (i == 4) or (i == 17):
        echo pattern.count('#')

