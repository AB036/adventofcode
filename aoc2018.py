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


"""          
arg = get_input()

pile = []

n = len(arg)
mini = 999999999999999999


for removed_letter in abc:
    pile = []
    for k in range(n):
        letter = arg[k]
        if letter.lower() == removed_letter.lower():
            continue
        
        if pile == []:
            pile.append(letter)
            continue
        
        if letter.lower() == pile[-1].lower() and ((letter.islower() and pile[-1].isupper()) or (letter.isupper() and pile[-1].islower())):
            pile.pop(-1)
        else:
            pile.append(letter)
    
    if len(pile) < mini:
        mini = len(pile)
    
    mini = min(mini, len(pile))
"""

"""
d = dict()
d[2] = 2
d[(2,2)] = "martin"
d["joel"] = dict()

d["joel"][5] = 89


s = set()
s.add(5)
s.add(6)


for element in s:
    break
"""

arg = get_input(1)

s = 0
seen = list()
stop = False

while not stop:
    for i,line in enumerate(arg):
        s += int(line)
        if s in seen:
            print(s)
            stop = True
            break
        seen.append(s)























