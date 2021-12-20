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

pub fn transform(xyz: [3]i64, t: u8) [3]i64 {
    const x = xyz[0]; const y = xyz[1]; const z = xyz[2];
    return switch (t) {
        0 =>  .{x, y, z},   1 =>  .{x, -y, -z},
        2 =>  .{x, z, -y},  3 =>  .{x, -z, y},
        
        4 =>  .{y, x, -z},  5 =>  .{y, -x, z},
        6 =>  .{y, z, x},   7 =>  .{y, -z, -x},
        
        8 =>  .{z, x, y},   9 =>  .{z, -x, -y},
        10 => .{z, y, -x},  11 => .{z, -y, x},
        
        12 => .{-x, y, -z}, 13 => .{-x, -y, z},
        14 => .{-x, z, y},  15 => .{-x, -z, -y},
        
        16 => .{-y, x, z},  17 => .{-y, -x, -z},
        18 => .{-y, z, -x}, 19 => .{-y, -z, x},
        
        20 => .{-z, x, -y}, 21 => .{-z, -x, y},
        22 => .{-z, y, x},  23 => .{-z, -y, -x},
        
        else => unreachable,
    };
}


const AAA = struct { tr: u8, shift: [3]i64 };

pub fn match(coords_a: [][3]i64, coords_b: [][3]i64, allocator: *std.mem.Allocator) !?AAA {
    var tr: u8 = 0; while (tr < 24) : (tr += 1) {
        
        var map = std.AutoHashMap([3]i64, void).init(allocator);
        for (coords_a) |aaa| { try map.put(aaa, undefined); }
        
        for (coords_a) |aaa| {
        for (coords_b) |bbb| {
            const ttt = transform(bbb, tr);
            const shift: [3]i64 = .{-ttt[0] + aaa[0], -ttt[1] + aaa[1], -ttt[2] + aaa[2]};
            
            var n_match: u32 = 0;
            
            for (coords_b) |bb| {
                const rot = transform(bb, tr);
                const xyz: [3]i64 = .{rot[0] + shift[0], rot[1] + shift[1], rot[2] + shift[2]};
                if (map.contains(xyz)) { n_match += 1; }
            }
            
            if (n_match >= 12) { return AAA {.tr = tr, .shift = shift}; }
        }}
    }
    return null;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var scan_data = std.ArrayList(std.ArrayList([3]i64)).init(allocator);
    var scan_pos = std.ArrayList([3]i64).init(allocator);
    var scan_found = std.ArrayList(bool).init(allocator);
    try scan_pos.append(.{0, 0, 0});
    try scan_found.append(true);
    var scan_id: usize = 0;
    
    for (lines) |line| {
        if (line[1] == '-') {
            try scan_data.append(std.ArrayList([3]i64).init(allocator));
            if (scan_id != 0) {
                try scan_pos.append(undefined);
                try scan_found.append(false);
            }
            scan_id += 1;
        }
        else {
            var ite = std.mem.split(u8, line, ",");
            const xxx = try std.fmt.parseInt(i64, ite.next().?, 10);
            const yyy = try std.fmt.parseInt(i64, ite.next().?, 10);
            const zzz = try std.fmt.parseInt(i64, ite.next().?, 10);
            try scan_data.items[scan_id - 1].append(.{xxx, yyy, zzz});
        }
    }
    const n = scan_id;
    
    var beacons = std.AutoHashMap([3]i64, void).init(allocator);
    for (scan_data.items[0].items) |xyz| { try beacons.put(xyz, undefined); }
    
    var tested = try allocator.alloc(bool, n*n);
    var ii: usize = 0; while (ii < n*n) : (ii += 1) { tested[ii] = false; }
    
    var stop = false;
    while (!stop) {
        stop = true;
        
        var i: usize = 0; while (i < n) : (i += 1) {  if (!scan_found.items[i]) { continue; }
        var j: usize = 0; while (j < n) : (j += 1) {
            if (i == j) { continue; }
            if (tested[n*i + j]) { continue; }
            if (scan_found.items[j]) { continue; }
            
            const m = try match(scan_data.items[i].items, scan_data.items[j].items, allocator);
            tested[n*i + j] = true;
            const res = m orelse continue;
            
            scan_found.items[j] = true;
            scan_pos.items[j] = res.shift;
            print("Scanner {}: {any}\n", .{j, res.shift});
            stop = false;
            
            var k: usize = 0; while (k < scan_data.items[j].items.len) : (k += 1) {
                const rot = transform(scan_data.items[j].items[k], res.tr);
                const beacon: [3]i64 = .{rot[0] + res.shift[0], rot[1] + res.shift[1], rot[2] + res.shift[2]};
                try beacons.put(beacon, undefined);
                scan_data.items[j].items[k] = beacon;
            }
            
            
        }}
    }
    print("Part 1: {}\n", .{beacons.count()});
    
    var part2: i64 = 0;
    
    var i: usize = 0;   while (i < n-1) : (i += 1) {
    var j: usize = i+1; while (j < n) :   (j += 1) {
        const aaa = scan_pos.items[i];
        const bbb = scan_pos.items[j];
        
        var dist = try std.math.absInt(aaa[0] - bbb[0]);
        dist += try std.math.absInt(aaa[1] - bbb[1]);
        dist += try std.math.absInt(aaa[2] - bbb[2]);
        if (dist > part2) { part2 = dist; }
    }}
    
    print("Part 2: {}\n", .{part2});
}


