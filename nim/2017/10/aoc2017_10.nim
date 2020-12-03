import strutils
import sets

proc get_input(): seq[string] =
    let file_str = strip(read_file("input.txt"))
    return split_lines(file_str)

proc knot_hash*(input: string): string =
    var lengths = new_seq[int](0)
    for c in input:
        lengths.add(int(c))

    lengths = lengths & @[17, 31, 73, 47, 23]

    let n = 256
    var L = new_seq[uint8](256)
    for i in 0 .. n-1:
        L[i] = uint8(i)

    var skip_size = 0
    var i = 0

    for round in 0 .. 63:
        for length in lengths:
            for k in 0 .. (length-1) div 2:
                let tmp = L[(i + k) mod n]
                L[(i + k) mod n] = L[(i + length - 1 - k) mod n]
                L[(i + length - 1 - k) mod n] = tmp
            i = (i + length + skip_size) mod n
            skip_size += 1  

    var dense_hash = new_seq[uint8](16)
    for k in 0 .. 15:
        for kk in 0 .. 15:
            dense_hash[k] = dense_hash[k] xor L[16*k + kk]

    var s = ""
    for h in dense_hash:
        s = s & to_hex(h)

    return s.to_lower()

when is_main_module:
    let arg = get_input()[0]
    echo knot_hash(arg)