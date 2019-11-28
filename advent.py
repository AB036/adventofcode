#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import string
import hashlib
import collections
import copy
import math

abc = string.ascii_lowercase
ABC = string.ascii_uppercase


def get_input(lines = False):
    with open("input.txt", "r") as f:
        text = f.read().strip()
    if lines:
        return text.splitlines()
    else:
        return text

def get_ex(lines = False):
    with open("example.txt", "r") as f:
        text = f.read().strip()
    if lines:
        return text.splitlines()
    else:
        return text
       
def get_numbers(arg):
    if type(arg) == str:
        line = arg.replace(',', ' ')
        for char in string.punctuation.replace('-', '') + abc + ABC:
            line = line.replace(char, ' ')
        return tuple( int(e) for e in line.split(' ') if e)
    elif type(arg) == list:
        return [get_numbers(line) for line in arg]

def minsmaxs(numbers):
    n = len(numbers[0])
    minis = tuple(min(e[k] for e in numbers) for k in range(n))
    maxis = tuple(max(e[k] for e in numbers) for k in range(n))
    return minis, maxis

def repartition(n_items, total):
    if n_items == 1:
        yield (total,)
    else:
        for k in range(total+1):
            g = repartition(n_items-1, total - k)
            for r in g:
                yield (k,) + r
                
def md5(s):
    m = hashlib.md5()
    m.update(s.encode('utf-8'))
    return m.hexdigest()

def next_letter(letter):
    if letter in abc:
        return abc[(abc.index(letter)+1)%26]
    if letter in ABC:
        return ABC[(ABC.index(letter)+1)%26]
    raise ValueError("not a letter: " + str(letter))
    
def list_to_str(l):
    s = ""
    for e in l:
        s += e
    return s

def defdict(default = 0):
    return collections.defaultdict(lambda : copy.copy(default))

def neighbours(x,y):
    return ((x+1,y), (x-1,y), (x,y+1), (x,y-1), (x+1,y+1), (x-1,y-1), (x+1,y-1), (x-1,y+1))

def prod(se):
    p = 1
    for e in se:
        p *= e
    return p