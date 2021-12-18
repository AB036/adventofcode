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


pub fn encode(line: []const u8, numbers: *std.ArrayList(u32), depth: *std.ArrayList(u32)) !void {
    var d: u32 = 0;
    for (line) |c| {
        if (c == '[') {d += 1; continue;}
        if (c == ']') {d -= 1; continue;}
        if (c == ',') {continue;}
        try numbers.append(c-'0');
        try depth.append(d);
    }
}

pub fn explode(numbers: *std.ArrayList(u32), depth: *std.ArrayList(u32)) bool {
    const n = numbers.items.len;
    var i: usize = 0;
    while (i < n-1) : (i += 1) { if (depth.items[i] >= 5) {
        if (i > 0)   {numbers.items[i-1] += numbers.items[i];}
        if (i < n-2) {numbers.items[i+2] += numbers.items[i+1];}
        
        numbers.items[i] = 0;
        depth.items[i] -= 1;
        
        _ = numbers.orderedRemove(i+1);
        _ = depth.orderedRemove(i+1);
        
        return true;
    }}
    return false;
}

pub fn split(numbers: *std.ArrayList(u32), depth: *std.ArrayList(u32)) !bool {
    const n = numbers.items.len;
    var i: usize = 0;
    while (i < n) : (i += 1) { if (numbers.items[i] >= 10) {
        const val = numbers.items[i];
        const left = val / 2;
        const right = (val+1) / 2;
        
        numbers.items[i] = left;
        try numbers.insert(i+1, right);
        
        depth.items[i] += 1;
        try depth.insert(i+1, depth.items[i]);
        
        return true;
    }}
    return false;
}


pub fn magnitude(numbers: *std.ArrayList(u32), depth: *std.ArrayList(u32)) u32 {
    while (numbers.items.len > 1) {
        var i: usize = 0;
        while (i < numbers.items.len - 1) : (i += 1) { if (depth.items[i] == depth.items[i+1]) {
            numbers.items[i] = 3*numbers.items[i] + 2*numbers.items[i+1];
            depth.items[i] -= 1;
            
            _ = numbers.orderedRemove(i+1);
            _ = depth.orderedRemove(i+1);
            
            break;
        }}
    }
    return numbers.items[0];
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test2.txt", allocator);

    var numbers = std.ArrayList(u32).init(allocator);
    var depth = std.ArrayList(u32).init(allocator);

    try encode(lines[0], &numbers, &depth);
    
    //~ print("{any}\n", .{numbers.items});
    //~ print("{any}\n\n", .{depth.items});
    
    for (lines) |line, k| {
        if (k == 0) {continue;}
        try encode(line, &numbers, &depth);
        
        var i: usize = 0;
        while (i < numbers.items.len) : (i += 1) {depth.items[i] += 1;}
        
        while (true) {
            if (explode(&numbers, &depth)) { continue; }
            if (try split(&numbers, &depth)) { continue; }
            break;
        }
    }
    
    const part1 = magnitude(&numbers, &depth);
    print("Part 1: {}\n", .{part1});
    
    var part2: u32 = 0;
    
    var i: usize = 0; while (i < lines.len) : (i += 1) {
    var j: usize = 0; while (j < lines.len) : (j += 1) {
        if (i == j) {continue;}
        
        var numbers2 = std.ArrayList(u32).init(allocator);
        var depth2 = std.ArrayList(u32).init(allocator);
        
        try encode(lines[i], &numbers2, &depth2);
        try encode(lines[j], &numbers2, &depth2);
        var ii: usize = 0;
        while (ii < numbers2.items.len) : (ii += 1) {depth2.items[ii] += 1;}
        
        while (true) {
            if (explode(&numbers2, &depth2)) { continue; }
            if (try split(&numbers2, &depth2)) { continue; }
            break;
        }
        
        const mag = magnitude(&numbers2, &depth2);
        if (mag > part2) { part2 = mag; }
    }}
    
    print("Part 2: {}\n", .{part2});
}


