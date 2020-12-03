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
    s = get_input()
    f = 1
    for p,char in enumerate(s):
        if char == '(':
            f += 1
        else:
            f -= 1
        if f == -1:
            print(p)
    
def day2():
    arg = get_input(1)
    numbers = get_numbers(arg)
    s = 0
    r = 0
    for a,b,c in numbers:
        areas = (a*b, b*c, a*c)
        s += 2*sum(areas) + min(areas)
        r += 2*(a+b+c - max((a,b,c))) + a*b*c
    print(s)
    print(r)
    
def day3():
    arg = get_input()
    s = set()
    s.add((0,0))
    x,y = 0,0
    xx,yy = 0,0
    k = 0
    while k < len(arg):
        char = arg[k]
        
        if char == '^':
            i,j = 0,1
        elif char =="v":
            i,j = 0,-1
        elif char == ">":
            i,j = 1,0
        else:
            i,j = -1,0
            
        if k % 2 == 0:
            x += i
            y += j
            s.add((x,y))
        else:
            xx += i
            yy += j
            s.add((xx,yy))
            
        k += 1
    print(len(s))
    

def day4():
    arg = "bgvyzdsv"
    k = 1
    while md5(arg+str(k))[:6] != "000000":
        k += 1
    print(k)
    
def day5a():
    arg = get_input(1)
    s = 0
    for line in arg:
        voyels = 0
        double = 0
        bad = 0
        for i,char in enumerate(line):
            if char in "aeiou":
                voyels += 1
            if i != len(line) -1 and char == line[i+1]:
                double += 1
            if i != len(line)-1 and char + line[i+1] in ("ab","cd","pq","xy"):
                bad += 1
        if voyels >= 3 and double and bad == 0:
            s += 1
    print(s)
    
def day5b():
    arg = get_input(1)
    s = 0
    for line in arg:
        pairs = dict()
        ppp = 0
        tri = 0
        for i,char in enumerate(line):
            if i != len(line) -1:
                p = char + line[i+1]
                if p not in pairs:
                    pairs[p] = i
                elif pairs[p] != i-1:
                    ppp += 1
            if i < len(line) -2:
                if char == line[i+2]:
                    tri += 1
        if tri and ppp:
            s += 1
    print(s)