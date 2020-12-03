import strutils
import tables
import ../advent

let arg = get_input()[0].split(",")
    
var programs = "abcdefghijklmnop"
let n = len(programs)

proc dance(prog: var string) =
    for move in arg:
        case move[0]:
            of 's':
                let spin = parse_int(move[1 .. ^1])
                prog = prog[n-spin .. n-1] & prog[0 .. n-spin-1]
            of 'x':
                let exchange = move[1 .. ^1].split("/")
                let tmp = prog[parse_int(exchange[0])]
                prog[parse_int(exchange[0])] = prog[parse_int(exchange[1])]
                prog[parse_int(exchange[1])] = tmp
            of 'p':
                let exchange = move[1 .. ^1].split("/")
                var i = 0
                var j = 0
                for k,p in prog:
                    if $p == exchange[0]:
                        i = k
                    if $p == exchange[1]:
                        j = k
                let tmp = prog[i]
                prog[i] = programs[j]
                prog[j] = tmp
            else:
                discard
    


var moves = init_table[string, int]()
var x = 0

while x < 1000000000:
    x += 1
    dance(programs)
    if x == 1:
        echo programs
    if programs in moves:
        break
    moves[programs] = x

if x != 1000000000:
    let cycle = x - moves[programs]
    let todo = (1000000000 - x) mod cycle
    for k in 0 ..< todo:
        dance(programs)

echo programs














