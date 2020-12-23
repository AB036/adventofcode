const std = @import("std");
const print = std.debug.print;

pub fn read_lines(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.split(trimmed, "\n");
    var list = std.ArrayList([]const u8).init(allocator);
    while (iterator.next()) |token| { try list.append(token); }

    return list.toOwnedSlice();
}

const L = std.TailQueue(u32);

const AAAAA = error {
    OutOfMemory,
};

pub fn play(deck1: *std.TailQueue(u32),
            deck2: *std.TailQueue(u32),
            allocator: *std.mem.Allocator) AAAAA!bool {
    var seen = std.AutoHashMap(u32, void).init(allocator);

    while (deck1.len > 0 and deck2.len > 0) {
        // magic hash function
        var hash: u32 = 0;
        var k: u32 = 0;
        var it1 = deck1.last;
        while (it1) |card| : (it1 = card.prev) { hash += k*card.data; k += 79; }
        var it2 = deck2.last;
        while (it2) |card| : (it2 = card.prev) { hash += k*card.data; k += 877;}
        if (seen.contains(hash)) { return true; }
        try seen.put(hash, undefined);
        
        const c1 = deck1.popFirst().?;
        const c2 = deck2.popFirst().?;

        var victory = false;
        if (deck1.len >= c1.data and deck2.len >= c2.data) {
            var deck1_copy = try copy(c1.data, deck1, allocator);
            var deck2_copy = try copy(c2.data, deck2, allocator);
            victory = try play(&deck1_copy, &deck2_copy, allocator);
            //deck1_copy.deinit(); // This doesn't work (please add it Andrew if you read this)
            //deck2_copy.deinit(); // i'll just fill the memory and hope I have enough RAM
        }
        else { victory = c1.data > c2.data; }
        
        if (victory) { deck1.append(c1); deck1.append(c2); }
        else         { deck2.append(c2); deck2.append(c1); }
    }
    
    return deck1.len > 0;
}


pub fn copy(n: u32, tq: *std.TailQueue(u32), allocator: *std.mem.Allocator) !std.TailQueue(u32) {
    var new_tq = L{};
    var ite = tq.first;
    var k: u32 = 0;
    while (ite) |node| : (ite = node.next) {
        const new_node = try allocator.create(L.Node);
        new_node.data = node.data;
        new_tq.append(new_node);
        k += 1; if (k >= n) { break; }
    }
    return new_tq;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var input = try read_lines("input.txt", allocator);
    //var input = try read_lines("test.txt", allocator);

    var cards1 = L{};
    var cards2 = L{};

    var aaaa = true;
    for (input) |line| {
        if (line.len == 0) {aaaa = false; continue;}
        if (line[0] == 'P') {continue;}

        const x: u32 = try std.fmt.parseInt(u32, line, 10);
        const card = try allocator.create(L.Node);
        card.data = x;
        if (aaaa) { cards1.append(card); }
        else { cards2.append(card); }
    }

    var deck1 = try copy(99999999, &cards1, allocator);
    var deck2 = try copy(99999999, &cards2, allocator);
    const victory = try play(&deck1, &deck2, allocator);

    var score: u32 = 0;
    var k: u32 = 1;
    var it1 = deck1.last;
    while (it1) |card| : (it1 = card.prev) {
        if (victory) { score += k*card.data; k += 1; }
    }
    var it2 = deck2.last;
    while (it2) |card| : (it2 = card.prev) {
        if (!victory) { score += k*card.data; k += 1; }
    }
    print("{}\n", .{score});
    
}


