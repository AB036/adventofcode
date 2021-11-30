const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    //const card_pub_key: u64 = 5764801;
    //const door_pub_key: u64 = 17807724;

    const card_pub_key: u64 = 15335876;
    const door_pub_key: u64 = 15086442;

    var a: u64 = 0;
    var x: u64 = 1;
    while (x != card_pub_key) : (a += 1) { x = (7*x) % 20201227; }

    var key: u64 = 1;
    var k: u64 = 0;
    while (k < a) : (k += 1) {key = (door_pub_key * key) % 20201227;}
    print("Key: {}\n", .{key});
}


