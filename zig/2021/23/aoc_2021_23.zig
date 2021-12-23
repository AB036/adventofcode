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


const State = struct { a: [16]u8, cost: u64 };

// Hallway    is 0 | 1 | .. | 10
// Corridor A is 11 | 12 | 13 | 14
// Corridor B is 15 | 16 | 17 | 18
// Corridor C is 19 | 20 | 21 | 22
// Corridor D is 23 | 24 | 25 | 26


pub fn get(positions: [16]u8, pos: u8) ?usize {
    for (positions) |p, k| { if (p == pos) { return k; }}
    return null;
}

pub fn costOf(k: usize, n_move: u8) u64 {
    var cost: u64 = switch (k/4) { 0 => 1,  1 => 10,  2 => 100,  else => 1000};
    return cost * n_move;
}

pub fn next(s: State, allocator: *std.mem.Allocator) ![]State {
    var list = std.ArrayList(State).init(allocator);
    for (s.a) |pos, k| {
        
        // In a room
        if (pos >= 11) {
            const target: u8 = switch (k/4) { 0 => 14,  1 => 18,  2 => 22,  else => 26};
            if (pos == target) { continue; }
            
            if ((pos - 11) % 4 != 0) {
                if (get(s.a, pos-1) == null) {
                    var new = s; new.a[k] = pos - 1; new.cost += costOf(k, 1);
                    try list.append(new);
                }
            }
            
            if ((pos - 11) % 4 != 3) {
                if ((pos-11) / 4 == k/4) {
                    if (get(s.a, pos+1) == null) {
                        var new = s; new.a[k] = pos + 1; new.cost += costOf(k, 1);
                        try list.append(new);
                    }
                }
            }
        }
        
        
        // Top of a room
        if (pos >= 11 and (pos-11) % 4 == 0) {
            const hall_pos: u8 = switch ((pos-11)/4) { 0 => 2,  1 => 4,  2 => 6,  else => 8};
            
            var left: u8 = 1;
            while (get(s.a, hall_pos - left) == null) : (left += 1) {
                if (hall_pos - left != 0 and hall_pos - left != 10 and (hall_pos-left) % 2 == 0) {continue;}
                var new = s; new.a[k] = hall_pos - left; new.cost += costOf(k, 1 + left);
                try list.append(new);
                if (left >= hall_pos) { break; }
            }
            
            var right: u8 = 1;
            while (get(s.a, hall_pos + right) == null) : (right += 1) {
                if (hall_pos + right != 0 and hall_pos + right != 10 and (hall_pos+right) % 2 == 0) {continue;}
                var new = s; new.a[k] = hall_pos + right; new.cost += costOf(k, 1 + right);
                try list.append(new);
                if (right + hall_pos >= 10) { break; }
            }
        }
        
        // Hallway
        if (pos <= 10) {
            const target: u8 = switch (k/4) { 0 => 11,  1 => 15,  2 => 19,  else => 23};
            const hall_target: u8 = switch (k/4) { 0 => 2,  1 => 4,  2 => 6,  else => 8};
            
            const space_free = (get(s.a, target) == null);
            
            var no_foreigners = true;
            
            var kk: u8 = target+1;
            while (kk < target + 4) : (kk += 1) {
                if (get(s.a, kk)) |at_the_bottom| {
                    if (at_the_bottom / 4 != k / 4) { no_foreigners = false; }
                }
            }
            
            if (space_free and no_foreigners) {
                var p = pos; var can_go = true;
                while (p != hall_target and can_go) {
                    if (pos < hall_target) { p += 1; } else { p -= 1; }
                    can_go = (get(s.a, p) == null);
                }
                
                if (can_go) {
                    var new = s; new.a[k] = target;
                    const n_move = if (pos < hall_target) hall_target - pos + 1 else pos - hall_target + 1;
                    new.cost += costOf(k, n_move);
                    try list.append(new);
                }
            }
        }
        
    }
    
    return list.toOwnedSlice();
}


pub fn unique(s: State) [27]u8 {
    var out = [_]u8 {'.'} ** 27;
    for (s.a) |pos, k| {
        out[pos] = switch (k/4) {0 => 'A', 1 => 'B', 2 => 'C', else => 'D'};
    }
    return out;
}

fn lessThan(a: State, b: State) std.math.Order {
    return std.math.order(a.cost, b.cost);
}

const PQlt = std.PriorityQueue(State, lessThan);


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);

    var start = State {.a = .{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, .cost = 0};

    var pos: u8 = 11;
    while (pos <= 26) : (pos += 1) {
        const line = switch ((pos - 11) % 4) {
            0    => lines[2],
            1    => "  #D#C#B#A#  ",
            2    => "  #D#B#A#C#  ",
            else => lines[3],
        };
        const c = switch ((pos - 11) / 4) {
            0 => line[3],
            1 => line[5],
            2 => line[7],
            else   => line[9],
        };
        var i: usize = 4*(c - 'A');
        while (start.a[i] != 0) { i += 1; }
        start.a[i] = pos;
    }
    
    var queue = PQlt.init(allocator);
    try queue.add(start);
    
    var seen = std.AutoHashMap([27]u8, void).init(allocator);
    var k: usize = 0;
    
    while (queue.removeOrNull()) |s| {
        const un = unique(s);
        if (seen.contains(un)) { continue; }
        try seen.put(un, undefined);
        
        if (std.mem.eql(u8, un[0..], "...........AAAABBBBCCCCDDDD")) {
            print("Part 2: {}\n", .{s.cost});
            break; 
        }
        
        for (try next(s, allocator)) |new_state| {
            try queue.add(new_state);
        }
    }
}


