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


const XY = struct { x: i64, y: i64};

pub fn move(dir: u8, dist: i64) !XY {
    var xy = XY {.x = 0, .y = 0};
    switch (dir) {
        'N' => xy.y -= dist,
        'S' => xy.y += dist,
        'E' => xy.x += dist,
        'W' => xy.x -= dist,
        else => unreachable,
    }
    return xy;
}

pub fn abs(x: anytype) @TypeOf(x) {
    if (x < 0) {return -x;}
    return x;
}

pub fn rotate_right(n_turn: u8, x: i64, y: i64) XY {
    var xy = XY {.x = x, .y = y};
    var turn = n_turn;
    while (turn > 0) : (turn -= 1) {
        const temp = xy.x;
        xy.x = -xy.y;
        xy.y = temp;
    }
    return xy;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var facing: u8 = 1;
    const dirs = [4]u8 {'N', 'E', 'S', 'W'};
    var x: i64 = 0;
    var y: i64 = 0;

    for (lines) |line| {
        const dist = try std.fmt.parseInt(i64, line[1..], 10);
        if (line[0] == 'F') {
            const xy = try move(dirs[facing], dist);
            x += xy.x; y += xy.y;
        }
        else if (line[0] == 'L') {
            const turn: u8 = @intCast(u8, @mod( @divFloor(dist, 90), 4));
            facing = (facing + 4 - turn) % 4;
        }
        else if (line[0] == 'R') {
            const turn: u8 = @intCast(u8, @mod( @divFloor(dist, 90), 4));
            facing = (facing + turn) % 4;
        }
        else {
            const xy = try move(line[0], dist);
            x += xy.x; y += xy.y;
        }
    }
    print("Part 1: {} {} -> {}\n", .{x, y, abs(x) + abs(y)});

    x = 0;
    y = 0;
    var xw: i64 = 10;
    var yw: i64 = -1;

    for (lines) |line| {
        const dist = try std.fmt.parseInt(i64, line[1..], 10);
        if (line[0] == 'F') {
            x += dist*xw;
            y += dist*yw;
        }
        else if (line[0] == 'L') {
            const turn: u8 = @intCast(u8, @mod( @divFloor(dist, 90), 4));
            const xy = rotate_right(4-turn, xw, yw);
            xw = xy.x; yw = xy.y;
        }
        else if (line[0] == 'R') {
            const turn: u8 = @intCast(u8, @mod( @divFloor(dist, 90), 4));
            const xy = rotate_right(turn, xw, yw);
            xw = xy.x; yw = xy.y;
        }
        else {
            const xy = try move(line[0], dist);
            xw += xy.x; yw += xy.y;
        }
    }
    print("Part 2: {} {} -> {}\n", .{x, y, abs(x) + abs(y)});
    
}


