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
    while (iterator.next()) |token| { try list.append(token); }

    return list.toOwnedSlice();
}


const Tile = struct {
    id: u32,
    t: [][]const u8,
    flipped: bool,
    rot: u8,
};


const Link = struct {
    other: usize,
    a: u8,
    b: u8,
    flip: bool,
};


pub fn flip10(x: u16) u16 {
    var y: u16 = 0;
    var k: u4 = 0;
    while (k < 10) : (k += 1) {
        if (x & (@intCast(u16,1) << k) != 0) { y += @intCast(u16,1) << (9-k);}
    }
    return y;
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var input = try read_lines("input.txt", allocator);
    //var input = try read_lines("test.txt", allocator);

    const n_tiles: usize = input.len;
    const n: usize = std.math.sqrt(n_tiles);

    var tiles = std.ArrayList(Tile).init(allocator);
    var sides = std.ArrayList([4]u16).init(allocator);
    for (input) |tile_str| {
        var it = std.mem.split(tile_str, "\n");
        const line0 = it.next().?;
        const tile_id = try std.fmt.parseInt(u32, line0[5 .. line0.len-1], 10);
        var T = Tile{ .id = tile_id, .t=undefined, .flipped = false, .rot = 0};

        var list = std.ArrayList([]const u8).init(allocator);
        while (it.next()) |line| { try list.append(line); }
        T.t = list.toOwnedSlice();
        try tiles.append(T);

        var up: u16 = 0;
        var down: u16 = 0;
        var left: u16 = 0;
        var right: u16 = 0;
        var k: u4 = 0; while (k < 10) : (k += 1) {
            if (T.t[0][k] == '#')   { up    += @intCast(u16,1) << k;}
            if (T.t[9][9-k] == '#') { down  += @intCast(u16,1) << k;}
            if (T.t[9-k][0] == '#') { left  += @intCast(u16,1) << k;}
            if (T.t[k][9] == '#')   { right += @intCast(u16,1) << k;}
        }
        try sides.append(.{up,right,down,left});
    }

    var links = std.ArrayList([]Link).init(allocator);
    
    var t: usize = undefined;
    var rot: u8 = 0;
    var flipped = false;
    
    var answer1: u64 = 1;
    var i: usize = 0; while (i < n_tiles) : (i += 1) {
        var llinks = std.ArrayList(Link).init(allocator);
        var s: u8 = 0; while (s < 4) : (s += 1) {
            const side = sides.items[i][s];
            const flip = flip10(side);

            var j: usize = 0; while (j < n_tiles) : (j += 1) {
                if (i == j) {continue;}
                var ss: u8 = 0; while (ss < 4) : (ss += 1) {
                    if (flip == sides.items[j][ss]) {
                        var link = Link {.other = j, .a = s, .flip = false, .b = ss};
                        try llinks.append(link);
                    }
                    else if (side == sides.items[j][ss]) {
                        var link = Link {.other = j, .a = s, .flip = true, .b = ss};
                        try llinks.append(link);
                    }
                }
            }
        }
        if (llinks.items.len == 2) {
            answer1 *= tiles.items[i].id;
            t = i;
            if ((4 + llinks.items[1].a - llinks.items[0].a) % 4 == 1) {
                rot = 0;
                while ((llinks.items[0].a + rot) % 4 != 1) {rot += 1;}
            }
            else {
                rot = 0;
                while ((llinks.items[1].a + rot) % 4 != 1) {rot += 1;}
                //flipped = true;
            }
        }
        try links.append(llinks.toOwnedSlice());
    }
    print("Part 1: {}\n\n", .{answer1});
    tiles.items[t].rot = rot;
    tiles.items[t].flipped = flipped;
    var right_side: u8 = (4 + 1 - rot) % 4;
    var bottom_side: u8 = (right_side + 1) % 4;


    var line_first_tile = t;
    var pic = std.AutoHashMap([2]usize, u8).init(allocator);

    // fill the whole grid
    // THIS WAS TEDIOUS
    var y: usize = 0; while (y < 8*n) : (y += 8) {

        // find the tile at the bottom of the current one
        if (y != 0) {
            t = line_first_tile;
            for (links.items[t]) |link| {
                print("  --> {} {}\n", .{link, bottom_side});
                if (link.a  == bottom_side) {
                    var new_flip = tiles.items[t].flipped;
                    if (link.flip) {new_flip = !new_flip;}
                    var new_rot = (4 - link.b) % 4;
                    t = link.other;
                    tiles.items[t].flipped = new_flip;
                    tiles.items[t].rot = new_rot;
                    bottom_side = (link.b + 2) % 4;
                    for (links.items[t]) |link2| {
                        if ((4 + link2.a - bottom_side) % 2 == 1) {right_side = link2.a;}
                    }
                    break;
                }
            }
            else {unreachable;}
            line_first_tile = t;
        }
        
        var x: usize = 0; while (x < 8*n) : (x += 8) {

            // find the tile at the right of the current one
            if (x != 0) {
                for (links.items[t]) |link| {
                    print("  --> {} {}\n", .{link, right_side});
                    if (link.a  == right_side) {
                        var new_flip = tiles.items[t].flipped;
                        if (link.flip) {new_flip = !new_flip;}
                        var new_rot = (4 + 1 - link.b) % 4;
                        t = link.other;
                        tiles.items[t].flipped = new_flip;
                        tiles.items[t].rot = new_rot;
                        right_side = (link.b + 2) % 4;
                        break;
                    }
                }
                else {unreachable;}
            }

            print("Tile:{} rot:{} flip:{}\n", .{t, tiles.items[t].rot, tiles.items[t].flipped});
            
            var dx: usize = 0; while (dx < 8) : (dx += 1) {
            var dy: usize = 0; while (dy < 8) : (dy += 1) {
                var xx = if (tiles.items[t].flipped) (7-dx) else dx; var yy = dy;
                var rrot = tiles.items[t].rot;
                while (rrot > 0) : (rrot -= 1) { const temp = yy; yy = 7- xx; xx = temp; }
                try pic.put(.{x+dx, y+dy}, tiles.items[t].t[1+yy][1+xx]);
            }}
        }
        print("\n", .{});
    }

    const SEA_MONSTER = 
         \\                  # 
         \\#    ##    ##    ###
         \\ #  #  #  #  #  #   
         ;

    var monster = std.ArrayList([2]usize).init(allocator);
    var monster_ite = std.mem.split(SEA_MONSTER, "\n");
    var sy: usize = 0;
    while (monster_ite.next()) |line| : (sy += 1) {
        for (line) |char, sx| {
            if (char == '#') {try monster.append(.{sx,sy});}
        }
    }

    var kk: u8 = 0;
    while (kk < 8) : (kk += 1) {
        var grid = std.AutoHashMap([2]usize, u8).init(allocator);
        const rotrot: u8 = kk % 4;
        const flipflip: bool = kk >= 5;
        var FOUND_THE_MONSTERS = false;

        y = 0;
        while (y < 8*n) : (y += 1) {
            var x: usize = 0;
            while (x < 8*n) : (x += 1) {
                var xx = x; var yy = y;
                if (flipflip) {xx = 8*n - 1 - xx;}
                var rrot = rotrot;
                while (rrot > 0) : (rrot -= 1) { const temp = yy; yy = 8*n-1- xx; xx = temp; }
                try grid.put(.{xx,yy}, pic.get(.{x,y}).?);
            }
        }
        
        y = 0;
        while (y < 8*n) : (y += 1) {
            var x: usize = 0;
            while (x < 8*n) : (x += 1) {
                for (monster.items) |coords| {
                    const xxx = x + coords[0];
                    const yyy = y + coords[1];
                    if (xxx >= 8*n or yyy >= 8*n or grid.get(.{xxx,yyy}).? != '#') {break;}
                }
                else {
                    for (monster.items) |coords| {
                        try grid.put(.{x + coords[0], y + coords[1]}, 'O');
                        FOUND_THE_MONSTERS = true;
                    }
                }
            }
        }

        if (!FOUND_THE_MONSTERS) {continue;}
    
        var sum: u32 = 0;
        y = 0;
        while (y < 8*n) : (y += 1) {
            var x: usize = 0;
            while (x < 8*n) : (x += 1) {
                const WATER = grid.get(.{x,y}).?;
                print("{c}", .{WATER});
                if (WATER == '#') {sum += 1;}
                if ((x+1) % 8 == 0) {print(" ", .{});}
            }
            print("\n", .{});
            if ((y+1) % 8 == 0) {print("\n", .{});}
        }
        
        grid.clearAndFree();
        print("Part 2: {}\n", .{sum});
    }
    
}


