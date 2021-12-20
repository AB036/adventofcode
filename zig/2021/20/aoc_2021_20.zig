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


pub fn pixel_index(x: i64, y: i64, map: std.AutoHashMap([2]i64, u8), def: u8) usize {
    var p: usize = 0;
    
    if (map.get(.{x-1, y-1}) orelse def == '#') { p += 0b100000000; }
    if (map.get(.{x  , y-1}) orelse def == '#') { p += 0b10000000; }
    if (map.get(.{x+1, y-1}) orelse def == '#') { p += 0b1000000; }
    if (map.get(.{x-1, y  }) orelse def == '#') { p += 0b100000; }
    if (map.get(.{x  , y  }) orelse def == '#') { p += 0b10000; }
    if (map.get(.{x+1, y  }) orelse def == '#') { p += 0b1000; }
    if (map.get(.{x-1, y+1}) orelse def == '#') { p += 0b100; }
    if (map.get(.{x  , y+1}) orelse def == '#') { p += 0b10; }
    if (map.get(.{x+1, y+1}) orelse def == '#') { p += 0b1; }
    
    return p;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    //~ var lines = try read_lines("input.txt", allocator);
    var lines = try read_lines("test.txt", allocator);

    const alg = lines[0];
    var img = std.AutoHashMap([2]i64, u8).init(allocator);
    
    for (lines[1..]) |line, y| {
        for (line) |c, x| {
            try img.put(.{@intCast(i64, x), @intCast(i64, y)}, c);
        }
    }

    var xmin: i64 = 0;  var xmax: i64 = @intCast(i64, lines[1].len);
    var ymin: i64 = 0;  var ymax: i64 = @intCast(i64, lines.len - 1);
    
    var default: u8 = '.';

    var NI: u64 = 0;
    var step: u64 = 0;
    while (step < 50) : (step += 1) {
        xmin -= 1;  xmax += 1;
        ymin -= 1;  ymax += 1;
        var new_img = std.AutoHashMap([2]i64, u8).init(allocator);
        NI = 0;
        
        var y = ymin; while (y <= ymax) : (y += 1) {
        var x = xmin; while (x <= xmax) : (x += 1) {
            const i = pixel_index(x, y, img, default);
            try new_img.put(.{x, y}, alg[i]);
            if (alg[i] == '#') { NI += 1; }
        }}
        
        img.deinit();
        img = new_img;
        default = if (default == '.') alg[0] else alg[alg.len-1];
        
        if (step == 1) { print("Part 1: {}\n", .{NI}); }
    }
    
    print("Part 2: {}\n", .{NI});
}


