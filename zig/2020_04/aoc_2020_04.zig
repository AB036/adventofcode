const std = @import("std");

const print = std.debug.print;

pub fn read_pass(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(path, .{ .read = true });
    defer file.close();

    const file_buffer = try file.readToEndAlloc(allocator, 9999999);
    const trimmed = std.mem.trim(u8, file_buffer, "\n");
    
    var iterator = std.mem.split(trimmed, "\n\n");
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

    var passports = try read_pass("input.txt", allocator);
    //var passports = try read_pass("test.txt", allocator);

    const fields = [_][]const u8{"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"};
    var n_valid: u32 = 0;
    var n_valid2: u32 = 0;
    
    for (passports) |passport| {
        var pass_map = std.StringHashMap([]const u8).init(allocator);
        var ite = std.mem.tokenize(passport, " \n");
        while (ite.next()) |pass_entry| {
            var iter = std.mem.split(pass_entry, ":");
            var field = iter.next().?;
            var value = iter.next().?;
            try pass_map.put(field, value);
        }
        
        var fields_present: u32 = 0;
        for (fields) |field| {
            if (pass_map.contains(field)) {fields_present += 1;}
        }
        if (fields_present != fields.len) {continue;}
        n_valid += 1;

        const byr = std.fmt.parseInt(u32, pass_map.get("byr").?, 10) catch continue;
        if (byr < 1920 or byr > 2002) {continue;}

        const iyr = std.fmt.parseInt(u32, pass_map.get("iyr").?, 10) catch continue;
        if (iyr < 2010 or iyr > 2020) {continue;}

        const eyr = std.fmt.parseInt(u32, pass_map.get("eyr").?, 10) catch continue;
        if (eyr < 2020 or eyr > 2030) {continue;}

        const hgt = pass_map.get("hgt").?;
        if (hgt.len < 3) {continue;}
        const height = std.fmt.parseInt(u32, hgt[0..hgt.len-2], 10) catch continue;
        if (std.mem.eql(u8, hgt[hgt.len-2..], "cm") and !(150 <= height and height <= 193)) {
            continue;}
        if (std.mem.eql(u8, hgt[hgt.len-2..], "in") and !(59 <= height and height <= 76)) {
            continue;}

        const hcl = pass_map.get("hcl").?;
        if (hcl[0] != '#') {continue;}
        if (hcl.len != 7) {continue;}
        _ = std.fmt.parseInt(u32, hcl[1..], 16) catch continue; // try to parse hex

        const ecl = pass_map.get("ecl").?;
        const colors = [_][]const u8{"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
        for (colors) |color| {
            if (std.mem.eql(u8, color, ecl)) {break;}
        }
        else {continue;}

        const pid = pass_map.get("pid").?;
        if (pid.len != 9) {continue;}
        _ = std.fmt.parseInt(u32, pid, 10) catch continue;

        n_valid2 += 1;
    }
    print("Part 1: {}\n", .{n_valid});
    print("Part 2: {}\n", .{n_valid2});
}


