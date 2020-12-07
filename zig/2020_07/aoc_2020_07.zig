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


const Bags = struct {
    n: u32,
    color: []const u8,
};


pub fn count_bags(comptime T: type, map: *T, color: []const u8) u32 {
    var count: u32 = 0;
    var bags = map.get(color) orelse return 1;
    for (bags) |bag| {
        count += if (bag.n == 0) 0
                 else bag.n * count_bags(T, map, bag.color);
    }
    return 1 + count;
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    // Parsing
    var dummy = std.ArrayList(Bags).init(allocator);
    var map = std.StringHashMap([]Bags).init(allocator);
    var bag_inside = std.StringHashMap(@TypeOf(dummy)).init(allocator);
    for (lines) |line| {
        var ite = std.mem.split(line, " bags contain ");
        const color = ite.next().?;
        const rest = ite.next().?;
        var ite2 = std.mem.split(rest, ", ");
        var bags = std.ArrayList(Bags).init(allocator);
        while (ite2.next()) |token| {
            var space: usize = 0;
            while (token[space] != ' ') {space += 1;}
            const n_bags: u32 = if (rest[0] != 'n') try std.fmt.parseInt(u32, token[0..space], 10)
                                else 0;
            var ite3 = std.mem.split(token, " bag");
            const color2 = ite3.next().?[space+1 ..];
            try bags.append(Bags {.n = n_bags, .color = color2});
            var entry = try bag_inside.getOrPutValue(color2, std.ArrayList(Bags).init(allocator));
            try entry.value.append(Bags {.n = n_bags, .color = color});
        }
        try map.put(color, bags.toOwnedSlice());
    }

    // map is a direct mapping of the input
    // bag_inside is the same but reversed

    var seen = std.StringHashMap(void).init(allocator);
    const list_type = std.SinglyLinkedList([]const u8);
    var list = list_type {};
    var nose_attractor = list_type.Node{ .data = "shiny gold" };
    list.prepend(&nose_attractor);

    var answer: u32 = 0;

    while (list.popFirst()) |node| {
        if (seen.contains(node.data)) {continue;}
        try seen.put(node.data, undefined);
        answer += 1;
        var inside = bag_inside.get(node.data) orelse continue;
        for (inside.items) |bags| {
            const new_node_ptr = try allocator.create(list_type.Node);
            new_node_ptr.* = list_type.Node{.data = bags.color};
            list.prepend(new_node_ptr);
        }
    }

    var answer2: u32 = count_bags(@TypeOf(map), &map, "shiny gold");
    print("Part 1: {}\n", .{answer-1});  // minus 1 because the first bag doesn't count
    print("Part 2: {}\n", .{answer2-1}); // same
}


