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

const ListStr = std.ArrayList([]const u8);
const Node = struct {
    name: []const u8,
    prev: ?*Node,
    small_cave_twice: bool
};
const List = std.SinglyLinkedList(Node);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("bigboy.txt", allocator);
    //~ var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var map = std.StringHashMap(*ListStr).init(allocator);
    
    for (lines) |line| {
        var ite = std.mem.split(u8, line, "-");
        const A = ite.next().?;
        const B = ite.next().?;
        
        if (! map.contains(A)) {
            const ptr = try allocator.create(ListStr);
            ptr.* = std.ArrayList([]const u8).init(allocator);
            try map.put(A, ptr);
        }
        if (! map.contains(B)) {
            const ptr = try allocator.create(ListStr);
            ptr.* = std.ArrayList([]const u8).init(allocator);
            try map.put(B, ptr);
        }
        
        try map.get(A).?.append(B);
        try map.get(B).?.append(A);
    }

    var part2: u64 = 0;
    
    var list = List {};
    var first_node = List.Node{ .data = .{.name = "start", .prev = null, .small_cave_twice = false} };
    list.prepend(&first_node);
    
    while (list.popFirst()) |nnn| {
        const node = nnn.data;
        if (std.mem.eql(u8, node.name, "end")) {
            part2 += 1;
            continue;
        }
        //~ print("\n===== {s}\n", .{node.name});
        
        const neighbors = map.get(node.name).?;
        for (neighbors.items) |next_name| {
            //~ print("---- next: {s}\n", .{next_name});
            const ptr = try allocator.create(List.Node);
            ptr.* = List.Node{.data = Node {
                .name = next_name, .prev = &(nnn.data), .small_cave_twice = node.small_cave_twice
            }};
            
            // uppercases can be visited multiple times
            if ('A' <= next_name[0] and next_name[0] <= 'Z') { list.prepend(ptr); continue; }
            
            // Dont not visit start again
            if (std.mem.eql(u8, next_name, "start")) {continue;}
            
            var i_have_seen_this_name: u8 = 0;
            var prev = node.prev;
            while (prev) |previous_node| {
                //~ print("prev: {s}\n", .{previous_node.name});
                if (std.mem.eql(u8, next_name, previous_node.name)) {
                    i_have_seen_this_name += 1;
                    if (i_have_seen_this_name >= 2) {break;}
                }
                prev = previous_node.prev;
            }
            
            if (!node.small_cave_twice and i_have_seen_this_name == 1) {
                ptr.data.small_cave_twice = true;
                list.prepend(ptr);
            }
            else if (i_have_seen_this_name == 0) { list.prepend(ptr); }
            
        }
    }
    print("Part2: {}\n", .{part2});
}


