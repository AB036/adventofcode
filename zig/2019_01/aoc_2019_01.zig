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

pub fn fuel(mass: i64) i64 {
    var fuel_needed: i64 = @divFloor(mass, 3) - 2;
    if (fuel_needed <= 0) {
        return 0;
    }
    return fuel_needed + fuel(fuel_needed);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var total_fuel: i64 = 0;

    for (lines) |line| {
        var value = try std.fmt.parseInt(i64, line, 10);
        var fff = fuel(value);
        //print("{} {}\n", .{value, fff});
        total_fuel += fff;
    }

    print("{}\n", .{total_fuel});
}


