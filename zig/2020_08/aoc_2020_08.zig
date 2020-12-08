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
    while (iterator.next()) |token| {
        try list.append(token);
    }

    return list.toOwnedSlice();
}


const Opcode = enum {
    acc,
    jmp,
    nop,
};


const Operation = struct {
    code: Opcode,
    param: i64,
};


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var lines = try read_lines("input.txt", allocator);
    //var lines = try read_lines("test.txt", allocator);

    var list = std.ArrayList(Operation).init(allocator);
    for (lines) |line| {
        var ite = std.mem.split(line, " ");
        const opcode_raw = ite.next().?;
        const param_raw = ite.next().?;
        const opcode = if (std.mem.eql(u8, opcode_raw, "acc")) Opcode.acc
                  else if (std.mem.eql(u8, opcode_raw, "jmp")) Opcode.jmp
                  else if (std.mem.eql(u8, opcode_raw, "nop")) Opcode.nop
                  else unreachable;
        const param = try std.fmt.parseInt(i64, param_raw, 10);
        try list.append(Operation {.code = opcode, .param=param});
    }
    const op = list.toOwnedSlice();

    var accu: i64 = 0;
    var i: usize = 0;
    var seen = std.AutoHashMap(usize, void).init(allocator);

    while (i < op.len) {
        if (seen.contains(i)) {break;}
        try seen.put(i, undefined);
        if (op[i].code == Opcode.acc) {
            accu += op[i].param;
            i += 1;
        }
        else if (op[i].code == Opcode.jmp) {
            var i_i64 = @intCast(i64, i) + op[i].param;
            if (i_i64 < 0) {break;}
            i = @intCast(usize, i_i64);
        }
        else if (op[i].code == Opcode.nop) {
            i += 1;
        }
    }
    print("Part 1: {}\n", .{accu});

    var k_jmp: usize = 0;
    while (k_jmp < op.len) : (k_jmp += 1) {
        if (op[k_jmp].code != Opcode.jmp) {continue;}
        accu = 0;
        i = 0;
        seen.clearAndFree();
        while (i < op.len) {
            if (seen.contains(i)) {break;} // seeing the same instruction twice: infinite looping
            try seen.put(i, undefined);
            if (op[i].code == Opcode.acc) {
                accu += op[i].param;
                i += 1;
            }
            else if (op[i].code == Opcode.jmp and i != k_jmp) {
                var i_i64 = @intCast(i64, i) + op[i].param;
                if (i_i64 < 0) {break;}
                i = @intCast(usize, i_i64);
            }
            else if (op[i].code == Opcode.nop or i == k_jmp) {
                i += 1;
            }
        }
        else {print("Part 2: {}\n", .{accu});} // if exiting the while without breaking
    }
    
    
}


