const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    //const input = [_]u64{0,3,6};
    const input = [_]u64{8,0,17,4,1,12};

    var map = std.AutoHashMap(u64, u64).init(allocator);

    var k: u64 = 0;
    var number: u64 = undefined;
    var is_new: bool = true;
    var last: u64 = undefined;
    while (k < 30000000): (k += 1) {
        if (k < input.len) { number = input[k]; }
        else if (is_new) { number = 0; }
        else { number = k - last - 1; }

        is_new = !map.contains(number);
        if (!is_new) { last = map.get(number).?; }
        try map.put(number, k);
        if (k == 2020 - 1) { print("Part 1: {}\n", .{number}); }
    }
    print("Part 2: {}\n", .{number});
}


