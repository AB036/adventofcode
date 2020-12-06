const std = @import("std");

const print = std.debug.print;

pub fn read_groups(path: []const u8, allocator: *std.mem.Allocator) ![][]const u8 {
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

    var groups = try read_groups("input.txt", allocator);
    //var groups = try read_groups("test.txt", allocator);

    var answer: u32 = 0;
    var answer2: u32 = 0;
    
    for (groups) |group| {
        var questions = [_]bool{false} ** 26;  // using arrays, bitmask could have worked too
        var questions2 = [_]bool{true} ** 26;
        var ite = std.mem.split(group, "\n");
        while (ite.next()) |line| {
            var this_person_questions = [_]bool{false} ** 26;
            for (line) |char| {
                this_person_questions[char - 'a'] = true;
            }
            var k: usize = 0;
            while (k < 26) : (k += 1) {
                if (this_person_questions[k]) {questions[k] = true;}
                else {questions2[k] = false;}
            }
        }
        var k: usize = 0;
        while (k < 26) : (k += 1){
            if (questions[k]) {answer += 1;}
            if (questions2[k]) {answer2 += 1;}
        }
    }
    print("Part 1: {}\n", .{answer});
    print("Part 2: {}\n", .{answer2});
}


