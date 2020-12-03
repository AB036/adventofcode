import strutils
import math
import tables

let arg = 277678


iterator spiral(): (int, int, int) =
    var m = 1
    var d = 1
    var x = 0
    var y = 0
    while true:
        m += 1
        d += 2
        x += 1
        yield (m,x,y)
        for k in 1 .. d-2:
            m += 1
            y -= 1
            yield (m,x,y)
        for k in 1 .. d-1:
            x -= 1
            m += 1
            yield (m,x,y)
        for k in 1 .. d-1:
            y += 1
            m += 1
            yield (m,x,y)
        for k in 1 .. d-1:
            x += 1
            m += 1
            yield (m,x,y)

for m,x,y in spiral():
    if m == arg:
        echo abs(x) + abs(y)
        break

var grid = initTable[(int, int), int]()
grid[(0,0)] = 1

for m,x,y in spiral():
    var s = 0
    for nx in @[x-1,x,x+1]:
        for ny in @[y-1,y,y+1]:
            if not((nx,ny) in grid):
                grid[(nx,ny)] = 0
            s += grid[(nx,ny)]
    grid[(x,y)] = s
    if s >= arg:
        echo s
        break
            











