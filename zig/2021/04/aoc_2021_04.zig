const std = @import("std");

const print = std.debug.print;

pub fn read_input(path: []const u8, allocator: *std.mem.Allocator) !std.mem.SplitIterator(u8) {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    return std.mem.split(u8, trimmed, "\n\n"); // double newline here
}

const XY = struct { x: u8, y: u8 };

const Bingo = struct {
    grid: std.AutoHashMap(u8, XY),
    marks: std.ArrayList(bool),
    
    pub fn mark(self: Bingo, number: u8) void {
        var xy = self.grid.get(number);  // may be null if number isn't in the grid
        if (xy != null) {self.marks.items[5*xy.?.y + xy.?.x] = true;}
    }
    
    pub fn is_complete(self: Bingo) bool {
        var y: u8 = 0;  // check columns
        while (y < 5) : (y += 1) {
            var x: u8 = 0; var complete = true;
            while (x < 5) : (x += 1) {complete = complete and self.marks.items[5*y+x];}
            if (complete) {return true;}
        }
        
        var x: u8 = 0;  // check lines
        while (x < 5) : (x += 1) {
            y = 0; var complete = true;
            while (y < 5) : (y += 1) {complete = complete and self.marks.items[5*y+x];}
            if (complete) {return true;}
        }
        
        return false;
    }
    
    pub fn sum_unmarked(self: Bingo) u32 {
        var sum: u32 = 0;
        var iterator = self.grid.iterator();
        while (iterator.next()) |kv| {
            if (! self.marks.items[5*kv.value_ptr.y + kv.value_ptr.x]) {sum += kv.key_ptr.*;}
        }
        return sum;
    }
};


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var iterator = try read_input("input.txt", allocator);
    //~ var iterator = try read_input("test.txt", allocator);
    
    const first_line = iterator.next().?;
    var ite1 = std.mem.tokenize(u8, first_line, ",");
    var numbers = std.ArrayList(u8).init(allocator);
    while (ite1.next()) |token| {
        try numbers.append(try std.fmt.parseInt(u8, token, 10));
    }

    var bingos = std.ArrayList(Bingo).init(allocator);
    var bingos_done = std.ArrayList(bool).init(allocator);
    while (iterator.next()) |grid_text| {
        var marks = std.ArrayList(bool).init(allocator);
        var map = std.AutoHashMap(u8, XY).init(allocator);
        
        var ite2 = std.mem.tokenize(u8, grid_text, "\n");
        var y: u8 = 0;
        while (ite2.next()) |line| : (y += 1){
            var ite3 = std.mem.tokenize(u8, line, " ");
            var x: u8 = 0;
            while (ite3.next()) |number| : (x += 1){
                try map.put(try std.fmt.parseInt(u8, number, 10), XY {.x = x, .y = y});
                try marks.append(false);
            }
        }
        
        try bingos.append(Bingo {.grid = map, .marks = marks});
        try bingos_done.append(false);
    }
    
    var n_bingos_left = bingos.items.len;
    
    for (numbers.items) |number| {
        for (bingos.items) |bingo, k| {
            bingo.mark(number);
            if (bingo.is_complete() and !bingos_done.items[k]) {
                if (n_bingos_left == bingos.items.len) {
                    print("Part 1: {}\n", .{bingo.sum_unmarked() * number});
                }
                n_bingos_left -= 1;
                bingos_done.items[k] = true;
                if (n_bingos_left == 0) {
                    print("Part 2: {}\n", .{bingo.sum_unmarked() * number});
                }
            }
        }
    }

}


