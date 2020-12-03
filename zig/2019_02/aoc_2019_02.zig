const std = @import("std");

const print = std.debug.print;

pub fn read_ints(path: []const u8, allocator: *std.mem.Allocator) ![] const i64 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.tokenize(trimmed, ",");
    var list = std.ArrayList(i64).init(allocator);
    while (iterator.next()) |token| {
        var code = try std.fmt.parseInt(i64,token,10);
        try list.append(code);
    }

    return list.toOwnedSlice();
}

pub fn intcode(ints: []i64, input1: i64, input2: i64) i64 {
    var k: usize = 0;
    const n = ints.len;
    ints[1] = input1;
    ints[2] = input2;
    while (k < n) {
        //print("{} {}\n", .{k, ints[k]});
        if (ints[k] == 1) {
            const index_a = @intCast(usize, ints[k+1]);
            const index_b = @intCast(usize, ints[k+2]);
            const index_c = @intCast(usize, ints[k+3]);
            ints[index_c] = ints[index_b] + ints[index_a];
            k += 4;
        }
        else if (ints[k] == 2) {
            const index_a = @intCast(usize, ints[k+1]);
            const index_b = @intCast(usize, ints[k+2]);
            const index_c = @intCast(usize, ints[k+3]);
            ints[index_c] = ints[index_b] * ints[index_a];
            k += 4;
        }
        else if (ints[k] == 99) {break;}
        else {unreachable;}
    }
    return ints[0];
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    const ints = try read_ints("input.txt", allocator);
    //var ints = try read_ints("test.txt", allocator);

    var ints_copy_0 = std.ArrayList(i64).init(allocator);
    for (ints) |code| {
        try ints_copy_0.append(code);
    }
    var result_0 = intcode(ints_copy_0.toOwnedSlice(), 12, 2);
    print("{}\n", .{result_0});

    var x: i64 = 0;
    var y: i64 = 0;
    while (x <= 99) : (x += 1) {
        while (y <= 99) : (y += 1) {
            var ints_copy = std.ArrayList(i64).init(allocator);
            for (ints) |code| {
                try ints_copy.append(code);
            }
            var result = intcode(ints_copy.toOwnedSlice(), x, y);
            if (result == 19690720) {
                print("{}{}\n", .{x, y});
            }
        }
        y = 0;
    }
}


