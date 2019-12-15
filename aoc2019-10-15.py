#!/usr/bin/env python3
# -*- coding: utf-8 -*-



import time
import numpy as np
import random
import matplotlib.pyplot as plt
import math
import collections
import string
import itertools
import copy
import hashlib

from advent import *

def day11():
    import intcode
    arg = get_input()
    num = get_numbers(arg)
    
    pro = intcode.process(num, printt = False)
    
    x,y = 0,0
    direction = "up"
    grid = dict()
    s = 0
    out = fifo()
    pro.out(out)
    grid[(0,0)] = 1 #part2
    
    while pro.alive:
        if (x,y) not in grid:
            s += 1
            grid[(x,y)] = 0
        pro.feed(grid[(x,y)])
        pro.run_until_output()
        pro.run_until_output()
        if not pro.alive:
            break
        color = out.get_nowait()
        d = out.get_nowait()
        grid[(x,y)] = color
        if d == 0: #left
            direction = {"up":"left", "left":"down", "down":"right", "right":"up"}[direction]
        else: #right
            direction = {"up":"right", "right":"down", "down":"left", "left":"up"}[direction]
        x += {"left":-1, "right":1, "up":0, "down":0}[direction]
        y += {"left":0, "right":0, "up":-1, "down":1}[direction]
    
    
    xa, xb = min(x for (x,y) in grid), max(x for (x,y) in grid)
    ya, yb = min(y for (x,y) in grid), max(y for (x,y) in grid)
    
    L = [[0 for i in range(xa, xb+1)] for j in range(ya, yb+1)]
    
    for x,y in grid:
        L[y-ya][x-xa] = grid[(x,y)]
    
    plt.matshow(L)


def day12():
    arg = get_input(1)
    num = get_numbers(arg)
    
    pos = [list(a) for a in num]
    v = [[0,0,0] for a in num]
    
    pairs = ((0,1),(0,2),(0,3),(1,2),(1,3),(2,3))
    start = tuple( tuple(e[axis] for e in pos+v) for axis in range(3))
    
    step = 0
    cycles = [0,0,0]
    
    while 0 in cycles:
        step += 1
        for m1,m2 in pairs:
            for axis in range(3):
                if pos[m1][axis] > pos[m2][axis]:
                    v[m1][axis] -= 1
                    v[m2][axis] += 1
                elif pos[m1][axis] < pos[m2][axis]:
                    v[m1][axis] += 1
                    v[m2][axis] -= 1
        for m in range(4):
            for axis in range(3):
                pos[m][axis] += v[m][axis]
        for axis in range(3):
            t = tuple(e[axis] for e in pos+v)
            if cycles[axis] == 0 and t == start[axis]:
                cycles[axis] = step
    
    # Plus petit commun multiple
    a,b,c = cycles
    lcm = (a*b)//pgcd(a,b)
    lcm = (lcm*c)//pgcd(lcm,c)
    print(cycles)
    print(lcm)
    
def day13():
    arg = get_input()
    num = get_numbers(arg)
    
    import intcode
    pro = intcode.process(num, printt = False)
    pro.regs[0] = 2
    
    f = fifo()
    pro.out(f)
    g = dict()
            
    score = 0
    bx, by = 0,0
    px,py = 0,0
    
    while pro.alive:
        pro.run_until_stop()
        while not f.empty():
            x = f.get_nowait()
            y = f.get_nowait()
            t = f.get_nowait()
            if (x,y) == (-1,0):
                score = t
            else:
                g[(x,y)] = t
            if t == 4:
                bx,by = x,y
            if t == 3:
                px,py = x,y
        
        if bx < px:
            pro.feed(-1)
        elif bx > px:
            pro.feed(1)
        else:
            pro.feed(0)
    
    print(score)

"""
arg = get_input(1)
d = dict()

for line in arg:
    a,b = line.split(' => ')
    l = a.split(', ')
    l2 = b.split(' ')
    d[l2[1]] = (int(l2[0]),)
    for aa in l:
        aaa,bbb = aa.split(' ')
        d[l2[1]] += (int(aaa), bbb)

        
def make(number, element):
    if element == "ORE":
        return number
    
    batch = d[element][0]

    if number%batch == 0:
        n_batch = number//batch
    else:
        n_batch = number//batch + 1
        
    n = (len(d[element])-1)//2
    s = 0

    for k in range(n):
        e_needed = d[element][2 + 2*k]
        n_needed = n_batch*d[element][1+2*k]
        av = available[e_needed]
        if av >= n_needed:
            available[e_needed] -= n_needed
        else:
            available[e_needed] = 0
            s += make(n_needed-av, e_needed)

    available[element] += n_batch*batch - number
    return s

available = defdict(0)
a = make(1, "FUEL")
print("p1 :",a)

trillion = 1000000000000

upper_bound = 1000*trillion//a
lower_bound = trillion//a

while upper_bound - lower_bound > 100:
    m = (lower_bound + upper_bound)//2
    available = defdict(0)
    cost = make(m, "FUEL")
    if cost > trillion:
        upper_bound = m
    else:
        lower_bound = m
        
cost = 0
m = lower_bound
while cost < trillion:
    available = defdict(0)
    m += 1
    cost = make(m, "FUEL")

print("p2 :", m-1)

"""


arg = get_input()
num = get_numbers(arg)

"""
import intcode

pro = intcode.process(num, printt=False)
f = fifo()
pro.out(f)

grid = dict()
x,y = 0,0
grid[(0,0)] = 1



for u in range(1000000):
    k = random.choice((1,2,3,4))
    xx,yy = {1:(x,y-1), 2:(x,y+1), 3:(x-1,y), 4:(x+1,y)}[k]
    pro.feed(k)
    pro.run_until_output()
    st = f.get_nowait()
    if st == 0:
        grid[(xx,yy)] = 0
    elif st == 1:
        grid[(xx,yy)] = 1
        x,y = xx,yy
    elif st == 2:
        grid[(xx,yy)] = 2
        x,y = xx,yy
"""       



mx = min(e[0] for e in grid)
my = min(e[1] for e in grid)

Mx = max(e[0] for e in grid)
My = max(e[1] for e in grid)




for y in range(my, My+1):
    s = ""
    for x in range(mx, Mx+1):
        if (x,y) in grid:
            s += "." if grid[(x,y)] == 1 else str(grid[(x,y)])
        else:
            s += "?"
    print(s)
 
"""
pile = [(0,0,0)]
seen = set()

while pile:
    x,y,s = pile.pop(0)
    if (x,y) in seen:
        continue
    seen.add((x,y))
    for k in range(1,5):
        xx,yy = {1:(x,y-1), 2:(x,y+1), 3:(x-1,y), 4:(x+1,y)}[k]
        if (xx,yy) in grid:
            if grid[(xx,yy)] == 2:
                print(s+1)
                break
            elif grid[(xx,yy)] == 1:
                pile.append((xx,yy,s+1))
"""
arg = get_ex(1)

grid = dict()
y = 0
for line in arg:
    x = 0
    for c in line:
        if c == '0':
            grid[(x,y)] = 0
        elif c == '.':
            grid[(x,y)] = 1
        elif c == '2':
            grid[(x,y)] = 2
            x2,y2 = x,y
        x += 1
    y += 1

done = set()
frontier = set()
frontier.add((x2,y2))
step = 0

while frontier:
    new = set()
    for x,y in frontier:
        for k in range(1,5):
            xx,yy = {1:(x,y-1), 2:(x,y+1), 3:(x-1,y), 4:(x+1,y)}[k]
            if (xx,yy) not in done and grid[(xx,yy)] == 1:
                new.add((xx,yy))
        done.add((x,y))
    frontier = new.copy()
    if frontier:
        step += 1