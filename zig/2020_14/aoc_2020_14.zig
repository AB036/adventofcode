const std = @import("std");

const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.split(trimmed, "\n");
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
    //var lines = try read_lines("test.txt", allocator);

    var mem = std.AutoHashMap(u64, u64).init(allocator);
    var mem2 = std.AutoHashMap(u64, u64).init(allocator);
    var mask_0: u36 = undefined;
    var mask_1:  u36 = undefined;
    var X = std.ArrayList(usize).init(allocator);
    for (lines) |line| {
        var ite = std.mem.split(line, " = ");
        const left_str  = ite.next().?;
        const right_str = ite.next().?;
        if (line[1] == 'a') {
            mask_0 = 0;
            mask_1 = 0;
            X.deinit();
            X = std.ArrayList(usize).init(allocator);
            for (right_str) |char, k| {
                const bit = @intCast(u36,1) << @truncate(u6, 35 - k);
                if (char == '0') { mask_0 |= bit; }
                if (char == '1') { mask_1 |= bit; }
                if (char == 'X') { try X.append(35-k); }
            }
        }
        else {
            const address = try std.fmt.parseInt(u36, left_str[4 .. left_str.len-1], 10);
            const value = try std.fmt.parseInt(u36, right_str, 10);
            try mem.put(address, (value & ~mask_0) | mask_1);

            var addr = address | mask_1;
            const nx: u6 = @truncate(u6, X.items.len);
            var max: u36 = @intCast(u36,1) << nx;
            var brute: u36 = 0;
            while (brute < max) : (brute += 1) {
                var k: u6 = 0;
                while (k < nx) : (k += 1) {
                    const bit = @intCast(u36,1) << @truncate(u6, X.items[k]);
                    if (brute & (@intCast(u36,1) << k) != 0) {addr |=  bit;}
                    else                                     {addr &= ~bit;}
                }
                try mem2.put(addr, value);
            }
        }
    }

    var sum: u64 = 0;
    var it = mem.iterator();
    while (it.next()) |kv| { sum += kv.value; }
    print("Part 1: {}\n", .{sum});

    sum = 0;
    it = mem2.iterator();
    while (it.next()) |kv| { sum += kv.value; }
    print("Part 2: {}\n", .{sum});
}


