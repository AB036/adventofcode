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


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var grid = std.AutoHashMap([4]i64, u8).init(allocator);
    for (lines) |line, l| {
        for (line) |char, c| {
            const x = @intCast(i64, c);
            const y = @intCast(i64, l);
            try grid.put(.{x,y,0,0}, char);
        }
    }
    var xmin: i64 = 0; var xmax: i64 = @intCast(i64,lines[0].len) - 1;
    var ymin: i64 = 0; var ymax: i64 = @intCast(i64,lines.len) - 1;
    var zmin: i64 = 0; var zmax: i64 = 0;
    var wmin: i64 = 0; var wmax: i64 = 0;

    const deltas = [3]i8{-1,0,1};

    var cycles: u32 = 0;
    while (cycles < 6) : (cycles += 1) {
        var new_grid = try grid.clone();
        xmin -= 1; xmax += 1;
        ymin -= 1; ymax += 1;
        zmin -= 1; zmax += 1;
        wmin -= 1; wmax += 1;

        var x: i64 = xmin; while (x <= xmax) : (x += 1) {
        var y: i64 = ymin; while (y <= ymax) : (y += 1) {
        var z: i64 = zmin; while (z <= zmax) : (z += 1) {
        var w: i64 = wmin; while (w <= wmax) : (w += 1) {
            var neighbors: u8 = 0;
            for (deltas) |dx| {
            for (deltas) |dy| {
            for (deltas) |dz| {
            for (deltas) |dw| {
                if (dx == 0 and dy == 0 and dz == 0 and dw == 0) {continue;}
                const value = grid.get(.{x+dx ,y+dy, z+dz, w+dw}) orelse '.';
                if (value == '#') {neighbors += 1;}
            }}}}
            var grid_value = grid.get(.{x,y,z,w}) orelse '.';
            if (grid_value == '.') {
                if (neighbors == 3) {grid_value = '#';}
            }
            else {
                if (neighbors != 2 and neighbors != 3) {grid_value = '.';}
            }
            try new_grid.put(.{x,y,z,w}, grid_value);
        }}}}
        grid.clearAndFree();
        grid = new_grid;
    }

    var n_active: u32 = 0;
    var ite = grid.iterator();
    while (ite.next()) |kv| { if (kv.value == '#') {n_active += 1;} }
    print("{}\n", .{n_active});
}


