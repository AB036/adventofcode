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

def day21():
    hp = 103
    dmg = 9
    armor = 2
    boss = [103,9,2]
    golds_win = set()
    golds_lose = set()
    
    weapons = ((8,4),(10,5),(25,6),(40,7),(74,8))
    armors = ((13,1),(31,2),(53,3),(75,4),(102,5),(0,0))
    rings = ((25,1,0),(50,2,0),(100,3,0),(20,0,1),(40,0,2),(80,0,3),(0,0,0),(0,0,0))
    
    for w in weapons:
        for a in armors:
            for r1,r2 in itertools.combinations(rings,2):
                gold = w[0] + a[0] + r1[0] + r2[0]
                atk = w[1] + r1[1] + r2[1]
                de = a[1] + r1[2] + r2[2]
                
                boss = [103,9,2]
                hp = 100
                
                while 1:
                    boss[0] -= max(1, atk-boss[2])
                    if boss[0] <= 0:
                        golds_win.add(gold)
                        break
                    hp -= max(1, boss[1] - de)
                    if hp <= 0:
                        golds_lose.add(gold)
                        break

def day22():
    boss_hp = 71
    boss_dmg = 10
    
    hp = 50
    mana = 500
    
    manas = set()
    
    d = dict()
    d["shield"] = 0
    d["poison"] = 0
    d["rech"] = 0
    queue = [(0,50,500,0,71,d)]
    #queue = [(0,10,250,0,13,d)]
    seen = set()
    
    while queue:
        aze = queue.pop()
        if aze[:-1] + tuple(aze[-1].items()) in seen:
            continue
        seen.add(aze[:-1] + tuple(aze[-1].items()))
        turn,hp,mana,mana_spent,boss_hp, spells = aze
        
        
        if spells["rech"] > 0:
            mana += 101
            spells["rech"] -= 1
        if spells["poison"] > 0:
            boss_hp -= 3
            if boss_hp <= 0:
                manas.add(mana_spent)
                print("poison", mana_spent)
                continue
            spells["poison"] -= 1
        if spells["shield"] > 0:
            armor = 7
            spells["shield"] -= 1
        else:
            armor = 0
    
        if turn == 0:
            hp -= 1
            if hp <= 0:
                continue
            if mana >= 53: #missile
                if boss_hp <= 4:
                    manas.add(mana_spent+53)
                    print("missile", mana_spent+53)
                else:
                    queue.append((1,hp,mana-53,mana_spent+53,boss_hp-4,copy.copy(spells)))
            if mana >= 73: #drain
                if boss_hp <= 2:
                    manas.add(mana_spent+73)
                    print("drain", mana_spent+73)
                else:
                    queue.append((1,hp+2,mana-73,mana_spent+73,boss_hp-2,copy.copy(spells)))
            if mana >= 113 and spells["shield"] == 0: #shield
                dd = copy.deepcopy(spells)
                dd['shield'] = 6
                queue.append((1,hp,mana-113,mana_spent+113,boss_hp,dd))
            if mana >= 173 and spells["poison"] == 0: #poison
                dd = copy.deepcopy(spells)
                dd['poison'] = 6
                queue.append((1,hp,mana-173,mana_spent+173,boss_hp,dd))
            if mana >= 229 and spells["rech"] == 0:
                dd = copy.deepcopy(spells)
                dd['rech'] = 5
                queue.append((1,hp,mana-229,mana_spent+229,boss_hp,dd))
        
        elif turn == 1:
            dmg = max(1, boss_dmg-armor)
            hp -= dmg
            if hp > 0:
                queue.append((0,hp,mana,mana_spent,boss_hp,copy.copy(spells)))
    
    print(min(manas))
            

def day23():
    arg = get_input(1)
    instr = []
    for line in arg:
        l = line.split(' ')
        if len(l) == 3:
            instr.append((l[0], l[1][:-1], int(l[2])))
        elif l[0] == "jmp":
            instr.append(("jmp", int(l[1])))
        else:
            instr.append(tuple(l))
    
    regs = dict()
    regs['a'] = 1
    regs['b'] = 0
    
    n = len(instr)
    i = 0
    
    while i < n:
        ins = instr[i]
        #print(i, arg[i], '\t', regs)
        if 0:#i%20 == 0:
            input()
        if ins[0] == "hlf":
            regs[ins[1]] //= 2
            i += 1
        if ins[0] == "tpl":
            regs[ins[1]] *= 3
            i += 1
        if ins[0] == "inc":
            regs[ins[1]] += 1
            i += 1
        if ins[0] == "jmp":
            i += ins[1]
        if ins[0] == "jie":
            if regs[ins[1]] % 2 == 0:
                i += ins[2]
            else:
                i += 1
        if ins[0] == "jio":
            if regs[ins[1]] == 1:
                i += ins[2]
            else:
                i += 1
                
def prod(se):
    p = 1
    for e in se:
        p *= e
    return p

def day24():
    arg = get_input(1)
    w = set()
    for line in arg:
        w.add(int(line))
        
    goal_w = sum(w) // 4
    n = len(w)
    
    poss = set()
    
    found_one = False
    for le1 in range(1,n+1):
        if found_one:
            break
        for group1 in itertools.combinations(w, le1):
            b = False
            if sum(group1) == goal_w:
                for le2 in range(1,n+1-le1):
                    for group2 in itertools.combinations(w-set(group1),le2):
                        if sum(group2) == goal_w:
                            for le3 in range(1,n+1-le1-le2):
                                for group3 in itertools.combinations(w-set(group1)-set(group2), le3):
                                    if sum(group3) == goal_w:
                                        poss.add(group1)
                                        print(prod(min(poss, key = lambda se: prod(se))))
                                        b = True
                                        found_one = True
                                        break
                            if b:
                                break
                    if b:
                        break
                if b:
                    break
    


row = 2978
column = 3083

code = 20151125
r,c = 1,1

while (r,c) != (row, column):
    if r == 1:
        r,c = c+1,1
    else:
        r,c = r-1,c+1
    code = (code*252533)%33554393