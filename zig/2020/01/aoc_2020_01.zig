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

    var list = std.ArrayList(i64).init(allocator);

    for (lines) |line| {
        var value = try std.fmt.parseInt(i64, line, 10);
        try list.append(value);
    }

    var map = std.AutoHashMap(i64, usize).init(allocator);
    var map2 = std.AutoHashMap(i64, i64).init(allocator);
    for (list.items) |item, i| {
        try map.put(item, i);
        for (list.items) |item2, j| {
            try map2.put(item + item2, item2);
        }
    }

    for (list.items) |item, i| {
        if (map.contains(2020 - item)) {
            var j = map.get(2020-item).?;
            if (i != j) {
                print("Part 1: {} * {} = {}\n", .{item,2020-item, item*(2020-item)});
                break;
            }
        }
    }
    for (list.items) |item, i| {
        if (map2.contains(2020 - item)) {
            var item2 = map2.get(2020-item).?;
            var item3 = 2020 - item - item2;
            print("Part 2: {} * {} * {} = {}\n", .{item,item2,item3, item*item2*item3});
            break;
         }
    }

    // var n = list.items.len;
// 
    // var i: usize = 0;
    // while (i < n) : (i += 1) {
        // var j: usize = i + 1;
        // while (j < n) : (j += 1) {
            // var a = list.items[i];
            // var b = list.items[j];
            // if (a + b == 2020) {
                // print("{} {} -> {} * {} = {}\n", .{i,j, a, b, a*b});
            // }
            // var k: usize = j + 1;
            // while (k < n) : (k += 1) {
                // var c = list.items[k];
                // if (a+b+c == 2020) {
                    // print("{} {} {} -> {} * {} * {} = {}\n", .{i,j,k,a,b,c,a*b*c});
                // }
            // }
        // }
    // }

}


