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


pub fn order_str(context: void, a: []const u8, b: []const u8) bool {
    const n = std.math.min(a.len, b.len);
    var k: usize = 0;
    while (k < n) : (k += 1) {
        if (a[k] != b[k]) { return a[k] < b[k]; }
    }
    return a.len <= b.len;
}


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var input = try read_lines("input.txt", allocator);
    //var input = try read_lines("test.txt", allocator);

    // map [allergen] [possible_ingredient]
    var map = std.StringHashMap(std.StringHashMap(void)).init(allocator);
    var all_ing = std.StringHashMap(u32).init(allocator);

    for (input) |line| {
        var ite = std.mem.split(line, " (contains ");
        const ing = ite.next().?;
        var aller = ite.next().?;
        aller = aller[0 .. aller.len - 1];

        var ings = std.StringHashMap(void).init(allocator);
        defer ings.clearAndFree();
        
        var ite45 = std.mem.split(ing, " ");
        while (ite45.next()) |iii| {
            if (all_ing.contains(iii)) { try all_ing.put(iii, all_ing.get(iii).? + 1); }
            else { try all_ing.put(iii, 1); }
            try ings.put(iii, undefined);
        }

        var ite77 = std.mem.split(aller, ", ");
        while (ite77.next()) |al| {
            if (!map.contains(al)) {
                var new_map = std.StringHashMap(void).init(allocator);
                var ite_ings = ings.iterator();
                while (ite_ings.next()) |iii| { try new_map.put(iii.key, undefined); }
                try map.put(al, new_map);
            }
            else {
                var ite_ings = map.get(al).?.iterator();
                var to_remove = std.ArrayList([]const u8).init(allocator);
                defer to_remove.deinit();
                while (ite_ings.next()) |kv| {
                    if (!ings.contains(kv.key)) {try to_remove.append(kv.key);}
                }
                for (to_remove.items) |rm| { _ = map.get(al).?.remove(rm); }
            }
        }
    }

    var sum: u32 = 0;
    var ite89 = all_ing.iterator();
    while (ite89.next()) |ing| {
        var ite55 = map.iterator();
        while (ite55.next()) |al| {
            if (al.value.contains(ing.key)) {break;}
        }
        else { sum += ing.value;}
    }
    print("Part 1: {}\n", .{sum});

    var association = std.StringHashMap([]const u8).init(allocator);
    var allergens_list = std.ArrayList([]const u8).init(allocator);

    var something_changed = true;
    while (something_changed) {
        something_changed = false;
        var ite_map = map.iterator();
        while (ite_map.next()) |kv| {
            const al = kv.key;
            var ite_ing = kv.value.iterator();
            var n: u32 = 0;
            var ing: []const u8 = undefined;
            while (ite_ing.next()) |kv2| {
                ing = kv2.key;
                n += 1;
            }
            if (n == 1) {
                try association.put(al, ing);
                try allergens_list.append(al);
                var ite22 = map.iterator();
                while (ite22.next()) |kv3| { _ = kv3.value.remove(ing); }
                something_changed = true;
                break;
            }
        }
    }

    print("Part 2: ", .{});
    var sorted_al = allergens_list.toOwnedSlice();
    std.sort.sort([]const u8, sorted_al, {}, order_str);
    for (sorted_al) |al| { print("{},", .{association.get(al).?}); }
    print(" <- Remove the last comma lol\n", .{});
    
}


