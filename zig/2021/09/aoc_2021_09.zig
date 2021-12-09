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

// This is a tuple alright
pub fn coords(x:u64, y:u64) u64 { return 10000*y + x; }

const list_u64 = std.SinglyLinkedList(u64);

pub fn prepend(list: *list_u64, data: u64, allocator: *std.mem.Allocator) !void {
    const new_node_ptr = try allocator.create(list_u64.Node);
    new_node_ptr.* = list_u64.Node{.data = data};
    list.prepend(new_node_ptr);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var map = std.AutoHashMap(u64, u8).init(allocator);
    for (lines) |line, y| {
        for (line) |c, x| {
            const val = c - '0';
            try map.put(coords(x,y), val);
        }
    }
    
    const Y: u64 = lines.len;
    const X: u64 = lines[0].len;
    var part1: u64 = 0;
    var basin_sizes = std.ArrayList(u64).init(allocator);
    
    var y: u64 = 0;
    while (y < Y) : (y += 1) {
        var x: u64 = 0;
        while (x < X) : (x += 1) {
            const val = map.get(coords(x,y)).?;
            
            const left = if (x > 0) (map.get(coords(x-1,y)) orelse 10) else 10;
            const right = map.get(coords(x+1,y)) orelse 10;
            const down = map.get(coords(x,y+1)) orelse 10;
            const up = if (y > 0) (map.get(coords(x,y-1)) orelse 10) else 10;
            
            if (val < left and val < right and val < down and val < up) {
                part1 += val + 1;
                
                var seen = std.AutoHashMap(u64, void).init(allocator);
                defer seen.clearAndFree();
                
                var list = list_u64 {};
                var first_node = list_u64.Node{ .data = coords(x,y) };
                list.prepend(&first_node);
                
                while (list.popFirst()) |node| {
                    if (seen.contains(node.data)) {continue;}
                    try seen.put(node.data, undefined);
                    
                    const node_x = node.data % 10000;
                    const node_y = node.data / 10000;
                    
                    const n_left = if (node_x > 0) (map.get(coords(node_x-1, node_y)) orelse 10) else 10;
                    const n_right = map.get(coords(node_x+1, node_y)) orelse 10;
                    const n_down = map.get(coords(node_x, node_y+1)) orelse 10;
                    const n_up = if (node_y > 0) (map.get(coords(node_x, node_y-1)) orelse 10) else 10;
                    
                    if (n_left < 9) {try prepend(&list, coords(node_x-1, node_y), allocator);}
                    if (n_right < 9) {try prepend(&list, coords(node_x+1, node_y), allocator);}
                    if (n_down < 9) {try prepend(&list, coords(node_x, node_y+1), allocator);}
                    if (n_up < 9) {try prepend(&list, coords(node_x, node_y-1), allocator);}
                }
                try basin_sizes.append(seen.count());
            }
        }
    }
    
    var sizes = basin_sizes.toOwnedSlice();
    std.sort.sort(u64, sizes, {}, comptime std.sort.asc(u64));
    
    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{sizes[sizes.len - 1]*sizes[sizes.len - 2]*sizes[sizes.len - 3]});

}


