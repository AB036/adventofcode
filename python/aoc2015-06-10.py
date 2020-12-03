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

def day6():
    arg = get_input(1)
    num = get_numbers(arg)
    L = [[0 for j in range(1000)] for i in range(1000)]
    
    for k,line in enumerate(arg):
        lll = line.split(' ')
        x,y,xx,yy = num[k]
        
        for i in range(x,xx+1):
            for j in range(y,yy+1):
                if lll[0] == 'toggle':
                    L[i][j] += 2
                elif lll[1] == 'on':
                    L[i][j] += 1
                else:
                    L[i][j] = max(L[i][j]-1,0)
        
    print(sum([sum(l) for l in L]))
    
    
def day7():
    arg = get_input(1)
    G = dict()
    regs = dict()
    regs['b'] = 956
    for line in arg:
        l = line.split(' -> ')
        G[l[-1]] = l[0]
        
    def find(reg):
        try:
            return int(reg)
        except:
            pass
        
        if reg in regs:
            return regs[reg]
        
        op = G[reg].split(' ')
        if len(op) == 1:
            try:
                out = int(op[0])
            except:
                out = find(op[0])
        elif op[0] == "NOT":
            out = find(op[1]) ^ 65535
        elif op[1] == "AND":
            out = find(op[0]) & find(op[2])
        elif op[1] == "OR":
            out = find(op[0]) | find(op[2])
        elif op[1] == "LSHIFT":
            out = find(op[0]) << int(op[2])
        elif op[1] == "RSHIFT":
            out = find(op[0]) >> int(op[2])
        
        regs[reg] = out
        return out
    
    print(find('a'))
    
def day8a():
    arg = get_input(1)
    lens = 0
    s = 0
    for line in arg:
        lens += len(line)
        l = line[1:-1]
        k = 0
        while k < len(l):
            if l[k] == "\\":
                if l[k+1] == "\\":
                    s += 1
                    k += 2
                elif l[k+1] == '"':
                    s += 1
                    k += 2
                elif l[k+1] == "x":
                    s += 1
                    k += 4
            else:
                s += 1
                k += 1
    print(lens-s)
    
def day8b():
    arg = get_input(1)
    lens = 0
    s = 0
    for line in arg:
        s += 2
        lens += len(line)
        l = line
        k = 0
        while k < len(l):
            if l[k] == "\\":
                s += 2
            elif l[k] == '"':
                s += 2
            else:
                s += 1
            k += 1
    print(s-lens)

#travelling salesman
#voyageur de commerce
def day9():
    arg = get_input(1)
    g = dict()
    for line in arg:
        l = line.split(' ')
        t1,t2,d = l[0],l[2],int(l[4])
        
        if t1 not in g:
            g[t1] = dict()
        if t2 not in g:
            g[t2] = dict()
            
        g[t1][t2] = d
        g[t2][t1] = d
        
    queue = [[0,aaa] for aaa in g]
    #best = 99999999999999
    best = 0
    
    while queue:
        curr = queue.pop(0)
        for aaa in g:
            if aaa not in curr:
                new = copy.copy(curr)
                new[0] += g[curr[-1]][aaa]
                new.append(aaa)
                queue.append(new)
        if len(curr) == len(g) +1:
            if curr[0] > best:
                best = curr[0]
                print(best)
                
def day10():
    arg = 1113222113
    s = str(arg)
    
    for k in range(50):
        ss = ""
        i = 0
        while i < len(s):
            char = s[i]
            n = 1
            while (i+n) < len(s) and s[i+n] == char:
                n += 1
            ss += str(n) + char
            i += n
        
        s = ss