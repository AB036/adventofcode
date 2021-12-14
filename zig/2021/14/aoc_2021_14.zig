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

const Node = struct {name: u8, next: ?*Node};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var node_0 = Node {.name = '0', .next = null};
    var prev = &node_0;
    for (lines[0]) |letter| {
        const ptr = try allocator.create(Node);
        ptr.* = Node {.name = letter, .next = null};
        prev.next = ptr;
        prev = ptr;
    }

    var rules = std.AutoHashMap([2]u8, u8).init(allocator);
    var rule_list = std.ArrayList([3]u8).init(allocator);
    for (lines[1..]) |line| {
        try rules.put(.{line[0], line[1]}, line[6]);
        try rule_list.append(.{line[0], line[1], line[6]});
    }
    
    var step: u32 = 0;
    while (step < 10) : (step += 1) {
        var node_a = node_0.next.?;
        while (true) {
            var node_b = node_a.next orelse break;
            if (rules.contains(.{node_a.name, node_b.name})) {
                const ptr = try allocator.create(Node);
                ptr.* = Node {.name = rules.get(.{node_a.name, node_b.name}).?, .next = node_b};
                node_a.next = ptr;
            }
            node_a = node_b;
        }
    }
    var count = [_]u64{0} ** 26;
    var x = &node_0;
    while (true) {
        x = x.next orelse break;
        count[x.name - 'A'] += 1;
    }
    
    var maxi: u64 = std.mem.max(u64, count[0..]);
    var mini: u64 = maxi;
    for (count) |c| { if (c != 0 and c < mini) {mini = c;}}
    
    print("Part 1: {} - {} = {}\n", .{maxi, mini, maxi-mini});
    
    // ===========================================================================================
    
    var map = std.AutoHashMap([2]u8, u64).init(allocator);
    var k: usize = 0;
    while (k < lines[0].len - 1) : (k += 1) {
        const n_pairs = map.get(.{lines[0][k], lines[0][k+1]}) orelse 0;
        try map.put(.{lines[0][k], lines[0][k+1]}, n_pairs + 1);
    }
    
    step = 0;
    while (step < 40) : (step += 1) {
        
        var new_map = try map.clone();
        
        for (rule_list.items) |rule| {
            const n_pairs = map.get(.{rule[0], rule[1]}) orelse continue;
            const count_old = new_map.get(.{rule[0], rule[1]}) orelse 0;
            try new_map.put(.{rule[0], rule[1]}, count_old - n_pairs);
            
            const count_a = new_map.get(.{rule[0], rule[2]}) orelse 0;
            try new_map.put(.{rule[0], rule[2]}, count_a + n_pairs);
            
            const count_b = new_map.get(.{rule[2], rule[1]}) orelse 0;
            try new_map.put(.{rule[2], rule[1]}, count_b + n_pairs);
        }
        
        map = new_map;
    }
    
    var count_letter = [_]u64{0} ** 26;
    var ite = map.iterator();
    while (ite.next()) |kv| {
        count_letter[kv.key_ptr[0] - 'A'] += kv.value_ptr.*;
    }
    count_letter[lines[0][lines[0].len-1] - 'A'] += 1;
    
    var max: u64 = std.mem.max(u64, count_letter[0..]);
    var min: u64 = max;
    for (count_letter) |c| { if (c != 0 and c < min) {min = c;}}
    print("Part 2: {} - {} = {}\n", .{max, min, max - min});
}


