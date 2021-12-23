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


const Cube = struct {on: bool, xmin: i64, xmax: i64, ymin: i64, ymax: i64, zmin: i64, zmax: i64};

pub fn intersection(c1: Cube, c2: Cube) ?Cube {
    const x1 = std.math.max(c1.xmin, c2.xmin);
    const x2 = std.math.min(c1.xmax, c2.xmax);
    const y1 = std.math.max(c1.ymin, c2.ymin);
    const y2 = std.math.min(c1.ymax, c2.ymax);
    const z1 = std.math.max(c1.zmin, c2.zmin);
    const z2 = std.math.min(c1.zmax, c2.zmax);
    
    if (x1 > x2 or y1 > y2 or z1 > z2) { return null; }
    return Cube {.on = true, .xmin=x1, .xmax=x2, .ymin=y1, .ymax=y2, .zmin=z1, .zmax = z2};
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //~ var lines = try read_lines("test2.txt", allocator);

    var cubes = std.ArrayList(Cube).init(allocator);
    
    for (lines) |line| {
        const on = (line[1] == 'n');
        const subline = if (line[1] == 'n') line[3..] else line[4..];
        
        var ite = std.mem.split(u8, subline, ",");
        const xxx = ite.next().?[2..];
        const yyy = ite.next().?[2..];
        const zzz = ite.next().?[2..];
        
        const ix = std.mem.indexOf(u8, xxx, "..").?;
        const iy = std.mem.indexOf(u8, yyy, "..").?;
        const iz = std.mem.indexOf(u8, zzz, "..").?;
        
        const xmin = try std.fmt.parseInt(i64, xxx[0..ix], 10);
        const xmax = try std.fmt.parseInt(i64, xxx[ix+2..], 10);
        const ymin = try std.fmt.parseInt(i64, yyy[0..iy], 10);
        const ymax = try std.fmt.parseInt(i64, yyy[iy+2..], 10);
        const zmin = try std.fmt.parseInt(i64, zzz[0..iz], 10);
        const zmax = try std.fmt.parseInt(i64, zzz[iz+2..], 10);
        
        // FUCK YOU
        // if (xmin < -50 or xmax > 50 or ymin < -50 or ymax > 50 or zmin < -50 or zmax > 50) { continue; }
        
        const cube = Cube {.on = on, .xmin=xmin, .xmax=xmax, .ymin=ymin, .ymax=ymax, .zmin=zmin, .zmax=zmax};
        
        var to_add = std.ArrayList(Cube).init(allocator);
        defer to_add.deinit();
        
        for (cubes.items) |cube2| {
            var inter = intersection(cube, cube2) orelse continue;
            inter.on = ! cube2.on;
            try to_add.append(inter);
        }
        
        for (to_add.items) |cube_to_add| { try cubes.append(cube_to_add); }
        
        if (cube.on) { try cubes.append(cube); }
    }
    
    
    var part1: i64 = 0;
    
    for (cubes.items) |cube| {
        const v = (cube.xmax - cube.xmin + 1) * (cube.ymax - cube.ymin + 1) * (cube.zmax - cube.zmin + 1);
        if (cube.on) { part1 += v; } else { part1 -= v; }
    }
    
    print("Part 1: {}\n", .{part1});

}


