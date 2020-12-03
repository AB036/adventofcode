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

def day16():
    arg = get_input(1)
    d = dict()
    
    for line in arg:
        l = line.split(' ')
        aaaa = int(l[1][:-1])
        d[aaaa] = defdict(-1)
        d[aaaa][l[2][:-1]] = int(l[3][:-1])
        d[aaaa][l[4][:-1]] = int(l[5][:-1])
        d[aaaa][l[6][:-1]] = int(l[7])
        
    ttt  = """children: 3
cats: 7
samoyeds: 2
pomeranians: 3
akitas: 0
vizslas: 0
goldfish: 5
trees: 3
cars: 2
perfumes: 1"""
    
    possible = set(range(1,501))
    for line in ttt.splitlines():
        l = line.split(': ')
        item = l[0]
        n = int(l[1])
        to_remove = set()
        for aunt in possible:
            if item in ("cats", "trees"):
                if d[aunt][item] != -1 and d[aunt][item] <= n:
                    to_remove.add(aunt)
            elif item in ("pomeranians", "goldfish"):
                if d[aunt][item] != -1 and d[aunt][item] >= n:
                    to_remove.add(aunt)
            elif d[aunt][item] not in (-1,n):
                to_remove.add(aunt)
        possible = possible - to_remove
    
    print(possible)
    
def day17():
    arg = get_input(1)
    s = list()
    for line in arg:
        s.append(int(line))
    total = 150
    
    res = 0
    best = 9999999999
    n = len(s)
    for k in range(1,n+1):
        for comb in itertools.combinations(s,k):
            if sum(comb) == total:
                best = min(k,best)
                res += 1
    res2 = 0
    for comb in itertools.combinations(s,4):
        if sum(comb) == total:
            res2 += 1
            
def day18():
    arg = get_input(1)
    grid = defdict(0)
    for x in range(100):
        for y in range(100):
            grid[(x,y)] = 1 if arg[y][x] == "#" else 0
    
    for xx,yy in ((0,0), (99,0), (0,99), (99,99)):
        grid[(xx,yy)] = 1
            
    for step in range(100):
        new_grid = defdict(0)
        for x in range(100):
            for y in range(100):
                ne = neighbours(x,y)
                on = sum(grid[(xx,yy)] for xx,yy in ne)
                if grid[(x,y)]:
                    new_grid[(x,y)] = 1 if on in (2,3) else 0
                else:
                    new_grid[(x,y)] = 1 if on == 3 else 0
        grid = copy.deepcopy(new_grid)
        for xx,yy in ((0,0), (99,0), (0,99), (99,99)):
            grid[(xx,yy)] = 1
    
    print(sum(grid.values()))
    
def day19a():
    arg = get_input(1)
    arg2 = "CRnSiRnCaPTiMgYCaPTiRnFArSiThFArCaSiThSiThPBCaCaSiRnSiRnTiTiMgArPBCaPMgYPTiRnFArFArCaSiRnBPMgArPRnCaPTiRnFArCaSiThCaCaFArPBCaCaPTiTiRnFArCaSiRnSiAlYSiThRnFArArCaSiRnBFArCaCaSiRnSiThCaCaCaFYCaPTiBCaSiThCaSiThPMgArSiRnCaPBFYCaCaFArCaCaCaCaSiThCaSiRnPRnFArPBSiThPRnFArSiRnMgArCaFYFArCaSiRnSiAlArTiTiTiTiTiTiTiRnPMgArPTiTiTiBSiRnSiAlArTiTiRnPMgArCaFYBPBPTiRnSiRnMgArSiThCaFArCaSiThFArPRnFArCaSiRnTiBSiThSiRnSiAlYCaFArPRnFArSiThCaFArCaCaSiThCaCaCaSiRnPRnCaFArFYPMgArCaPBCaPBSiRnFYPBCaFArCaSiAl"
    #arg2 = "HOHOHO"
    
    tr = defdict(set())
    for line in arg:
        l = line.split(' => ')
        tr[l[0]].add(l[1])
    
    s = set()
    k = 0
    n = len(arg2)
    
    while k < n:
        if arg2[k] in tr:
            for nnn in tr[arg2[k]]:
                s.add(arg2[:k] + nnn + arg2[k+1:])
        if k < n-1 and arg2[k:k+2] in tr:
            for nnn in tr[arg2[k:k+2]]:
                s.add(arg2[:k] + nnn + arg2[k+2:])
        k += 1
    
    print(len(s))
    
def day19b():
    arg = get_input(1)
    arg2 = "CRnSiRnCaPTiMgYCaPTiRnFArSiThFArCaSiThSiThPBCaCaSiRnSiRnTiTiMgArPBCaPMgYPTiRnFArFArCaSiRnBPMgArPRnCaPTiRnFArCaSiThCaCaFArPBCaCaPTiTiRnFArCaSiRnSiAlYSiThRnFArArCaSiRnBFArCaCaSiRnSiThCaCaCaFYCaPTiBCaSiThCaSiThPMgArSiRnCaPBFYCaCaFArCaCaCaCaSiThCaSiRnPRnFArPBSiThPRnFArSiRnMgArCaFYFArCaSiRnSiAlArTiTiTiTiTiTiTiRnPMgArPTiTiTiBSiRnSiAlArTiTiRnPMgArCaFYBPBPTiRnSiRnMgArSiThCaFArCaSiThFArPRnFArCaSiRnTiBSiThSiRnSiAlYCaFArPRnFArSiThCaFArCaCaSiThCaCaCaSiRnPRnCaFArFYPMgArCaPBCaPBSiRnFYPBCaFArCaSiAl"
    
    #arg2 = "A(B(C,D),E(F,G))"
    
    arg2 = arg2.replace("Rn", "(")
    arg2 = arg2.replace("Y", ",")
    arg2 = arg2.replace("Ar", ")")
    
    n_elements = sum(1 if e.isupper() else 0 for e in arg2)
    
    print(n_elements - arg2.count(',') -1)
    
    
def day19b2():
    arg = get_input(1)
    arg2 = "CRnSiRnCaPTiMgYCaPTiRnFArSiThFArCaSiThSiThPBCaCaSiRnSiRnTiTiMgArPBCaPMgYPTiRnFArFArCaSiRnBPMgArPRnCaPTiRnFArCaSiThCaCaFArPBCaCaPTiTiRnFArCaSiRnSiAlYSiThRnFArArCaSiRnBFArCaCaSiRnSiThCaCaCaFYCaPTiBCaSiThCaSiThPMgArSiRnCaPBFYCaCaFArCaCaCaCaSiThCaSiRnPRnFArPBSiThPRnFArSiRnMgArCaFYFArCaSiRnSiAlArTiTiTiTiTiTiTiRnPMgArPTiTiTiBSiRnSiAlArTiTiRnPMgArCaFYBPBPTiRnSiRnMgArSiThCaFArCaSiThFArPRnFArCaSiRnTiBSiThSiRnSiAlYCaFArPRnFArSiThCaFArCaCaSiThCaCaCaSiRnPRnCaFArFYPMgArCaPBCaPBSiRnFYPBCaFArCaSiAl"
    
    tr = list()
    for line in arg:
        l = line.split(' => ')
        tr.append((l[0],l[1]))
    tr.sort(key=lambda e: -len(e[1]))
        
    part2 = 0
    while arg2 != "e":
        for a,b in tr:
            if b in arg2:
                arg2 = arg2.replace(b,a,1)
                part2 += 1
    print(part2)
    
        
def day20():
    arg = 34000000
    k = 1
    while 1:
        div = set()
        for i in range(1, int(math.sqrt(k))+1):
            if k%i == 0:
                if 50*i >= k:
                    div.add(i)
                if 50*(k//i) >= k:
                    div.add(k//i)
        if 11*sum(div) >= arg:
            print(k)
            break
        k += 1