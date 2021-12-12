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


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test.txt", allocator);

    var part1: u64 = 0;
    
    var grid: [10][10]u8 = undefined;
    for (lines) |line, y| { for (line) |c, x| {
        grid[y][x] = c - '0';
    }}

    var step: u64 = 0;
    while (step < 10000) : (step += 1) {
        //~ print("=== {} ===\n", .{step});
        var stack: [100]i16 = undefined;
        var k: u8 = 0;
        var flashes: u8 = 0;
        
        // Each cell +1
        var new_grid: [10][10]u8 = undefined;
        for (grid) |line, y| {
            for (line) |oct, x| {
                //~ print("{}", .{oct});
                new_grid[y][x] = oct + 1;
                if (oct >= 9) {stack[k] = @intCast(i16, 10*y + x); k += 1;}
            }
            //~ print("\n", .{});
        }
        
        // Unstacking the flashes
        while (k > 0) {
            part1 += 1;
            flashes += 1;
            k -= 1;
            const y = @divTrunc(stack[k], 10);
            const x = @rem(stack[k], 10);
            
            
            var xx: i16 = x-1; while (xx <= x+1) : (xx += 1) {
            var yy: i16 = y-1; while (yy <= y+1) : (yy += 1) {
                if (xx < 0 or xx > 9 or yy < 0 or yy > 9 or (x == xx and y == yy)) {continue;}
                const xxx = @intCast(usize, xx);
                const yyy = @intCast(usize, yy);
                new_grid[yyy][xxx] += 1;
                if (new_grid[yyy][xxx] == 10) { stack[k] = 10*yy + xx; k += 1;}
            }}
        }
        
        for (new_grid) |line, y| { for (line) |oct, x| {
            grid[y][x] = if (oct >= 10) 0 else oct;
        }}
        //~ print("\n", .{});
        
        if (step == 99) {print("Part 1: {}\n", .{part1});}
        if (flashes == 100) {print("Part 2: {}\n", .{step+1}); break;}
    }
}


