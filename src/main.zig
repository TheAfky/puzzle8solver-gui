const std = @import("std");
const App = @import("app.zig").App;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var app = try App.init(allocator, 1.5);
    try app.run();
}
