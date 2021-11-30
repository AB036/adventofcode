const std = @import("std");
const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.split(trimmed, "\n\n");
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

    var rules = std.ArrayList([4]u64).init(allocator);
    var dep_rule_indices = std.ArrayList(usize).init(allocator);
    var it_rules = std.mem.split(lines[0], "\n");
    var i: usize = 0;
    while (it_rules.next()) |rule| : (i += 1) {
        var dotdot: usize = 0;
        var dash1: usize = 0;
        var rrr: usize = 0;
        var dash2: usize = 0;
        for (rule) |char, k| {
            if (char == ':') {dotdot = k;}
            if (char == '-' and dash1 == 0) {dash1 = k;}
            if (char == '-' and dash1 != 0) {dash2 = k;}
            if (char == 'o' and rule[k+1] == 'r' and rule[k+2] == ' ') {rrr = k+1;}
        }
        const a = try std.fmt.parseInt(u64, rule[dotdot+2 .. dash1], 10);
        const b = try std.fmt.parseInt(u64, rule[dash1+1 .. rrr-2], 10);
        const c = try std.fmt.parseInt(u64, rule[rrr+2 .. dash2], 10);
        const d = try std.fmt.parseInt(u64, rule[dash2+1 ..], 10);
        try rules.append(.{a,b,c,d});

        if (std.mem.eql(u8, rule[0..9], "departure")) { try dep_rule_indices.append(i); }
    }

    const ur_ticket_str = lines[1][13..];
    var ite_urt = std.mem.split(ur_ticket_str, ",");
    var n: usize = 0;
    var ur_ticket = std.ArrayList(u64).init(allocator);
    while (ite_urt.next()) |value_str| : (n += 1) {
        try ur_ticket.append(try std.fmt.parseInt(u64, value_str, 10));
    }
    var impossible = std.AutoHashMap([2]usize, void).init(allocator);

    var sum: u64 = 0;
    var it_tickets = std.mem.split(lines[2], "\n");
    _ = it_tickets.next(); // skip first line
    while (it_tickets.next()) |ticket| {
        var ite = std.mem.split(ticket, ",");
        var valid: bool = true;
        while (ite.next()) |value_str| {
            const value = try std.fmt.parseInt(u64, value_str, 10);
            for (rules.items) |r| {
                if ((r[0] <= value and value <= r[1]) or (r[2] <= value and value <= r[3]))
                {break;}
            }
            else { // no rule matched the value; ticket is invalid
                sum += value;
                valid = false;
            }
        }
        if (!valid) {continue;} // skip invalid tickets for part 2

        ite = std.mem.split(ticket, ",");
        var k: usize = 0;
        while (ite.next()) |value_str| : (k += 1) {
            const value = try std.fmt.parseInt(u64, value_str, 10);
            for (rules.items) |r,ii| {
                if ((r[0] > value or value > r[1]) and (r[2] > value or value > r[3]))
                { try impossible.put(.{ii,k}, undefined); }
            }
        }
    }
    print("Part 1: {}\n", .{sum});

    // Strategy: find rules where there's only one possibility, repeat
    var map = std.AutoHashMap(usize, usize).init(allocator);
    var something_happened: bool = true;
    while (something_happened) {
        something_happened = false;
        var rule_i: usize = 0;
        while (rule_i < n) : (rule_i += 1) {
            if (map.contains(rule_i)) {continue;}
            var the_one: usize = n+10;
            var pos: usize = 0;
            while (pos < n) : (pos += 1) {
                if (!impossible.contains(.{rule_i, pos})) {
                    if (the_one != n+10) {break;}
                    the_one = pos;
                }
            }
            else {
                try map.put(rule_i, the_one);
                something_happened = true;
                var rule_j: usize = 0;
                while (rule_j < n) : (rule_j += 1) {
                    try impossible.put(.{rule_j, the_one}, undefined);
                }
            }
        }
    }

    var product: u64 = 1;
    for (dep_rule_indices.items) |dri| { product *= ur_ticket.items[map.get(dri).?]; }
    print("Part 2: {}\n", .{product});
}


