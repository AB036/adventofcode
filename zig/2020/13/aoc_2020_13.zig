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


pub fn euclid(x: u64, y: u64) u64 {
    var a = x; var b = y;
    if (a < b) {a = y; b = x;}
    while (b != 0) {
        const t = b;
        b = a % b;
        a = t;
    }
    return a;
}


pub fn lcm(x: u64, y: u64) u64 {
    return (x*y)/euclid(x,y);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var t: u64 = try std.fmt.parseInt(u64, lines[0], 10);
    var ite = std.mem.split(lines[1], ",");
    var bus = std.ArrayList(u64).init(allocator);
    var rest = std.ArrayList(u64).init(allocator);
    var i_bus: u64 = 0;
    while (ite.next()) |bus_id_str| : (i_bus += 1){
        if (bus_id_str[0] == 'x') {continue;}
        const bus_id = try std.fmt.parseInt(u64, bus_id_str, 10);
        try bus.append(bus_id);
        try rest.append((bus_id - i_bus%bus_id) % bus_id);
    }
    const n: usize = bus.items.len;

    var best_time: u64 = std.math.maxInt(u64);
    var best_bus: u64 = 0;
    for (bus.items) |bus_id| {
        const eta: u64 = bus_id - t % bus_id;
        if (eta < best_time) { best_time = eta; best_bus = bus_id; }
    }
    print("Part 1: {} * {} = {}\n", .{best_time, best_bus, best_time*best_bus});

    var k: usize = 0;
    var r: u64 = 0;
    var mod: u64 = 1;
    while (k < n) : (k += 1) {
        const new_mod = lcm(mod, bus.items[k]);
        var new_rest = r;
        while (new_rest % bus.items[k] != rest.items[k]) {new_rest += mod;}
        r = new_rest % new_mod;
        mod = new_mod;
    }
    print("Part 2: {}\n", .{r});
}


