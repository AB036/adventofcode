const std = @import("std");

const print = std.debug.print;

pub fn read_input(path: []const u8, allocator: *std.mem.Allocator) ![]u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    var iterator = std.mem.tokenize(u8, trimmed, ",");

    var list = std.ArrayList(u8).init(allocator);
    while (iterator.next()) |token| {
        try list.append(try std.fmt.parseInt(u8, token, 10));
    }

    return list.toOwnedSlice();
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var list = try read_input("input.txt", allocator);
    //~ var list = try read_input("test.txt", allocator);

    var map = [_]u64{0} ** 9;
    for (list) |number| { map[number] += 1; }

    var day: u32 = 0;
    while (day < 256) : (day += 1) {  // put limit = 80 for day 1
        const zeroes: u64 = map[0];
        
        var number: u8 = 1;
        while (number <= 8) : (number += 1) {
            map[number-1] = map[number];
        }
        
        map[6] += zeroes;
        map[8] = zeroes;
    }
    
    var sum: u64 = 0;
    for (map) |x| { sum += x; }
    print("{}\n", .{sum});
}


