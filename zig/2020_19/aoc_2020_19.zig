const std = @import("std");
const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.split(trimmed, "\n\n");
    var list = std.ArrayList([]const u8).init(allocator);
    while (iterator.next()) |token| { try list.append(token); }

    return list.toOwnedSlice();
}


const rule = struct {
    items: [][]u16,
    base: []const u8,
};


const AAAAA = error {
    OutOfMemory,
};


pub fn solve(r: u16,
             rules: anytype,
             map: anytype,
             allocator: *std.mem.Allocator)
             AAAAA!std.StringHashMap(void) {
    if (map.contains(r)) { return map.get(r).?; }
    const rr = rules.get(r).?;
    var set = std.StringHashMap(void).init(allocator);

    // Base case: the only pattern is the one written in the rule
    if (rr.base.len > 0) {
        try set.put(rr.base, undefined);
        try map.put(r, set);
        return set;
    }

    for (rr.items) |items| {
        var list = std.ArrayList([]const u8).init(allocator);
        try list.append("");
        for (items) |r2| {
            const set2 = try solve(r2, rules, map, allocator);
            var list2 = std.ArrayList([]const u8).init(allocator);
            var ite2 = set2.iterator();
            while (ite2.next()) |kv| {
                for (list.items) |str| {
                    try list2.append(
                           try std.mem.concat(allocator, u8, &[_][]const u8{str, kv.key})
                        );
                }
            }
            list.deinit();
            list = list2;
        }
        for (list.items) |aaa| { try set.put(aaa, undefined); }
    }

    try map.put(r, set);
    return set;
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var rules = std.AutoHashMap(u16, rule).init(allocator);
    var ite_rules = std.mem.split(lines[0], "\n");
    while (ite_rules.next()) |line| {
        var ite_dotdot = std.mem.split(line, ": ");
        const rule_number = try std.fmt.parseInt(u16, ite_dotdot.next().?, 10);
        const rule_str = ite_dotdot.next().?;
        if (rule_str[0] == '"') { //"
            const r = rule {.items=undefined, .base = rule_str[1 .. rule_str.len -1]};
            try rules.put(rule_number, r);
            continue;
        }

        var ite_space = std.mem.split(rule_str, " ");
        var items = std.ArrayList([]u16).init(allocator);
        var list = std.ArrayList(u16).init(allocator);
        while (ite_space.next()) |token| {
            if (token[0] == '|') {
                try items.append(list.toOwnedSlice());
                continue;
            }
            try list.append(try std.fmt.parseInt(u16, token, 10));
        }
        try items.append(list.toOwnedSlice());
        const r = rule {.items = items.toOwnedSlice(), .base = ""};
        try rules.put(rule_number, r);
    }


    var map = std.AutoHashMap(u16, std.StringHashMap(void)).init(allocator);
    const pat0 = try solve(0, rules, &map, allocator);
    
    var sum: u32 = 0;
    var ite_messages = std.mem.split(lines[1], "\n");
    while (ite_messages.next()) |line| {
        if (pat0.contains(line)) {sum += 1;}
    }
    print("Part 1: {}\n", .{sum});

    // 0: 8 11
    // 8: 42 | 42 8
    // 11: 42 31 | 42 11 31
    // --> a 0 pattern must begin by X+Y 42 and end with Y 31
    const pat42 = try solve(42, rules, &map, allocator);
    const pat31 = try solve(31, rules, &map, allocator);
    
    const len42: usize = pat42.iterator().next().?.key.len;
    const len31: usize = pat31.iterator().next().?.key.len;

    var sum2: u32 = 0;
    ite_messages = std.mem.split(lines[1], "\n");
    while (ite_messages.next()) |line| {
        var i: usize = 0;
        var j: usize = line.len;
        while (i < line.len) : (i += len42) {
            if (!pat42.contains(line[i .. i+len42])) {break;}
        }
        while (j > 0) : (j -= len31) {
            if (!pat31.contains(line[j-len31 .. j])) {break;}
        }
        const n42 = i / len42;
        const n31 = (line.len - j) / len31;
        if ((i==j) and (n31 >= 1) and (n42 >= n31 + 1)) {
            sum2 += 1;
        }
    }
    print("Part 2: {}\n", .{sum2});
}


