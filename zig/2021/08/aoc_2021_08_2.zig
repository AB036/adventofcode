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

    var part1: u32 = 0;
    var part2: u32 = 0;
    
    for (lines) |line| {
        var ite = std.mem.split(u8, line, " | ");
        const first_line = ite.next().?;
        const output_line = ite.next().?;
        
        var occurences = std.AutoHashMap(u8, u8).init(allocator);
        var ite3 = std.mem.split(u8, first_line, " ");
        while (ite3.next()) |token| {
            for (token) |letter| {
                const n = occurences.get(letter) orelse 0;
                try occurences.put(letter, n+1);
            }
        }
        
        var m: u32 = 1000;
        var ite2 = std.mem.split(u8, output_line, " ");
        while (ite2.next()) |token| {
            const lengths: [4]u8 = .{2,4,3,7};
            for (lengths) |length| { if (token.len == length) {part1 += 1;} }
            
            var token_sum: u32 = 0;
            for (token) |letter| {token_sum += occurences.get(letter).?;}
            
            // It just works
            const value: u8 = switch (token_sum) {
                42 => 0,
                17 => 1,
                34 => 2,
                39 => 3,
                30 => 4,
                37 => 5,
                41 => 6,
                25 => 7,
                49 => 8,
                45 => 9,
                else => unreachable,
            };
            part2 += value * m;
            m = m / 10;
        }
    }
    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{part2});
}


