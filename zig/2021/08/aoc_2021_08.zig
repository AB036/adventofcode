const std = @import("std");

const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    var iterator = std.mem.tokenize(u8, trimmed, "\n");

    var list = std.ArrayList([]const u8).init(allocator);
    while (iterator.next()) |token| {
        try list.append(token);
    }

    return list.toOwnedSlice();
}


pub fn get_one(map: *std.AutoHashMap(u8, void)) u8 {
    var iterator = map.iterator();
    while (iterator.next()) |kv| {
        return kv.key_ptr.*;
    }
    unreachable;
}

pub fn contains(string_a: []const u8, string_b: []const u8) bool {
    var sum: u32 = 0;
    for (string_b) |bbb| {
        for (string_a) |aaa| { if (aaa == bbb) {sum += 1; break;} }
    }
    return sum == string_b.len;
}


pub fn contains_single(a: []const u8, x: u8) bool {
    for (a) |aaa| {if (aaa == x) {return true;}}
    return false;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    //~ var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test2.txt", allocator);
    var lines = try read_lines("8-100000.in", allocator);

    // Children[x] --> numbers that contains x in the 7-segments representation
    var children = std.AutoHashMap(u8, []const u8).init(allocator);
    try children.put(0, ([_]u8{8})[0..]);
    try children.put(1, ([_]u8{0, 3, 4, 7, 8, 9})[0..]);
    try children.put(2, ([_]u8{8})[0..]);
    try children.put(3, ([_]u8{8, 9})[0..]);
    try children.put(4, ([_]u8{8, 9})[0..]);
    try children.put(5, ([_]u8{6, 8, 9})[0..]);
    try children.put(6, ([_]u8{8})[0..]);
    try children.put(7, ([_]u8{0, 3, 8, 9})[0..]);
    try children.put(8, ([_]u8{})[0..]);
    try children.put(9, ([_]u8{8})[0..]);

    var part1: u32 = 0;
    var part2: u32 = 0;
    
    for (lines) |line| {
        var ite = std.mem.split(u8, line, " | ");
        const first_line = ite.next().?;
        const output_line = ite.next().?;
        
        var values = std.StringHashMap(u8).init(allocator);
        var possible = std.StringHashMap(std.AutoHashMap(u8, void)).init(allocator);
        
        var ite3 = std.mem.split(u8, first_line, " ");
        while (ite3.next()) |token| {
            var map = std.AutoHashMap(u8, void).init(allocator);
            switch (token.len) {
                2    => {try map.put(1, undefined);},
                4    => {try map.put(4, undefined);},
                3    => {try map.put(7, undefined);},
                7    => {try map.put(8, undefined);},
                6    => {try map.put(0, undefined); try map.put(6, undefined); try map.put(9, undefined);},
                5    => {try map.put(2, undefined); try map.put(3, undefined); try map.put(5, undefined);},
                else => unreachable,
            }
            try possible.put(token, map);
        }
        
        var k: u8 = 0;
        while (k < 10) : (k += 1) {
            var ite_a = possible.iterator();
            while (ite_a.next()) |aaa| {
                const token_a = aaa.key_ptr.*;
                
                // If there's only one possibility for A
                if (aaa.value_ptr.count() == 1) {
                    const value = get_one(aaa.value_ptr);
                    try values.put(token_a, value); // Remember the value for A
                    
                    var ite_b = possible.iterator();
                    while (ite_b.next()) |bbb| {
                        
                        // Ignore (x,x) tuples
                        if (aaa.key_ptr == bbb.key_ptr) {continue;}
                        
                        _ = bbb.value_ptr.remove(value);
                        
                        // If A contains B
                        if (contains(token_a, bbb.key_ptr.*)) {
                            var to_remove = std.ArrayList(u8).init(allocator);
                            var ite_bb = bbb.value_ptr.keyIterator();
                            while (ite_bb.next()) |possible_for_b| {
                                if (!contains_single(children.get(possible_for_b.*).?, value)){
                                    try to_remove.append(possible_for_b.*);
                                }
                            }
                            for (to_remove.items) |to_rm| {
                                _ = bbb.value_ptr.remove(to_rm);
                            }
                        }
                        
                        // If B contains A
                        else if (contains(bbb.key_ptr.*, token_a)) {
                            var to_remove = std.ArrayList(u8).init(allocator);
                            var ite_bb = bbb.value_ptr.keyIterator();
                            while (ite_bb.next()) |possible_for_b| {
                                if (!contains_single(children.get(value).?, possible_for_b.*)){
                                    try to_remove.append(possible_for_b.*);
                                }
                            }
                            for (to_remove.items) |to_rm| {
                                _ = bbb.value_ptr.remove(to_rm);
                            }
                        }
                    }
                }
            }
        }
        
        var m: u32 = 1000;
        var ite2 = std.mem.split(u8, output_line, " ");
        while (ite2.next()) |token| {
            const lengths: [4]u8 = .{2,4,3,7};
            for (lengths) |length| { if (token.len == length) {part1 += 1;} }
            
            var val_iter = values.iterator();
            while (val_iter.next()) |kv| {
                if (token.len == kv.key_ptr.len and contains(token, kv.key_ptr.*)) {
                    part2 += m * kv.value_ptr.*;
                    break;
                }
            }
            m = m / 10;
        }
    }
    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});

}


