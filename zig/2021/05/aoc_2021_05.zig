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

const XY = struct {x: u64, y: u64};

pub fn add_to_map_default_zero(map: *std.AutoHashMap(XY, u64), xy: XY) !void {
    const val = map.get(xy) orelse 0;
    try map.put(xy, val + 1);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var map = std.AutoHashMap(XY, u64).init(allocator);
    
    for (lines) |line| {
        var iterator = std.mem.tokenize(u8, line, ", ->");
        const x1 = try std.fmt.parseInt(u64, iterator.next().?, 10);
        const y1 = try std.fmt.parseInt(u64, iterator.next().?, 10);
        const x2 = try std.fmt.parseInt(u64, iterator.next().?, 10);
        const y2 = try std.fmt.parseInt(u64, iterator.next().?, 10);
        
        var x: u64 = x1;
        var y: u64 = y1;
        while (true) {
            try add_to_map_default_zero(&map, XY {.x=x, .y=y});
            if ((x == x2) and (y == y2)) {break;}
            if (x < x2) {x += 1;} else if (x > x2) {x -= 1;}
            if (y < y2) {y += 1;} else if (y > y2) {y -= 1;}
        }

    }

    var overlaps: u64 = 0;
    var map_ite = map.iterator();
    while (map_ite.next()) |kv| {
        if (kv.value_ptr.* > 1) {overlaps += 1;}
    }
    // print("Part 1: {}\n", .{overlaps});  // remove the diagonal handling to get part 1
    print("Part 2: {}\n", .{overlaps});
}


