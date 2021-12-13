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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("folded_101_times.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var map = std.AutoHashMap(XY, void).init(allocator);
    var folds = std.ArrayList(i128).init(allocator);
    
    for (lines) |line| {
        if (line[0] == 'f') {
            var ite = std.mem.split(u8, line, "=");
            const A = ite.next().?;
            const val = try std.fmt.parseInt(i128, ite.next().?, 10);
            try folds.append(if (A[A.len-1] == 'x') val else -val);
        }
        else {
            var ite = std.mem.split(u8, line, ",");
            const x = try std.fmt.parseInt(u64, ite.next().?, 10);
            const y = try std.fmt.parseInt(u64, ite.next().?, 10);
            try map.put(.{.x=x,.y=y}, undefined);
        }
    }

    var fold_x: u64 = 100;
    var fold_y: u64 = 100;
    
    for (folds.items) |fold, k| {
        var to_add = std.ArrayList(XY).init(allocator);
        defer to_add.deinit();
        var to_remove = std.ArrayList(XY).init(allocator);
        defer to_remove.deinit();
        
        if (fold < 0) { // fold on y
            fold_y = @intCast(u64, -fold);
            var ite = map.iterator();
            while (ite.next()) |kv| {
                if (kv.key_ptr.y > fold_y) {
                    try to_add.append(.{.x = kv.key_ptr.x, .y = 2*fold_y - kv.key_ptr.y});
                    try to_remove.append(kv.key_ptr.*);
                }
            }
        }
        else { // fold on x
            fold_x = @intCast(u64, fold);
            var ite = map.iterator();
            while (ite.next()) |kv| {
                if (kv.key_ptr.x > fold_x) {
                    try to_add.append(.{.x = 2*fold_x - kv.key_ptr.x, .y = kv.key_ptr.y});
                    try to_remove.append(kv.key_ptr.*);
                }
            }
        }
        
        for (to_remove.items) |point| { _ = map.remove(point); }
        for (to_add.items) |point| { try map.put(point, undefined); }
        
        if (k == 0) { print("Part 1: {}\n", .{map.count()}); }
    }
    
    var y: u64 = 0; while (y < fold_y) : (y += 1) {
        var x: u64 = 0; while (x < fold_x) : (x += 1) {
            if (map.contains(.{.x=x, .y=y})) { print("#", .{}); } else { print(" ", .{}); }
        }
        { print("\n", .{}); }
    }
    
    
    
}


