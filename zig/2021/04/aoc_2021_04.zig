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

const Bingo = struct {
    inv_grid: std.AutoHashMap(u8, u8),
    marks: [25]bool = [_]bool{false} ** 25,
    complete: bool = false,
    ignore: bool = false,
    
    pub fn mark(self: *Bingo, number: u8) void {
        const index = self.inv_grid.get(number) orelse return;
        self.marks[index] = true;
        
        const x: u8 = index % 5; var row_complete = true;
        const y: u8 = index / 5; var col_complete = true;
        var d: u8 = 0;
        while (d < 5) : (d += 1) {
            row_complete = row_complete and self.marks[5*d + x];
            col_complete = col_complete and self.marks[5*y + d];
        }
        if (row_complete or col_complete) {self.complete = true;}
    }
    
    pub fn sum_unmarked(self: *Bingo) u32 {
        var sum: u32 = 0;
        var iterator = self.inv_grid.iterator();
        while (iterator.next()) |kv| {
            if (!self.marks[kv.value_ptr.*]) {sum += kv.key_ptr.*;}
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
    
    const first_line = iterator.next().?;  // will parse later

    var bingos = std.ArrayList(*Bingo).init(allocator);
    while (iterator.next()) |grid_text| {
        var inv_grid = std.AutoHashMap(u8, u8).init(allocator);
        var i: u8 = 0;
        var ite2 = std.mem.tokenize(u8, grid_text, "\n");
        while (ite2.next()) |line| {
            var ite3 = std.mem.tokenize(u8, line, " ");
            while (ite3.next()) |number_str| {
                try inv_grid.put(try std.fmt.parseInt(u8, number_str, 10), i);
                i += 1;
            }
        }
        
        const bingo_ptr = try allocator.create(Bingo);
        bingo_ptr.* = Bingo {.inv_grid = inv_grid} ;
        try bingos.append(bingo_ptr);
    }
    
    var n_bingos_left = bingos.items.len;
    
    var ite1 = std.mem.tokenize(u8, first_line, ",");
    while (ite1.next()) |token| {
        const number = try std.fmt.parseInt(u8, token, 10);
        
        for (bingos.items) |bingo| {
            bingo.mark(number);
            if (bingo.complete and !bingo.ignore) {
                if (n_bingos_left == bingos.items.len) {
                    print("Part 1: {}\n", .{bingo.sum_unmarked() * number});
                }
                n_bingos_left -= 1;
                bingo.ignore = true;
                if (n_bingos_left == 0) {
                    print("Part 2: {}\n", .{bingo.sum_unmarked() * number});
                }
            }
        }
    }

}


