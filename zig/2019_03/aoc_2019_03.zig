const std = @import("std");

const print = std.debug.print;

const adv = struct {
    dir: u8,
    dist: i64,
};

const vec = struct{ x:i64, y:i64 };

pub fn man_dist(vvv: vec) i64 {
    var dist: i64 = 0;
    if (vvv.x >= 0) {dist += vvv.x;}
    else {dist -= vvv.x;}
    if (vvv.y >= 0) {dist += vvv.y;}
    else {dist -= vvv.y;}
    return dist;
}

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


pub fn read_adv(line: []const u8, allocator: *std.mem.Allocator) ![] adv {
    var list = std.ArrayList(adv).init(allocator);
    var iterator = std.mem.tokenize(line, ",");
    while (iterator.next()) |token| {
        var aaa = adv {.dir = undefined, .dist = undefined};
        aaa.dir = token[0];
        aaa.dist = try std.fmt.parseInt(i64, token[1..], 10);
        try list.append(aaa);
    }
    return list.toOwnedSlice();
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var wire0_adv = try read_adv(lines[0], allocator);
    var wire1_adv = try read_adv(lines[1], allocator);

    var x: i64 = 0;
    var y: i64 = 0;

    var seen = std.hash_map.AutoHashMap(vec, i64).init(allocator);
    var step: i64 = 0;

    for (wire0_adv) |aaa| {
        var n = aaa.dist;
        while (n > 0) : (n -= 1) {
            const movement = switch (aaa.dir) {
                    'U' => vec {.x = 0, .y = -1},
                    'D' => vec {.x = 0, .y = 1},
                    'L' => vec {.x = -1, .y = 0},
                    'R' => vec {.x = 1, .y = 0},
                    else => unreachable,
            };
            x += movement.x;
            y += movement.y;
            step += 1;
            _ = try seen.put(vec {.x = x, .y = y}, step);
        }
    }

    x = 0;
    y = 0;
    step = 0;
    
    var doubles = std.hash_map.AutoHashMap(vec, i64).init(allocator);

    for (wire1_adv) |aaa| {
        var n = aaa.dist;
        while (n > 0) : (n -= 1) {
            const movement = switch (aaa.dir) {
                    'U' => vec {.x = 0, .y = -1},
                    'D' => vec {.x = 0, .y = 1},
                    'L' => vec {.x = -1, .y = 0},
                    'R' => vec {.x = 1, .y = 0},
                    else => unreachable,
            };
            x += movement.x;
            y += movement.y;
            step += 1;
            if (seen.contains(vec {.x = x, .y = y})) {
                const step_other = seen.get(vec {.x = x, .y = y});
                if (step_other) |value|{
                    _ = try doubles.put(vec {.x = x, .y = y}, step + value);
                }
                else unreachable;
            }
        }
    }

    var mini: i64 = 99999999999;
    var best_x: i64 = undefined;
    var best_y: i64 = undefined;

    var it = doubles.iterator();
    while (it.next()) |kv| {
        //if (mini > man_dist(kv.key)) mini = man_dist(kv.key);
        if (mini > kv.value) mini = kv.value;
    }

    print("{}\n", .{mini});
}


