import strutils
import tables
import sets
import ../advent

let arg = get_input()
let n = len(arg)

var map = init_table[(int,int), int]()

for i,line in arg:
    for j,c in line:
        map[(j - (n div 2), i - (n div 2))] = if (c == '#'): 2 else: 0

let right = {'u':'r', 'r':'d', 'd':'l', 'l':'u'}.to_table
let left = {'u':'l', 'l':'d', 'd':'r', 'r':'u'}.to_table
let foward = {'u':(0,-1), 'r':(1,0), 'd':(0,1), 'l':(-1,0)}.to_table

var dir = 'u'
var x = 0
var y = 0

var answer = 0

for k in 0 ..< 10000000:
    if (x,y) notin map:
        map[(x,y)] = 0
    if map[(x,y)] == 0:
        dir = left[dir]
    elif map[(x,y)] == 1:
        answer += 1
    elif map[(x,y)] == 2:
        dir = right[dir]
    elif map[(x,y)] == 3:
        dir = right[right[dir]]
    map[(x,y)] = (map[(x,y)] + 1) mod 4
    x += foward[dir][0]
    y += foward[dir][1]

echo answer