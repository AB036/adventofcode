const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    const input = "318946572"; //real
    //const input = "389125467"; //test

    var next = std.ArrayList(usize).init(allocator);
    for (input) |_| {try next.append(0);}

    var n: usize = 0;
    var prev: usize = 0;
    for (input) |char| {
        const data = char - '0';
        if (prev != 0) { next.items[prev-1] = data; }
        prev = data;
        n += 1;
    }
    while (n < 1000000) : (n += 1) {
        try next.append(0);
        next.items[prev-1] = n+1;
        prev = n+1;
    }
    var current_cup: u64 = input[0] - '0';
    next.items[prev-1] = current_cup;

    var turn: u32 = 0;
    while (turn < 10000000) : (turn += 1) { 
        const a = next.items[current_cup-1];
        const b = next.items[a-1];
        const c = next.items[b-1];
        const d = next.items[c-1];
        next.items[current_cup-1] = d;

        var dest = current_cup - 1;
        while (dest == a or dest == b or dest == c or dest == 0) {
            if (dest == 0) {dest = n;}
            else {dest = dest - 1;}
        }

        const tmp = next.items[dest-1];
        next.items[dest-1] = a;
        next.items[a-1] = b;
        next.items[b-1] = c;
        next.items[c-1] = tmp;

        current_cup = next.items[current_cup-1];
    }

    const a = next.items[0];
    const b = next.items[a-1];
    print("{} * {} = {}\n", .{a, b, a*b});
}


