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
    flip: bool,
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
        var T = Tile{ .id = tile_id, .t=undefined, .flip = false, .rot = 0};

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
    var leading_tile: usize = undefined;
    
    var answer1: u64 = 1;
    var i: usize = 0; while (i < n_tiles) : (i += 1) {
        var llinks = std.ArrayList(Link).init(allocator);
        var s: u8 = 0; while (s < 4) : (s += 1) {
            const side = sides.items[i][s];
            const flip = flip10(side);
            var j: usize = 0; while (j < n_tiles) : (j += 1) {
                if (i == j) {continue;}
                var ss: u8 = 0; while (ss < 4) : (ss += 1) {
                    if (side == sides.items[j][ss] or flip == sides.items[j][ss]) {
                        var link = Link {.other = j, .a = s, .flip = false, .b = ss};
                        link.flip = side == sides.items[j][ss];
                        try llinks.append(link);
                    }
                }
            }
        }
        if (llinks.items.len == 2) {
            answer1 *= tiles.items[i].id;
            leading_tile = i;
        }
        try links.append(llinks.toOwnedSlice());
    }
    print("Part 1: {}\n\n", .{answer1});

    // flip and turn the last corner so its connected sides are facing right and down resp.
    {
        var a = links.items[leading_tile][0].a;
        var b = links.items[leading_tile][1].a;
        print("{} {}\n", .{a,b});
        if ( (4 + b - a) % 4 != 1 ) {
            tiles.items[leading_tile].flip = true;
            if (a % 2 == 1) {a = (a + 2) % 4;}
        }
        tiles.items[leading_tile].rot = (4 + 1 - a) % 4;
    }

    var t = leading_tile;
    var right = links.items[t][0].a;
    var down = links.items[t][1].a;

    var pic = std.AutoHashMap([2]usize, u8).init(allocator);

    // assemble the grid
    var y: usize = 0; while (y < n) : (y += 1) {

        if (y != 0) {
            t = leading_tile;
            for (links.items[t]) |link| {
                if (link.a == down) {
                    //print("--> {}\n", .{link});
                    var new_flip = tiles.items[t].flip;
                    if (link.flip) {new_flip = !new_flip;}
                    t = link.other;
                    tiles.items[t].flip = new_flip;
                    down = (link.b + 2) % 4;
                    var target = down;
                    if (new_flip and (target % 2 == 1)) { target = (target + 2) % 4; }
                    tiles.items[t].rot = (4 + 2 - target) % 4;
                    right = (4 + 1 - tiles.items[t].rot) % 4;
                    if (new_flip and (right % 2 == 1)) { right = (right + 2) % 4;}
                    break;
                }
            }
            else {unreachable;}
            leading_tile = t;
        }
        
        var x: usize = 0; while (x < n) : (x += 1) {
            
            if (x != 0) {
                for (links.items[t]) |link| {
                    //print("--> {}\n", .{link});
                    if (link.a == right) {
                        var new_flip = tiles.items[t].flip;
                        if (link.flip) {new_flip = !new_flip;}
                        t = link.other;
                        tiles.items[t].flip = new_flip;
                        right = (link.b + 2) % 4;
                        var target = right;
                        if (new_flip and (target % 2 == 1)) { target = (target + 2) % 4; }
                        tiles.items[t].rot = (4 + 1 - target) % 4;
                        break;
                    }
                }
                else {unreachable;}
            }
            print("{}: rot:{} flip:{}\n", .{t, tiles.items[t].rot, tiles.items[t].flip});

            var dx: usize = 0; while (dx < 8) : (dx += 1) {
            var dy: usize = 0; while (dy < 8) : (dy += 1) {
                var xx = if (tiles.items[t].flip) (7-dx) else dx; var yy = dy;
                var rrot = tiles.items[t].rot;
                while (rrot > 0) : (rrot -= 1) { const temp = xx; xx = 7- yy; yy = temp; }
                try pic.put(.{8*x+xx, 8*y+yy}, tiles.items[t].t[1+dy][1+dx]);
            }}
        }
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
                //if ((x+1) % 8 == 0) {print(" ", .{});}
            }
            print("\n", .{});
            //if ((y+1) % 8 == 0) {print("\n", .{});}
        }
        
        grid.clearAndFree();
        print("Part 2: {}\n", .{sum});
    }
    
}


