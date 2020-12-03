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


def day6():
    arg = get_input(1)
    
    d = dict()
    for line in arg:
        l = line.split(')')
        a,b = l[0], l[1]
        d[b] = a
    
    s = 0
    for key in d:
        a = key
        while a in d:
            s += 1
            a = d[a]
    print(s)
    
    you = dict()
    p = "YOU"
    s = 0
    while p != "COM":
        p = d[p]
        you[p] = s
        s += 1
    
    s = 0
    p = "SAN"
    while p not in you:
        p = d[p]
        s += 1
        
    print(you[p] + s - 1)



def day7():
    import intcode
    
    arg = get_input()
    num = get_numbers(arg)
    n = len(num)
    
    pro = [intcode.process(num) for k in range(5)]
    
    for k in range(4):
        pro[k].out(pro[k+1])
    
    pro[4].out(pro[0])
    output_last = list()
    pro[4].out(output_last)
        
    s = set()
    
    for perm in itertools.permutations((0,1,2,3,4)):
        for k in range(5):
            pro[k].reset()
            pro[k].feed(perm[k]+5)
        pro[0].feed(0)
        
        alive = True
        while alive:
            for k in range(5):
                pro[k].run_until_stop()
            
            alive = False
            for k in range(5):
                alive = alive or pro[k].alive
        
        s.add(output_last[-1])
    
    print(max(s))



def day8():
    arg = get_input()
    n = len(arg)
    w = 25
    h = 6
    
    layers = list()
    
    k = 0
    while k < n:
        layers.append( [int(e) for e in arg[k : k+w*h]] )
        k += w*h
        
    best = min(layers, key = lambda l: l.count(0))
    print(best.count(1) * best.count(2))
    
    
    image = []
    image2 = np.zeros((h,w))
    
    for i in range(w*h):
        k = 0
        while layers[k][i] == 2:
            k += 1
        image.append(layers[k][i])
    
    for hh in range(h):
        image2[hh] = image[hh*w:(hh+1)*w]
    
    for k in range(h):
        a = str()
        for cc in image[k*w:(k+1)*w]:
            if cc:
                a += '*'
            else:
                a += ' '
        print(a)
        
def day9():
    import intcode
        
    arg = get_input()
    
    num = get_numbers(arg)
    n = len(num)
    
    pro = intcode.process(num)
    pro.feed(2)
    pro.run_until_stop()
    


arg = get_input(1)
ast = set()

y = 0
for line in arg:
    x = 0
    for char in line:
        if char == "#":
            ast.add((x,y))
        x += 1
    y += 1
    
def pgcd(a,b):
    a,b = abs(a),abs(b)
    if b > a:
        return pgcd(b,a)
    if b == 0:
        return a
    return pgcd(b, a%b)

def can_see(a, asteroids):
    x1,y1 = a
    d = dict()
    for (x2,y2) in asteroids:
        if (x1,y1) == (x2,y2):
            continue
        p = pgcd(x1-x2, y1-y2)
        dx, dy = (x2-x1)//p, (y2-y1)//p # "direction"
        if (dx,dy) not in d:
            d[(dx,dy)] = (x2,y2)
        else:
            x3,y3 = d[(dx,dy)]
            # replace the point if there's a closer one in the same direction
            if abs(x2-x1) + abs(y2-y1) < abs(x3-x1) + abs(y3-y1):
                d[(dx,dy)] = (x2,y2)
    return set(d.values())

number_seen = dict()
for a in ast:
    number_seen[a] = len(can_see(a, ast))

best = max(number_seen, key = lambda e: number_seen[e])
print(best, number_seen[best])


def angle_sort(x,y):
    # the function increases as you rotate clockwise
    # minimum is directly on top
    a = math.atan2(x,-y)
    if a < 0:
        a += 2*math.pi
    return a
    

destroyed = set()
d = dict()
k = 1

while len(destroyed) != len(ast) - 1:
    can_destroy = can_see(best, ast-destroyed)
    s = sorted(can_destroy, key = lambda e: angle_sort(e[0]-best[0], e[1]-best[1]))
    for x,y in s:
        destroyed.add((x,y))
        d[k] = (x,y)
        #print(k, "\t", (x,y))
        k += 1
    #print("-------------------")
    
print(d[200])
