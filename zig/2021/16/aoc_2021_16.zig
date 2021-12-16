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

pub fn get1(buff: []u8, i: usize) u1 {
    return if (buff[i/8] & (@intCast(u8, 1) << @intCast(u3, 7 - i%8)) != 0) 1 else 0;
}

pub fn get(buff: []u8, i: usize, n: u6) u64 {
    var out: u64 = 0;
    var j = i;
    var to_add = @intCast(u64, 1) << (n-1);
    while (j < i + n) : (j += 1) {
        out += get1(buff, j) * to_add;
        to_add = to_add/2;
    }
    return out;
}

pub fn read_literal(i: *usize, buff: []u8) u64 {
    var number: u64 = 0;
    var j = i.*; while (get1(buff, j) == 1) {j += 5;}
    var mult: u64 = std.math.pow(u64, 16, (j-i.*)/5);
    while (i.* != j) : (i.* += 5) { number += mult * get(buff, i.*+1, 4); mult = mult / 16;}
    number += get(buff, i.*+1, 4);
    i.* += 5;
    return number;
}

const Errors = error {
    OutOfMemory,
};

pub fn read_packet(i: *usize, buff: []u8, sum_version: *u64, allocator: *std.mem.Allocator) Errors!u64 {
    const version = get(buff, i.*, 3);  sum_version.* += version;
    i.* += 3;
    const type_id = get(buff, i.*, 3);
    i.* += 3;
    
    if (type_id == 4) { return read_literal(i, buff); }
    else {
        var numbers = std.ArrayList(u64).init(allocator);
        
        const length_type_id = get1(buff, i.*); i.* += 1;
        if (length_type_id == 0) {
            const target = i.* + get(buff, i.*, 15) + 15; i.* += 15;
            while (i.* < target) {
                try numbers.append(try read_packet(i, buff, sum_version, allocator));
            }
        }
        else {
            const n_sub_packet = get(buff, i.*, 11); i.* += 11;
            var k: u64 = 0; while (k < n_sub_packet) : (k += 1) {
                try numbers.append(try read_packet(i, buff, sum_version, allocator));
            }
        }
        
        switch (type_id) {
            0 => {var sum: u64 = 0; for (numbers.items) |aaa| {sum += aaa;} return sum;},
            1 => {var pro: u64 = 1; for (numbers.items) |aaa| {pro *= aaa;} return pro;},
            2 => {return std.mem.min(u64, numbers.items);},
            3 => {return std.mem.max(u64, numbers.items);},
            5 => {return if (numbers.items[0] > numbers.items[1]) 1 else 0;},
            6 => {return if (numbers.items[0] < numbers.items[1]) 1 else 0;},
            7 => {return if (numbers.items[0] == numbers.items[1]) 1 else 0;},
            else => unreachable,
        }
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var line = (try read_lines("input.txt", allocator))[0];
    //~ var line = (try read_lines("test.txt", allocator))[0];
    //~ const line = "9C0141080250320F1802104A08";

    var buff = try allocator.alloc(u8, line.len / 2);
    buff = try std.fmt.hexToBytes(buff, line);
    
    var last: usize = 8*buff.len - 1;
    while (get1(buff, last) == 0) {last -= 1;}

    var i: usize = 0;
    var part1: u64 = 0;
    const part2 = try read_packet(&i, buff, &part1, allocator);
    
    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});

}


