import strutils
import tables
import sets
import deques
import ../advent


var tape = init_table[int, bool]()
tape[0] = false
var cursor = 0
var state = 'A'

var mini = 0
var maxi = 0

for k in 0 ..< 12368930:
    if cursor == mini:
        mini -= 1
        tape[mini] = false
    if cursor == maxi:
        maxi += 1
        tape[maxi] = false
    case state:
        of 'A':
            if tape[cursor] == false:
                tape[cursor] = true
                cursor += 1
                state = 'B'
            else:
                tape[cursor] = false
                cursor += 1
                state = 'C'
        of 'B':
            if tape[cursor] == false:
                tape[cursor] = false
                cursor -= 1
                state = 'A'
            else:
                tape[cursor] = false
                cursor += 1
                state = 'D'
        of 'C':
            if tape[cursor] == false:
                tape[cursor] = true
                cursor += 1
                state = 'D'
            else:
                tape[cursor] = true
                cursor += 1
                state = 'A'
        of 'D':
            if tape[cursor] == false:
                tape[cursor] = true
                cursor -= 1
                state = 'E'
            else:
                tape[cursor] = false
                cursor -= 1
                state = 'D'
        of 'E':
            if tape[cursor] == false:
                tape[cursor] = true
                cursor += 1
                state = 'F'
            else:
                tape[cursor] = true
                cursor -= 1
                state = 'B'
        of 'F':
            if tape[cursor] == false:
                tape[cursor] = true
                cursor += 1
                state = 'A'
            else:
                tape[cursor] = true
                cursor += 1
                state = 'E'
        else:
            echo "something wrong here"

var s = 0
for k in mini .. maxi:
    if tape[k]:
        s += 1

echo s
            