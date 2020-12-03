#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 25 14:13:42 2019

@author: armand
"""


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



def day1():
    arg = get_input()
    nu = get_numbers(arg)
    print(sum((e//3)-2 for e in nu))
    
    s = 0
    for n in nu:
        f = n//3 - 2
        while f > 0:
            s += f
            f = (f//3) - 2
    
    print(s)
        

def op_add(regs, k):
    a,b,c = regs[k], regs[k+1], regs[k+2]
    regs[c] = regs[a] + regs[b]
    
def op_mul(regs, k):
    a,b,c = regs[k], regs[k+1], regs[k+2]
    regs[c] = regs[a] * regs[b]
    

def day2():
    arg = get_input()
    num = get_numbers(arg)
    n = len(num)
    
    for aaa in range(100):
        for bbb in range(100):
            op = list(num)
            op[1] = aaa
            op[2] = bbb
            
            k = 0
            while 0 <= k <= n-1:
                if op[k] == 1:
                    op_add(op, k+1)
                    k += 4
                elif op[k] == 2:
                    op_mul(op, k+1)
                    k += 4
                elif op[k] == 99:
                    break
            
            if op[0] == 19690720:
                print(100 * aaa + bbb)



def day3():
    arg = get_input()
    seen = set()
    time = dict()
    x,y = 0,0
    l = arg.split(',')
    t = 0
    dirs = {'U':(0,-1), 'D':(0,1), 'L':(-1,0), 'R':(1,0)}
    for aaa in l:
        direct, dist = aaa[0], int(aaa[1:])
        dx,dy = dirs[direct]
        for k in range(dist):
            x += dx
            y += dy
            seen.add((x,y))
            t += 1
            if (x,y) not in time:
                time[(x,y)] = t
                
    arg2 = get_ex()
    seen2 = set()
    time2 = dict()
    x,y = 0,0
    l2 = arg2.split(',')
    t = 0
    for aaa in l2:
        direct, dist = aaa[0], int(aaa[1:])
        dx,dy = dirs[direct]
        for k in range(dist):
            x += dx
            y += dy
            seen2.add((x,y))
            t += 1
            if (x,y) not in time2:
                time2[(x,y)] = t
                
    both = seen & seen2
    best = min(both, key = lambda e: abs(e[0])+abs(e[1]))
    print(abs(best[0]) + abs(best[1]))
    best2 = min(both, key = lambda e: time[e] + time2[e])
    print(time[best2] + time2[best2])
        


def day4():
    arg = 206938
    arg2 = 679128
    
    s = 0
    
    for p in range(arg, arg2+1):
        ss = str(p)
        double = False
        inc = True
        for k in range(5):
            if ss[k] == ss[k+1] and ss.count(ss[k]) == 2:
                double = True
            if int(ss[k]) > int(ss[k+1]):
                inc = False
        if double and inc:
            s += 1
    print(s)
    


    

arg = get_input()
num = get_numbers(arg)
n = len(num)

op = list(num)

k = 0
while 0 <= k <= n-1:
    ope = str(op[k]).zfill(5)
    opcode = int(ope[-2:])
    ia, ib, ic = int(ope[2]), int(ope[1]), int(ope[0])
    if opcode == 1:
        a,b,c = op[k+1], op[k+2], op[k+3]
        aa = a if ia else op[a]
        bb = b if ib else op[b]
        op[c] = aa + bb
        k += 4
    elif opcode == 2:
        a,b,c = op[k+1], op[k+2], op[k+3]
        aa = a if ia else op[a]
        bb = b if ib else op[b]
        op[c] = aa * bb
        k += 4
    elif opcode == 3:
        a = op[k+1]
        op[a] = 5
        k += 2
    elif opcode == 4:
        a = op[k+1]
        print(op[a])
        k += 2
    elif opcode == 5:
        a,b = op[k+1], op[k+2]
        aa = a if ia else op[a]
        bb = b if ib else op[b]
        if aa:
            k = bb
        else:
            k += 3
    elif opcode == 6:
        a,b = op[k+1], op[k+2]
        aa = a if ia else op[a]
        bb = b if ib else op[b]
        if aa == 0:
            k = bb
        else:
            k += 3
    elif opcode == 7:
        a,b,c = op[k+1], op[k+2], op[k+3]
        aa = a if ia else op[a]
        bb = b if ib else op[b]
        op[c] = 1 if aa < bb else 0
        k += 4
    elif opcode == 8:
        a,b,c = op[k+1], op[k+2], op[k+3]
        aa = a if ia else op[a]
        bb = b if ib else op[b]
        op[c] = 1 if aa == bb else 0
        k += 4
    elif opcode == 99:
        break












