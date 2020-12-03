import strutils
import sets

proc get_input*(): seq[string] =
    let file_str = strip(read_file("input.txt"), chars = {'\n'})
    return split_lines(file_str)

proc max[T](S: HashSet[T]): T =
    var m = low(T)
    for item in S:
        if item > m:
            m = item
    return m
    
let abc* = "abcdefghijklmnopqrstuvwxyz"
let ABC* = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"