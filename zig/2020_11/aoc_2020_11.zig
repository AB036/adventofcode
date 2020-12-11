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


const XY = struct { x: i32, y: i32};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    for (0 .. 10) |token| {
        print("{}\n", .{token});
    }

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    const ny: i32 = @intCast(i32, lines.len);
    const nx: i32 = @intCast(i32, lines[0].len);

    var grid = std.AutoHashMap(XY, u8).init(allocator);
    for (lines) |line, l| {
        for (line) |char, c| {
            try grid.put(XY {.x = @intCast(i32,c), .y = @intCast(i32,l)}, char);
        }
    }

    var smth_changed: bool = true;
    while (smth_changed) {
        //print("---------------------------------\n", .{});
        smth_changed = false;
        var new_grid = try grid.clone();
        var y: i32 = 0;
        while (y < ny) : (y += 1) {
            var x: i32 = 0;
            while (x < nx) : (x += 1) {
                const xy = XY {.x = x, .y = y};
                const grid_value = grid.get(xy).?;
                //print("{c}", .{grid_value});
                if (grid_value == '.') { continue; }
                
                var n_adj: u8 = 0;
                const dx = [8]i8{-1, 0, 1, 1, 1, 0,-1,-1};
                const dy = [8]i8{-1,-1,-1, 0, 1, 1, 1, 0};
                var k: usize = 0;
                while (k < 8) : (k += 1) {
                    var coords = XY {.x = x+dx[k], .y = y+dy[k]};
                    while (grid.contains(coords)) {
                        if (grid.get(coords).? == 'L') {break;}
                        if (grid.get(coords).? == '#') {n_adj += 1; break;}
                        coords.x += dx[k]; coords.y += dy[k];
                        // PART 1 -> break;
                    }
                }
                
                if (grid_value == 'L' and n_adj == 0) {
                    try new_grid.put(xy, '#'); smth_changed = true;
                }
                else if (grid_value == '#' and n_adj >= 5) { // part 1 had 4 here
                    try new_grid.put(xy, 'L'); smth_changed = true;
                }
            }
            //print("\n", .{});
        }
        grid.clearAndFree();
        grid = new_grid;  // hopefully there's pointer magic and it just works
    }

    var n_occupied: u32 = 0;
    var ite = grid.iterator();
    while (ite.next()) |kv| {
        if (kv.value == '#') {n_occupied += 1;}
    }
    print("{}\n", .{n_occupied});
}


