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


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var list = std.ArrayList(u32).init(allocator);
    for (lines) |line| {
        var value = try std.fmt.parseInt(u32, line, 2);
        try list.append(value);
    }
    
    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    
    var shifted: u32 = @intCast(u32, 1) << @truncate(u5, lines[0].len - 1);
    while (shifted > 0) : (shifted = shifted >> @intCast(u32, 1)) {
        var sum_zero: u32 = 0;
        var sum_one: u32 = 0;
        for (list.items) |number| {
            if (number & shifted != 0) {sum_one += 1;} else {sum_zero += 1;}
        }
        
        if (sum_one >= sum_zero) {gamma += shifted;} else {epsilon += shifted;}
    }
    print("Part 1: {}\n", .{gamma * epsilon});
    
    var oxygen: u32 = 0;  var c02: u32 = 0;
    var oxy_stop = false; var co2_stop = false;
    
    var shift: u5 = @truncate(u5, lines[0].len - 1);
    while (true) {
        var oxy_zero: u32 = 0; var oxy_one: u32 = 0;
        var c02_zero: u32 = 0; var c02_one: u32 = 0;
        const ss = @intCast(u32, 1) << shift;
        var oxy_possible: u32 = 0;
        var c02_possible: u32 = 0;
        for (list.items) |number| {
            if (number >> (shift+1) == oxygen >> (shift+1)) {
                oxy_possible = number;
                if (number & ss != 0) {oxy_one += 1;} else {oxy_zero += 1;}
            }
            if (number >> (shift+1) == c02 >> (shift+1)) {
                c02_possible = number;
                if (number & ss != 0) {c02_one += 1;} else {c02_zero += 1;}
            }
        }
        
        if (oxy_one + oxy_zero == 1) {oxy_stop = true; oxygen = oxy_possible;}
        if (c02_one + c02_zero == 1) {co2_stop = true; c02 = c02_possible;}
        
        if (!oxy_stop and (oxy_one >= oxy_zero)) {oxygen += ss;}
        if (!co2_stop and (c02_one < c02_zero)) {c02 += ss;}
        //print("oxy: {b}  c02: {b}\n", .{oxygen, c02});
        
        if (shift == 0) {break;}
        shift -= 1;
    }
    print("Part 2: {}\n", .{oxygen * c02});
}


