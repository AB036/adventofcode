#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from advent import *
import queue

"""

import intcode

arg = get_input()
num = get_numbers(arg)
n = len(num)

op = list(num)
out = list()

inn = lambda : 5
outt = lambda e: out.append(e)

pro = intcode.process(op, inn, outt)

while pro.alive:
    pro.step()

"""

class process:
    process_number = 0
    
    def __init__(self, intcode, input_func = None, output_func = None, printt = True):
        self.name = "Process" + str(process.process_number).zfill(3)
        process.process_number += 1
        self.printt = printt
        
        self.op = intcode
        self.regs = defdict(0)
        for k,o in enumerate(self.op):
            self.regs[k] = o
        
        self.fifo = fifo()
        self.input_func = input_func
        self.output_func = output_func
        self.output_containers = []
        
        self.k = 0
        self.n = len(self.regs)
        self.rel_base = 0
        
        self.alive = True
        self.waiting = False
        
    def __input(self):
        if self.fifo.empty():
            self.waiting = True
            return 0
        self.waiting = False
        v = self.fifo.get_nowait()
        if self.input_func:
            self.input_func(v)
        return v
    
    def __output(self, value):
        if self.printt:
            print(self.name + ":", value)
        if self.output_func:
            self.output_func(value)
        for container in self.output_containers:
            if type(container) == list:
                container.append(value)
            elif type(container) == tuple:
                container += (value,)
            elif type(container) == set:
                container.add(value)
            elif type(container) == queue.Queue:
                container.put(value)
            elif type(container) == process:
                container.feed(value)
        
    def __stop(self):
        self.alive = False
        
    def feed(self, v):
        self.fifo.put(v)
        
    def out(self, c):
        self.output_containers.append(c)
    
    def reset(self):
        self.regs = defdict(0)
        for k,o in enumerate(self.op):
            self.regs[k] = o
        self.alive = True
        self.waiting = False
        self.k = 0
        self.fifo = fifo()
    
    def run_until_stop(self):
        self.step()
        while self.alive and not self.waiting:
            self.step()
    
    def step(self):
        k = self.k
        regs = self.regs
        
        
        opcode = regs[k]%100
        imm1 = (regs[k]//100)%10
        imm2 = (regs[k]//1000)%10
        imm3 = (regs[k]//10000)%10
        
        # ADD
        if opcode == 1:
            arg1, arg2, arg3 = regs[k+1], regs[k+2], regs[k+3]
            aa = arg1 if imm1 == 1 else regs[arg1] if imm1 == 0 else regs[arg1+self.rel_base]
            bb = arg2 if imm2 == 1 else regs[arg2] if imm2 == 0 else regs[arg2+self.rel_base]
            if imm3 == 0:
                regs[arg3] = aa + bb
            elif imm3 == 2:
                regs[arg3  + self.rel_base] = aa + bb
            k += 4
            
        # MUL
        elif opcode == 2:
            arg1, arg2, arg3 = regs[k+1], regs[k+2], regs[k+3]
            aa = arg1 if imm1 == 1 else regs[arg1] if imm1 == 0 else regs[arg1+self.rel_base]
            bb = arg2 if imm2 == 1 else regs[arg2] if imm2 == 0 else regs[arg2+self.rel_base]
            if imm3 == 0:
                regs[arg3] = aa * bb
            elif imm3 == 2:
                regs[arg3  + self.rel_base] = aa * bb
            k += 4
        
        # INPUT
        elif opcode == 3:
            arg1 = regs[k+1]
            v = self.__input()
            if not self.waiting:
                if imm1 == 0:
                    regs[arg1] = v
                elif imm1 == 2 :
                    regs[arg1+self.rel_base] = v
                k += 2
            
        # OUTPUT
        elif opcode == 4:
            arg1 = regs[k+1]
            if imm1 == 0:
                self.__output(regs[arg1])
            elif imm1 == 1:
                self.__output(arg1)
            elif imm1 == 2:
                self.__output(regs[arg1+self.rel_base])
            k += 2
            
        # JUMP IF TRUE
        elif opcode == 5:
            arg1, arg2 = regs[k+1], regs[k+2]
            aa = arg1 if imm1 == 1 else regs[arg1] if imm1 == 0 else regs[arg1+self.rel_base]
            bb = arg2 if imm2 == 1 else regs[arg2] if imm2 == 0 else regs[arg2+self.rel_base]
            k = bb if aa else k+3
        
        # JUMP IF FALSE
        elif opcode == 6:
            arg1, arg2 = regs[k+1], regs[k+2]
            aa = arg1 if imm1 == 1 else regs[arg1] if imm1 == 0 else regs[arg1+self.rel_base]
            bb = arg2 if imm2 == 1 else regs[arg2] if imm2 == 0 else regs[arg2+self.rel_base]
            k = bb if aa == 0 else k+3
        
        # LESS THAN
        elif opcode == 7:
            arg1, arg2, arg3 = regs[k+1], regs[k+2], regs[k+3]
            aa = arg1 if imm1 == 1 else regs[arg1] if imm1 == 0 else regs[arg1+self.rel_base]
            bb = arg2 if imm2 == 1 else regs[arg2] if imm2 == 0 else regs[arg2+self.rel_base]
            if imm3 == 0:
                regs[arg3] = 1 if aa < bb else 0
            elif imm3 == 2:
                regs[arg3 + self.rel_base] = 1 if aa < bb else 0
            k += 4
        
        # EQUAL
        elif opcode == 8:
            arg1, arg2, arg3 = regs[k+1], regs[k+2], regs[k+3]
            aa = arg1 if imm1 == 1 else regs[arg1] if imm1 == 0 else regs[arg1+self.rel_base]
            bb = arg2 if imm2 == 1 else regs[arg2] if imm2 == 0 else regs[arg2+self.rel_base]
            if imm3 == 0:
                regs[arg3] = 1 if aa == bb else 0
            elif imm3 == 2:
                regs[arg3 + self.rel_base] = 1 if aa == bb else 0
            k += 4
        
        # BASE OFFSET
        elif opcode == 9:
            arg1 = regs[k+1]
            if imm1 == 0:
                self.rel_base += regs[arg1]
            elif imm1 == 1:
                self.rel_base += arg1
            elif imm1 == 2:
                self.rel_base += regs[arg1 + self.rel_base]
            k += 2
        
        
        # STOP
        elif opcode == 99:
            self.__stop()
        
        
        else:
            raise ValueError("Unknown opcode: " + str(opcode))
        
        self.k = k