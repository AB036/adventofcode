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
    while (iterator.next()) |token| { try list.append(token); }

    return list.toOwnedSlice();
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var input = try read_lines("input.txt", allocator);
    //var input = try read_lines("test.txt", allocator);

    var tiles = std.AutoHashMap([2]i32, bool).init(allocator);
    var N: u32 = 0;

    for (input) |line| {
        var i: usize = 0;
        var x: i32 = 0; var y: i32 = 0;
        while (i < line.len){
            var j = i+1;
            defer i = j;
            if (line[i] == 'n' or line[i] == 's') {j += 1;}
            if (line[i] == 'e') {x += 1;}
            else if (line[i] == 'w') {x -= 1;}
            else if (std.mem.eql(u8, line[i..j], "ne")) {y -= 1;}
            else if (std.mem.eql(u8, line[i..j], "sw")) {y += 1;}
            else if (std.mem.eql(u8, line[i..j], "nw")) {x -= 1; y -= 1;}
            else if (std.mem.eql(u8, line[i..j], "se")) {x += 1; y += 1;}
        }

        if (!tiles.contains(.{x,y})) { try tiles.put(.{x,y}, true); N += 1;}
        else {
            const t = tiles.get(.{x,y}).?;
            try tiles.put(.{x,y}, !t);
            if (t) {N -= 1;} else {N += 1;}
        }
    }
    print("Part 1: {}\n", .{N});

    var day: u32 = 0;
    while (day < 100) : (day += 1) {
        var around = std.AutoHashMap([2]i32, u8).init(allocator);
        defer around.deinit();
        var ite = tiles.iterator();
        while (ite.next()) |kv| {
            const x = kv.key[0];
            const y = kv.key[1];
            const dd = [6][2]i8 { .{1,0}, .{-1,0}, .{0,-1}, .{0,1}, .{1,1}, .{-1,-1} };
            var local_blacks: u8 = 0;
            for (dd) |d| {
                const xx = x + d[0];
                const yy = y + d[1];
                if (tiles.contains(.{xx,yy})) {
                    if (tiles.get(.{xx,yy}).?) {local_blacks += 1;}
                }
                else if (around.contains(.{xx,yy})) {
                    if (kv.value) {
                        try around.put(.{xx,yy}, around.get(.{xx,yy}).? + 1);
                    }
                }
                else {
                    try around.put(.{xx,yy}, if (kv.value) 1 else 0);
                }
            }
            try around.put(.{x,y}, local_blacks);
        }

        var new_tiles = std.AutoHashMap([2]i32, bool).init(allocator);
        var ite2 = around.iterator();
        while (ite2.next()) |kv| {
            const x = kv.key[0];
            const y = kv.key[1];
            var ig = tiles.get(.{x,y}) orelse false;
            if (ig and (kv.value == 0 or kv.value > 2)) {ig = false;}
            else if (!ig and kv.value == 2) {ig = true;}
            if (ig) { try new_tiles.put(.{x,y}, ig); }
        }
        
        tiles.deinit();
        tiles = new_tiles;
    }

    var xmin: i32 = 0; var xmax: i32 = 0;
    var ymin: i32 = 0; var ymax: i32 = 0;
    var gers: u32 = 0;
    var ite = tiles.iterator();
    while (ite.next()) |kv| {
        xmin = std.math.min(xmin, kv.key[0]); xmax = std.math.max(xmax, kv.key[0]);
        ymin = std.math.min(ymin, kv.key[1]); ymax = std.math.max(ymax, kv.key[1]);
        if (kv.value) {gers += 1;}
    }
    print("Part 2: {}\n", .{gers});

    // var v: u32 = 0; while (v <= ymax - ymin) : (v += 1) {
        // if (v % 2 == 1) {print(" ", .{});}
        // var u: u32 = 0; while (u <= xmax - xmin) : (u += 1) {
            // const x: i32 = xmin + @intCast(i32, u) - ymin - @intCast(i32, v);
            // const y: i32 = ymin + @intCast(i32, v);
            // if (tiles.get(.{x,y}) orelse false) {print("● ", .{});}
            // else { print("  ", .{}); }
        // }
        // print("\n", .{});
    // }
    
    
}


