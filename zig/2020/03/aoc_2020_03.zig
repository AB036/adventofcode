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

    var list = std.ArrayList(bool).init(allocator);
    var Y = lines.len;
    var X = lines[0].len;

    var answer: u32 = 1;

    const slopes = [_]u32{1,1,3,1,5,1,7,1,1,2};
    var k: usize = 0;
    while (k < slopes.len) : (k += 2) {
        const sx = slopes[k];
        const sy = slopes[k+1];
        var x: u64 = 0;
        var y: u64 = 0;
        var trees: u32 = 0;
    
        while (y < Y) {
            if (lines[y][x] == '#') {
                trees += 1;
            }
            x = (x+sx) % X;
            y += sy;
        }
        answer *= trees;
        if (sx == 3) {print("Part 1: {}\n", .{trees});}
    }

    print("Part 2: {}\n", .{answer});
}


