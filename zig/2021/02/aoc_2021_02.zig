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

const Vec = struct {
    x: i64 = 0,
    y: i64 = 0,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var depth = Vec {};
    var depth2 = Vec {};
    var aim: i64 = 0;
    
    for (lines) |line| {
        var iterator = std.mem.tokenize(u8, line, " ");
        const dir: []const u8 = iterator.next().?;
        const len: []const u8 = iterator.next().?;
        const val: i64 = try std.fmt.parseInt(i64, len, 10);
        
        switch (dir[0]) {
            'f'  => {depth.x += val;   depth2.x += val; depth2.y += aim*val;},
            'd'  => {depth.y += val;   aim += val;},
            'u'  => {depth.y -= val;   aim -= val;},
            else => unreachable,
        }
    }
    
    print("Part 1: {}\n", .{depth.x * depth.y});
    print("Part 2: {}\n", .{depth2.x * depth2.y});
}


