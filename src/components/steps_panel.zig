const std = @import("std");

const Board = @import("puzzle8solver").Board;

const c = @cImport({
    @cInclude("dcimgui.h");
});

pub const StepsPanel = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    selected_step: usize,
    selected_board: Board(3, 3),
    boards: std.ArrayList(Board(3, 3)),

    pub fn init(allocator: std.mem.Allocator) !Self {
        var self: Self = undefined;
        self.allocator = allocator;
        self.selected_step = 0;
        self.selected_board = Board(3, 3){ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        self.boards = .empty;

        return self;
    }

    pub fn draw(self: *Self, x: f32, y: f32, w: f32, h: f32) void {
        _ = c.ImGui_SetNextWindowPos(.{ .x = x, .y = y }, 0);
        _ = c.ImGui_SetNextWindowSize(.{ .x = w, .y = h }, 0);

        _ = c.ImGui_BeginChild("Steps", .{ .x = w, .y = h }, 0, 0);

        for (self.boards.items, 0..) |_, i| {
            var buf_label: [64]u8 = undefined;
            const label =
                if (i == 0)
                    std.fmt.bufPrintZ(&buf_label, "Start", .{}) catch unreachable
                else if (i == self.boards.items.len - 1)
                    std.fmt.bufPrintZ(&buf_label, "Goal", .{}) catch unreachable
                else
                    std.fmt.bufPrintZ(&buf_label, "Step {d}", .{i}) catch unreachable;

            if (i == self.selected_step) {
                _ = c.ImGui_TextColored(c.ImGui_GetStyleColorVec4(18).*, label.ptr);
            } else {
                if (c.ImGui_Selectable(label.ptr)) {
                    self.selected_step = i;
                    self.selected_board = self.boards.items[i];
                }
            }
        }

        c.ImGui_EndChild();
    }

    pub fn clearBoards(self: *Self) void {
        self.boards.clearAndFree(self.allocator);
    }

    pub fn appendBoard(self: *Self, board: Board(3, 3)) !void {
        try self.boards.append(self.allocator, board);
    }

    pub fn deinit(self: *Self) void {
        self.boards.deinit(self.allocator);
    }
};
