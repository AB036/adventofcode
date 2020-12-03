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
    arg = get_input(0)
    num = get_numbers(arg.replace('\n', ','))
    print(sum(num))
    
    seen = set()
    a = 0
    i = 0
    n = len(num)
    
    while 1:
        a += num[i]
        if a in seen:
            print(a)
            break
        else:
            i = (i+1)%n
            seen.add(a)

def day2():
    arg = get_input(1)
    twos = 0
    threes = 0
    
    for line in arg:
        for letter in abc:
            if line.count(letter) == 2:
                twos += 1
                break
        for letter in abc:
            if line.count(letter) == 3:
                threes += 1
                break
    
    print(twos*threes)
    
    d = dict()
    for line1 in arg:
        for line2 in arg:
            if line1 != line2:
                diff = 0
                for k in range(len(line1)):
                    if line1[k] != line2[k]:
                        diff += 1
                d[(line1,line2)] = diff
            
    a,b = min(d, key=lambda e: d[e])
    print(a)
    print(b)

def day3():
    arg = get_input(1)
    num = get_numbers(arg)
    
    grid = defdict(0)
    overlap = 0
    
    for nu in num:
        aaaa,x,y,w,h = nu
        for i in range(x, x+w):
            for j in range(y,y+h):
                grid[(i,j)] += 1
    
    for v in grid.values():
        if v >= 2:
            overlap += 1
    
    print(overlap)
    
    for nu in num:
        aaaa,x,y,w,h = nu
        ok = True
        for i in range(x, x+w):
            for j in range(y,y+h):
                if grid[(i,j)] >= 2:
                    ok = False
        if ok:
            print(aaaa)

def day4():
    arg = get_input(1)
    arg.sort()
    
    gu = 0
    d = defdict([])
    
    for line in arg:
        l = line.split('] ')
        ll = l[1].split(' ')
        m = int(l[0][-2:])
        if ll[0] == "Guard":
            gu = int(ll[1][1:])
        else:
            d[gu].append(m)
    
    sleep = dict()
    for g in d:
        sl = 0
        l = d[g]
        n = len(l)
        for k in range(0,n,2):
            m1,m2 = l[k],l[k+1]
            if m1 <= m2:
                sl += m2 - m1 
            else:
                sl += 60 + m2 - m1 
        sleep[g] = sl
        
    bestg = max(sleep, key=lambda e:sleep[e])
    
    sle = [0 for k in range(60)]
    l = d[bestg]
    n = len(l)
    for k in range(0,n,2):
        m1,m2 = l[k],l[k+1]
        while m1 != m2:
            sle[m1] += 1
            m1 = (m1+1)%60
            
    bestm = max(range(60), key=lambda e: sle[e])
    
    print(bestg, bestm, bestg*bestm)
    
    
    all_sleep = defdict([0 for k in range(60)])
    
    for g in d:
        l = d[g]
        n = len(l)
        for k in range(0,n,2):
            m1,m2 = l[k],l[k+1]
            while m1 != m2:
                all_sleep[g][m1] += 1
                m1 = (m1+1)%60
    
    bestg2 = max(all_sleep, key = lambda g: max(all_sleep[g]))
    bestm2 = max(range(60), key = lambda m: all_sleep[bestg2][m])
    print(bestg2, bestm2, bestg2*bestm2)

def day5():
    arg = get_input()
    le = set()
    for letter in abc:
        pile = []
        for i in range(len(arg)):
            char = arg[i]
            if char == letter or char == letter.upper():
                continue
            if i == 0 or len(pile) == 0:
                pile.append(char)
                continue
            if char.lower() == pile[-1].lower() and ((char.islower() and pile[-1].isupper()) or (pile[-1].islower() and char.isupper())):
                pile.pop(-1)
            else:
                pile.append(char)
        le.add(len(pile))
            





























