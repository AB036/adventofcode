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

def day16a():
    arg = get_input()
    num = tuple(int(c) for c in arg)
    n = len(num)
    
    iin = list(num)
    pattern = (0,1,0,-1)
    for aaa in range(100):
        #print(aaa)
        out = []
        n = len(iin)
        for i in range(n):
            a = 0
            length_pattern = 4*(i+1)
            mod = n%length_pattern
            
            for j in range(i, n, length_pattern):
                a += sum(iin[j:j+i+1])
            
            for j in range(i + 2*(i+1), n, length_pattern):
                a -= sum(iin[j:j+i+1])
                
            out.append(abs(a)%10)
        iin = out.copy()
    
    s = ""
    for e in out[:8]:
        s += str(e)
    print(s)

def day16b():
    arg = get_input()
    num = tuple(int(c) for c in arg)
    n = len(num)
    
    offset = int(arg[:7])
    if offset < 5000 * len(arg):
        raise ValueError("Can't do it")
        
    
    x = list((10000*num)[offset:])
    for phase in range(100):
        cumm = 0
        for i in range(10000*n - offset - 1, -1, -1):
            cumm += x[i]
            x[i] = cumm%10
    
    print(''.join(str(e) for e in x[:8]))



def day17():
    arg = get_input()
    num = get_numbers(arg)
    
    
    import intcode
    pro = intcode.process(num, printt=False)
    f = fifo()
    pro.out(f)
    pro.run_until_stop()
    
    grid = dict()
    x,y = 0,0
    xr,yr = 0,0
    d = ""
    
    while not f.empty():
        c = f.get_nowait()
        if c in (35, 46):
            grid[(x,y)] = chr(c)
        elif c in (60,62,94,118):
            xr,yr = x,y
            d = {60:"l", 62:"r", 94:"u", 118:"d"}[c]
            grid[(x,y)] = '#'
        x,y = (0,y+1) if c == 10 else (x+1,y)
          
    s = 0
    for a,c in grid.items():
        x,y = a
        if c == "#":
            ok = True
            for xx,yy in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
                if not ((xx,yy) in grid and grid[(xx,yy)] == '#'):
                    ok = False
            if ok:
                s += x*y
    print("p1 :", s)
    
    path = []
    x,y = xr,yr
    px,py = -1,-1
    while 1:
        rx,ry = {"r":(x+1,y),"l":(x-1,y),"d":(x,y+1),"u":(x,y-1)}[turn_right(d)]
        lx,ly = {"r":(x+1,y),"l":(x-1,y),"d":(x,y+1),"u":(x,y-1)}[turn_left(d)]
        if (rx,ry) in grid and grid[(rx,ry)] == '#':
            d = turn_right(d)
            pd = "R"
        elif (lx,ly) in grid and grid[(lx,ly)] == '#':
            d = turn_left(d)
            pd = "L"
        else:
            break
        
        pl = 0
        while (x,y) in grid and grid[(x,y)] == '#':
            pl += 1
            px,py = x,y
            x,y = {"r":(x+1,y),"l":(x-1,y),"d":(x,y+1),"u":(x,y-1)}[d]
        x,px = px, px - (x-px)
        y,py = py, py - (y-py)
        path.append(pd + "," + str(pl-1))
    
    n = len(path)
    for sizes in itertools.product(range(2,21), range(2,21), range(2,21)):
        p = ',' + ','.join(path)
        patterns = []
        for k in (0,1,2):
            pattern = p[:sizes[k]]
            patterns.append(pattern)
            p = p.replace(pattern, "")
        if p.replace(',', '') == "":
            print(sizes)
            break
    
    p = ','.join(path)
    for k in range(3):
        patterns[k] = patterns[k][1:]
        p = p.replace(patterns[k], "ABC"[k])
    
    
    pro.reset()
    pro.regs[0] = 2
    
    for line in [p] + patterns + ["n"]:
        for c in line:
            pro.feed(ord(c))
        pro.feed(10)
    
    pro.run_until_stop()
    while not f.empty():
        c = f.get()
        if c > 200:
            print("p2 :", c)


def day18():
    arg = get_input(1)
    grid = dict()
    keys = set()
    xa,ya = -1,-1
    pos = dict()
    
    y = 0
    for line in arg:
        x = 0
        for c in line:
            grid[(x,y)] = c
            if c == "@":
                xa,ya = x,y
            if c in abc:
                keys.add(c)
                pos[c] = (x,y)
            x += 1
        y += 1
    
    pos['0'] = (xa,ya)
    
    #part 2 stuff
    for xx,yy in ((xa+1,ya), (xa-1,ya), (xa,ya+1), (xa,ya-1)):
        grid[(xx,yy)] = "#"
    
    pos['1'] = xa-1,ya-1
    pos['2'] = xa+1,ya-1
    pos['3'] = xa-1,ya+1
    pos['4'] = xa+1,ya+1
    
    reach = dict()
    
    for k in keys | {'1','2','3','4'}: #{'0'}:
        reach[k] = dict()
        f = fifo()
        seen = set()
        xa,ya = pos[k]
        f.put((xa,ya,0,set()))
        while not f.empty():
            x,y,s,doors = f.get()
            seen.add((x,y))
            for xx,yy in ((x+1,y), (x-1,y), (x,y+1), (x,y-1)):
                c = grid[(xx,yy)]
                if c == '#':
                    continue
                if (xx,yy) in seen:
                    continue
                if "A" <= c <= "Z":
                    f.put( (xx, yy, s+1, doors | {c.lower()}) )
                elif c in keys:
                    reach[k][c] = (s+1, frozenset(doors))
                else:
                    f.put( (xx, yy, s+1, doors) )
    
    pq = minq()
    pq.put( (0, "1234", frozenset()) )
    seen = set()
    
    while not pq.empty():
        steps, last, ke = pq.get()
        if (last, ke) in seen:
            continue
        seen.add((last, ke))
        if len(ke) == len(keys):
            print(steps)
            break
        for i in range(4):
            for k2,r in reach[last[i]].items():
                if r[1] <= ke:
                    l = "".join(last[j] if j != i else k2 for j in range(4))
                    pq.put( (steps + r[0], l, frozenset(ke | {k2}) ) )


def day19():
    arg = get_input()
    num = get_numbers(arg)
    
    import intcode
    pro = intcode.process(num, printt=False)
    
    f = fifo()
    pro.out(f)
    
    d = dict()
    
    def fu(x,y):
        if (x,y) in d:
            return d[(x,y)]
        pro.reset()
        pro.feed(x)
        pro.feed(y)
        pro.run_until_output()
        d[(x,y)] = f.get()
        return d[(x,y)]
    
    print( sum( fu(x,y) for x,y in itertools.product(range(50), range(50)) ) )
        
    x = 30
    y = 0
    stop = False
    while not stop:
        while fu(x,y) == 0:
            y += 1
        xx,yy = x-99, y+99
        if fu(x,y) + fu(xx,yy) == 2:
            print(x-99,y, 10000*(x-99)+y)
            stop = True
        x += 1
    



with open("input.txt", "r") as f:
        text = f.read()

arg = text.splitlines()


grid = dict()
portal = defdict([])
letters = dict()

for y,line in enumerate(arg):
    for x,c in enumerate(line):
        if c in "#.":
            grid[(x,y)] = c
        if c in ABC:
            grid[(x,y)] = c
            letters[(x,y)] = c
        x += 1

xm,ym = x,y

for cc, l in letters.items():
    x,y = cc
    for xx,yy in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
        if (xx,yy) in letters:
            if (xx + xx-x, yy + yy-y) in grid:
                if x < xx or y < yy:
                    portal[grid[(x,y)] + grid[(xx,yy)]].append((xx + xx-x, yy + yy-y))
                elif xx < x or yy < y:
                    portal[grid[(xx,yy)] + grid[(x,y)]].append((xx + xx-x, yy + yy-y))

inner = set()
outter = set()
pos = dict()
pos2 = dict()


for po,L in portal.items():
    for k,cc in enumerate(L):
        pos[po + str(k)] = cc
        pos2[cc] = po + str(k)
        x,y = cc
        if 5 <= x <= xm-5 and 5 <= y <= ym-5:
            inner.add(po + str(k))
        else:
            outter.add(po + str(k))

                
xa,ya = portal['AA'][0]
xz,yz = portal['ZZ'][0]

d = dict()
for po in pos:
    d[po] = set()
    xr,yr = pos[po]
    seen = set()
    f = fifo()
    f.put( (0,xr,yr) )
    while not f.empty():
        s,x,y = f.get()
        if (x,y) in pos2 and (x,y) != (xr,yr):
            po2 = pos2[(x,y)]
            d[po].add((po2,s))
        seen.add((x,y))
        for xx,yy in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
            if grid[(xx,yy)] == "." and (xx,yy) not in seen:
                f.put( (s+1, xx, yy))


pq = minq()
seen = set()
pq.put( (0, 0, "AA0") )
stop = False

while not pq.empty() and not stop:
    s, l, po = pq.get()
    if (l,po) in seen:
        continue
    seen.add((l,po))
    if l == 0 and po == "ZZ0":
        print(s)
        break
    for po2, dist in d[po]:
        if po2 in "AA0ZZ0":
            pq.put( (s+dist, l, po2))
            continue
        k = int(po2[-1])
        po3 = po2[:-1] + str( (k+1)%2 )
        if po2 in inner:
            pq.put( (s + dist + 1, l+1, po3))
        elif l > 0:
            pq.put( (s + dist + 1, l-1, po3))


