import strutils
import sequtils
import tables
import sets
import ../10/aoc2017_10

var A = 289
var B = 629

var s = 0

for k in 0 ..< 5000000:
    A = (A * 16807) mod 2147483647
    while (A mod 4) != 0:
        A = (A * 16807) mod 2147483647
    B = (B * 48271) mod 2147483647
    while (B mod 8) != 0:
        B = (B * 48271) mod 2147483647
    if (A and 0xffff) == (B and 0xffff):
        s += 1

echo s