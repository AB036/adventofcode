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


const Node = struct {x: u32, y: u32, cost: u32};

fn lessThan(a: Node, b: Node) std.math.Order {
    return std.math.order(a.cost, b.cost);
}

const PQlt = std.PriorityQueue(Node, lessThan);


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);
    
    var grid = std.AutoHashMap([2]u32, u32).init(allocator);
    
    var Y: u32 = 0; while (Y < 5) : (Y += 1) {
    var X: u32 = 0; while (X < 5) : (X += 1) {
        var y: u32 = 0; while (y < lines.len) : (y += 1) {
        var x: u32 = 0; while (x < lines[0].len) : (x += 1) {
            var val = X + Y + lines[y][x] - '0';
            if (val > 9) {val -= 9;}
            try grid.put(.{@intCast(u32, lines[0].len*X) + x, @intCast(u32, lines.len*Y) + y}, val);
        }}
    }}
    
    const x_max: u32 = @intCast(u32, 5*lines[0].len) - 1;
    const y_max: u32 = @intCast(u32, 5*lines.len) - 1;

    var queue = PQlt.init(allocator);
    try queue.add(.{.x=0, .y=0, .cost=0});
    
    var seen = std.AutoHashMap([2]u32, void).init(allocator);
    
    while (queue.removeOrNull()) |node| {
        if (node.y == y_max and node.x == x_max) {
            print("Part 2: {}\n", .{node.cost});
            break;
        }
        
        if (seen.contains(.{node.x, node.y})) { continue; }
        try seen.put(.{node.x, node.y}, undefined);
        
        if (node.x > 0) {
            try queue.add(.{.x=node.x-1, .y=node.y, .cost=node.cost + grid.get(.{node.x-1, node.y}).?});
        }
        if (node.x < x_max) {
            try queue.add(.{.x=node.x+1, .y=node.y, .cost=node.cost + grid.get(.{node.x+1, node.y}).?});
        }
        if (node.y > 0) {
            try queue.add(.{.x=node.x, .y=node.y-1, .cost=node.cost + grid.get(.{node.x, node.y-1}).?});
        }
        if (node.y < y_max) {
            try queue.add(.{.x=node.x, .y=node.y+1, .cost=node.cost + grid.get(.{node.x, node.y+1}).?});
        }
    }
}


