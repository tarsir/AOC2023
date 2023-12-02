const std = @import("std");

const GameOptions = struct {
    blue: i32,
    red: i32,
    green: i32,
};

const MinimalCubes = struct {
    blue: u32 = 0,
    red: u32 = 0,
    green: u32 = 0,
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = &gp.allocator();
    const contents = try getInput("./input.txt", allocator.*);
    defer allocator.free(contents);
    var iter = std.mem.split(u8, contents, "\n");

    const gameOptions = GameOptions{
        .red = 12,
        .blue = 14,
        .green = 13,
    };
    var result: i32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const res = try validGame(line, gameOptions);
        result += res;
    }
    std.log.info("{d}", .{result});
}

pub fn minimalCubesForGame(game_record: []const u8) !u32 {
    var parts = std.mem.split(u8, game_record, ":");
    _ = parts.next().?;
    const reveals = parts.next().?;
    var reveal_parts = std.mem.split(u8, reveals, ";");
    var minimal_cubes = MinimalCubes{};

    while (reveal_parts.next()) |reveal| {
        var balls = std.mem.split(u8, reveal, ",");
        while (balls.next()) |ball| {
            const trimmed = std.mem.trim(u8, ball, " ");
            if (ball.len == 0) continue;
            var ball_parts = std.mem.split(u8, trimmed, " ");
            const c_count = ball_parts.next().?;
            std.debug.print("{s}\n", .{trimmed});
            const count: u32 = try std.fmt.parseUnsigned(u32, c_count, 10);
            const color = ball_parts.next().?;
            if (std.mem.eql(u8, color, "red")) {
                if (minimal_cubes.red < count) minimal_cubes.red = count;
            }
            if (std.mem.eql(u8, color, "blue")) {
                if (minimal_cubes.blue < count) minimal_cubes.blue = count;
            }
            if (std.mem.eql(u8, color, "green")) {
                if (minimal_cubes.green < count) minimal_cubes.green = count;
            }
        }
    }
    return minimal_cubes.red * minimal_cubes.blue * minimal_cubes.green;
}

pub fn validGame(game_record: []const u8, opts: GameOptions) !i32 {
    var parts = std.mem.split(u8, game_record, ":");
    const game_id = parts.next().?;
    const reveals = parts.next().?;
    var reveal_parts = std.mem.split(u8, reveals, ";");
    while (reveal_parts.next()) |reveal| {
        var balls = std.mem.split(u8, reveal, ",");
        while (balls.next()) |ball| {
            const trimmed = std.mem.trim(u8, ball, " ");
            if (ball.len == 0) continue;
            var ball_parts = std.mem.split(u8, trimmed, " ");
            const c_count = ball_parts.next().?;
            const count = try std.fmt.parseInt(i32, c_count, 10);
            const color = ball_parts.next().?;
            if (std.mem.eql(u8, color, "red")) {
                if (opts.red < count) return 0;
            }
            if (std.mem.eql(u8, color, "blue")) {
                if (opts.blue < count) return 0;
            }
            if (std.mem.eql(u8, color, "green")) {
                if (opts.green < count) return 0;
            }
        }
    }
    var id_parts = std.mem.split(u8, game_id, " ");
    _ = id_parts.next();
    return std.fmt.parseInt(i32, id_parts.next().?, 10);
}

pub fn getInput(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const absolute_path = try std.fs.realpath(file_path, &path_buffer);
    const file = try std.fs.openFileAbsolute(absolute_path, .{});
    defer file.close();
    const buffer_size = 50000;
    return try file.readToEndAlloc(allocator, buffer_size);
}

test "example" {
    const contents = try getInput("./test.txt", std.testing.allocator);
    defer std.testing.allocator.free(contents);

    var iter = std.mem.split(u8, contents, "\n");
    const gameOptions = GameOptions{
        .red = 12,
        .blue = 14,
        .green = 13,
    };
    var result: i32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const res = try validGame(line, gameOptions);
        result += res;
    }
    try std.testing.expectEqual(result, 8);
}

test "part 2" {
    const contents = try getInput("./input.txt", std.testing.allocator);
    defer std.testing.allocator.free(contents);

    var iter = std.mem.split(u8, contents, "\n");
    var result: u32 = 0;
    while (iter.next()) |line| {
        if (line.len == 0) break;
        const res = try minimalCubesForGame(line);
        result += res;
    }
    std.debug.print("{d}", .{result});
}
