import strutils
import tables
import deques
import math
import ../advent

let arg = get_input()

var answer = ""
var answer2 = 0
var x = 0
var y = 0

for i,c in arg[0]:
    if c == '|':
        x = i
        break

var direction = 'd'
let advance = {'u':(0,-1), 'd':(0,1), 'l':(-1,0), 'r':(1,0)}.to_table

while arg[y][x] != ' ':
    answer2 += 1
    x += advance[direction][0]
    y += advance[direction][1]
    if arg[y][x] in "-|":
        continue
    elif arg[y][x] in ABC:
        answer &= arg[y][x]
    elif arg[y][x] == '+':
        if direction in "ud":
            direction = if arg[y][x+1] == ' ': 'l' else: 'r'
        else:
            direction = if arg[y+1][x] == ' ': 'u' else: 'd'
    
echo answer
echo answer2








