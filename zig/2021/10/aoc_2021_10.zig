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
    var scores = std.ArrayList(u64).init(allocator);
    
    for (lines) |line| {
        var a_l = try std.ArrayList(u8).initCapacity(allocator, line.len);
        a_l.appendSliceAssumeCapacity(line);
        var stack = a_l.toOwnedSlice();
        var i: u32 = 0;
        var corrupted = false;
        
        for (line) |c| {
            if (c == '(' or c == '[' or c == '{' or c == '<') {
                i += 1;
                stack[i] = c;
                continue;
            }
            
            const expected: u8 = switch (stack[i]) {
                '(' => ')', '[' => ']', '{' => '}', '<' => '>', else => unreachable
            };
            if (expected != c) {
                const score: u32 = switch (c) {
                    ')' => 3, ']' => 57, '}' => 1197, '>' => 25137, else => unreachable
                };
                part1 += score;
                corrupted = true;
                break;
            }
            
            i -= 1;
        }

        if (!corrupted) {
            var score: u64 = 0;
            var k: u32 = i;
            while (k >= 1) : (k -= 1) {
                const value: u64 = switch (stack[k]) {
                    '(' => 1, '[' => 2, '{' => 3, '<' => 4, else => unreachable
                };
                score = score*5 + value;
            }
            try scores.append(score);
        }
    }
    
    var ss = scores.toOwnedSlice();
    std.sort.sort(u64, ss, {}, comptime std.sort.asc(u64));
    
    print("Part 1: {}\n", .{part1});
    print("Part 2: {any}\n", .{ss[ss.len / 2]});
}


