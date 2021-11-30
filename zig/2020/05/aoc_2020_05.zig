const std = @import("std");

const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.tokenize(trimmed, "\n");
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

    var best: u16 = 0;
    var map = std.AutoHashMap(u16, void).init(allocator);

    for (lines) |line| {
        var seat_id: u16 = 0;
        for (line) |char, i| {
            if (char == 'B' or char == 'R') {
                const shift: u4 = @truncate(u4, 9 - i);
                seat_id += @intCast(u16,1) << shift;
            }
        }
        if (best < seat_id) {best = seat_id;}
        try map.put(seat_id, undefined);
    }
    print("Part 1: {}\n", .{best});

    var seat_id: u16 = 0;
    while (seat_id <= 0b1111111111) : (seat_id += 1) {
        if (!map.contains(seat_id) and map.contains(seat_id-%1) and map.contains(seat_id+1)) {
           print("Part 2: {}\n", .{seat_id});
        }
    }
}


