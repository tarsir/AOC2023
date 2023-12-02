const std = @import("std");

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = &gp.allocator();
    const contents = try getInput("./input.txt", allocator.*);
    defer allocator.free(contents);
    var iter = std.mem.split(u8, contents, "\n");

    var result: u32 = 0;
    while (iter.next()) |line| {
        var first_int: u32 = 0;
        var last_int: u32 = 0;
        var line_iter = std.mem.window(u8, line, 1, 1);

        while (line_iter.next()) |byte| {
            first_int = std.fmt.parseInt(u16, byte, 10) catch continue;
            break;
        }

        var line_reverse: [80]u8 = undefined;
        std.mem.copy(u8, &line_reverse, line);
        std.mem.reverse(u8, &line_reverse);
        var rev_line_iter = std.mem.window(u8, &line_reverse, 1, 1);
        while (rev_line_iter.next()) |byte| {
            last_int = std.fmt.parseInt(u16, byte, 10) catch continue;
            break;
        }
        var combined: [2]u8 = undefined;
        const combined_str = try std.fmt.bufPrint(&combined, "{d}{d}", .{ first_int, last_int });
        const combined_parsed = try std.fmt.parseInt(u32, combined_str, 10);
        result += combined_parsed;
    }
    std.log.info("{d}", .{result});
}

pub fn getInput(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const absolute_path = try std.fs.realpath(file_path, &path_buffer);
    const file = try std.fs.openFileAbsolute(absolute_path, .{});
    defer file.close();
    const buffer_size = 50000;
    return try file.readToEndAlloc(allocator, buffer_size);
}

test "simple test" {
    const contents = try getInput("./test.txt", std.testing.allocator);
    defer std.testing.allocator.free(contents);
}
