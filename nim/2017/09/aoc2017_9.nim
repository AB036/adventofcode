import strutils
import sets

proc get_input(): seq[string] =
    let file_str = strip(read_file("input.txt"))
    return split_lines(file_str)

let arg = get_input()[0]
var total_score = 0
var local_score = 0

let n = len(arg)
var i = 0

var garbage = false
var total_garbage = 0

while i < n:
    let c = arg[i]
    if c == '!':
        i += 2
        continue
    if garbage:
        garbage = c != '>'
        if garbage:
            total_garbage += 1
    elif c == '<':
        garbage = true
    elif c == '{':
        local_score += 1
    elif c == '}':
        total_score += local_score
        local_score -= 1
    i += 1

echo total_score
echo total_garbage