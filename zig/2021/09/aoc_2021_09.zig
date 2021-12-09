const std = @import("std");

const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 99999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    var iterator = std.mem.tokenize(u8, trimmed, "\n");

    var list = std.ArrayList([]const u8).init(allocator);
    while (iterator.next()) |token| {
        try list.append(token);
    }

    return list.toOwnedSlice();
}

const XY = struct {x: u64, y: u64};
const list_xy = std.SinglyLinkedList(XY);

pub fn prepend(list: *list_xy, data: XY, allocator: *std.mem.Allocator) !void {
    const new_node_ptr = try allocator.create(list_xy.Node);
    new_node_ptr.* = list_xy.Node{.data = data};
    list.prepend(new_node_ptr);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    //~ var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);
    var lines = try read_lines("9-4096-2.in", allocator);

    const Y: u64 = lines.len;
    const X: u64 = lines[0].len;
    
    var list_y = std.ArrayList([]u8).init(allocator);
    for (lines) |line| {
        var list_x = std.ArrayList(u8).init(allocator);
        for (line) |c| { try list_x.append(c - '0'); }
        try list_y.append(list_x.toOwnedSlice());
    }
    const map = list_y.toOwnedSlice();
    
    var part1: u64 = 0;
    var basin_sizes = std.ArrayList(u64).init(allocator);
    
    var seen = std.AutoHashMap(XY, void).init(allocator);
    defer seen.clearAndFree();
    
    var y: u64 = 0;
    while (y < Y) : (y += 1) {
        var x: u64 = 0;
        while (x < X) : (x += 1) {
            const val = map[y][x];
            
            const left = if (x > 0) map[y][x-1] else 10;
            const right = if (x < X-1) map[y][x+1] else 10;
            const down = if (y < Y-1) map[y+1][x] else 10;
            const up = if (y > 0) map[y-1][x] else 10;
            
            if (val < left and val < right and val < down and val < up) {
                part1 += val + 1;
                
                var list = list_xy {};
                var first_node = list_xy.Node{ .data = .{.x=x, .y=y} };
                list.prepend(&first_node);
                
                var basin_size: u64 = 0;
                
                while (list.popFirst()) |node| {
                    if (seen.contains(node.data)) {continue;}
                    try seen.put(node.data, undefined);
                    basin_size += 1;
                    
                    const node_x = node.data.x;
                    const node_y = node.data.y;
                    
                    const n_left = if (node_x > 0) map[node_y][node_x-1] else 9;
                    const n_right = if (node_x < X-1) map[node_y][node_x+1] else 9;
                    const n_down = if (node_y < Y-1) map[node_y+1][node_x] else 9;
                    const n_up = if (node_y > 0) map[node_y-1][node_x] else 9;
                    
                    if (n_left != 9) {try prepend(&list, .{.x=node_x-1, .y=node_y}, allocator);}
                    if (n_right != 9) {try prepend(&list, .{.x=node_x+1, .y=node_y}, allocator);}
                    if (n_down != 9) {try prepend(&list, .{.x=node_x, .y=node_y+1}, allocator);}
                    if (n_up != 9) {try prepend(&list, .{.x=node_x, .y=node_y-1}, allocator);}
                }
                try basin_sizes.append(basin_size);
            }
        }
    }
    
    var sizes = basin_sizes.toOwnedSlice();
    std.sort.sort(u64, sizes, {}, comptime std.sort.asc(u64));
    
    print("Part 1: {}\n", .{part1});
    print("Part 2: {}\n", .{sizes[sizes.len - 1]*sizes[sizes.len - 2]*sizes[sizes.len - 3]});

}


