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
    //var lines = try read_lines("bigboy", allocator);

    var valid_passwords: i32 = 0;
    var valid_passwords2: i32 = 0;

    for (lines) |line| {
        var dash: usize = 0;
        while (line[dash] != '-') {dash += 1;}
        var first_space: usize = dash + 1;
        while (line[first_space] != ' ') {first_space += 1;}
        var mini = try std.fmt.parseInt(u32, line[0 .. dash], 10);
        var maxi = try std.fmt.parseInt(u32, line[dash+1 .. first_space], 10);
        var letter = line[first_space+1];

        var index: usize = first_space + 4;
        var count: i32 = 0;
        for (line[first_space + 4 ..]) |char| {
            if (char == letter) {count += 1;}
        }

        if (mini <= count and count <= maxi) {
            valid_passwords += 1;
        }

        var i: usize = first_space + 3 + mini;
        var j: usize = first_space + 3 + maxi;
        if ((line[i] == letter or line[j] == letter) and line[i] != line[j]) {
            valid_passwords2 += 1;
        }
    }

    print("Part 1: {d}\n", .{valid_passwords});
    print("Part 2: {d}\n", .{valid_passwords2});

}


