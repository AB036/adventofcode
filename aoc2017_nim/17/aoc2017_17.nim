import strutils
import tables
import ../advent

let arg = 312
    
type
    Node = ref object
        value: int
        next: Node

var zero: Node
new(zero)
zero.value = 0
zero.next = zero

var n = zero
for insert in 1 .. 2017:
    for spin in 0 ..< arg:
        n = n.next
    var nn: Node
    new(nn)
    nn.next = n.next
    nn.value = insert
    n.next = nn
    n = nn

echo n.next.value

var i = 0
var answer = 0
for size in 1 .. 50000000 + 1:
    i = (i + 1 + arg) mod size
    if i == 0:
        answer = size

echo answer







