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

def day11():
    arg = "hepxxzaa"#"hepxcrrq"
    p = list(arg)
    
    while 1:
        req1 = False
        for k in range(len(p)-2):
            n = next_letter(p[k])
            nn = next_letter(n)
            if n == p[k+1] and nn == p[k+2] and nn not in 'ab':
                req1 = True
        
        req2 = True
        for char in 'iol':
            if char in p:
                req2 = False
                
        req3 = False
        pairs = set()
        for k in range(len(p)-1):
            if p[k] == p[k+1]:
                pairs.add(k)
        if pairs:
            req3 = max(pairs) - min(pairs) >= 2
        
        if req1 and req2 and req3:
            break
        
        for k in range(len(p)):
            n = next_letter(p[-k-1])
            p[-k-1] = n
            if n != 'a':
                break
    print(list_to_str(p))

def day12a():
    arg = get_input()
    n = get_numbers(arg)
    print(sum(n))
    
def day12b():
    arg = get_input()
    d = eval(arg)
    
    def jsum(obj):
        if type(obj) == int:
            return obj
        if type(obj) == str:
            return 0
        if type(obj) == list:
            return sum(jsum(e) for e in obj)
        if type(obj) == dict:
            if "red" in obj.values():
                return 0
            else:
                return sum(jsum(e) for e in obj.values())
            
    print(jsum(d))
    
def day13():
    arg = get_input(1)
    d = defdict(defdict(0))
    for line in arg:
        l = line.split(' ')
        a = l[0]
        b = l[-1][:-1]
        sign = 1 if l[2] == "gain" else -1
        happy = int(l[3])
        d[a][b] = sign*happy
    
    people = list(d.keys())
    people.append('me')
    n = len(people)
    
    best = -9999999999999
    for aaa in itertools.permutations(people):
        score = 0
        for k in range(n):
            score += d[aaa[k]][aaa[(k+1)%n]]
            score += d[aaa[k]][aaa[(k-1)%n]]
        if score > best:
            best = score
            print(best)

def day14a():
    arg = get_input(1)
    d = dict()
    for line in arg:
        l = line.split(' ')
        deer = l[0]
        speed = int(l[3])
        fly_time = int(l[6])
        rest = int(l[-2])
        d[deer] = (speed, fly_time, rest)
        
    dist = defdict()
    
    for deer in d:
        s,f,r = d[deer]
        t = 0
        while t < 2503:
            fly_time = f if t+f <= 2503 else 2503 - t
            dist[deer] += s*fly_time
            t += fly_time
            t += r
            
def day14b():
    arg = get_input(1)
    d = dict()
    for line in arg:
        l = line.split(' ')
        deer = l[0]
        speed = int(l[3])
        fly_time = int(l[6])
        rest = int(l[-2])
        d[deer] = (speed, fly_time, rest)
    
    dist = defdict(0)
    points = defdict(0)
    
    for t in range(2503):
        for deer in d:
            s,f,r = d[deer]
            if t%(f+r) < f:
                dist[deer] += s
        max_d = max(dist.values())
        for deer in d:
            if dist[deer] == max_d:
                points[deer] += 1
                
def day15():
    arg = get_input(1)
    num = get_numbers(arg)
    
    best = 0
    for rep in repartition(4,100):
        c,d,f,t = 0,0,0,0
        cal = 0
        for k in range(4):
            c += rep[k]*num[k][0]
            d += rep[k]*num[k][1]
            f += rep[k]*num[k][2]
            t += rep[k]*num[k][3]
            cal += rep[k]*num[k][4]
        c = max(c,0)
        d = max(d,0)
        f = max(f,0)
        t = max(t,0)
        score = c*f*d*t
        if cal == 500 and score > best:
            best = score
            print(rep, best)