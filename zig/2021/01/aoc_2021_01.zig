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

    var list = std.ArrayList(i64).init(allocator);

    for (lines) |line| {
        var value = try std.fmt.parseInt(i64, line, 10);
        try list.append(value);
    }
    
    var k: usize = 0;
    var part1: u32 = 0;
    while (k < list.items.len - 1) : (k += 1) {
        if (list.items[k] < list.items[k+1]) {
            part1 += 1;
        }
    }
    print("{}\n", .{part1});
    
    k = 0;
    var part2: u32 = 0;
    while (k < list.items.len - 3) : (k += 1) {
        if (list.items[k] < list.items[k+3]) {
            part2 += 1;
        }
        
    }
    print("{}\n", .{part2});

}


