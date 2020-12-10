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

const asc_u64 = std.sort.asc(u64);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var list = std.ArrayList(u64).init(allocator);
    for (lines) |line| {
        const a = try std.fmt.parseInt(u64, line, 10);
        try list.append(a);
    }
    try list.append(0);  // the first value is zero
    var numbers = list.toOwnedSlice();
    std.sort.sort(u64, numbers, {}, asc_u64);

    var ones: u64 = 0;
    var threes: u64 = 1; // the last one will always be 3, so this starts at 1
    var i: usize = 0;
    while (i < numbers.len - 1) : (i += 1) {
        switch (numbers[i+1] - numbers[i]) {
            1 => ones += 1,
            3 => threes += 1,
            else => continue,
        }
    }
    print("Part 1: {} * {} = {}\n", .{ones, threes, ones*threes});

    // Dynamic programming
    // numbers of ways to reach the previous three elements: [P(k-3), P(k-2), P(k-1)]
    var possibilities = [_]u128{0} ** 3;
    possibilities[2] = 1;
    var k: usize = 1;
    while (k < numbers.len) : (k += 1) {
        var sum: u128 = 0;
        var d: usize = 0;
        while (d <= 2) : (d += 1) {
            if (k+d >= 3 and numbers[k] - numbers[k+d-3] <= 3) {
                sum += possibilities[d];
            }
        }
        possibilities[0] = possibilities[1];
        possibilities[1] = possibilities[2];
        possibilities[2] = sum;
    }
    print("Part 2: {}\n", .{possibilities[2]});
}


