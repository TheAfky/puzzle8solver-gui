const std = @import("std");

const Board = @import("puzzle8solver").Board(3, 3);

const c = @cImport({
    @cInclude("dcimgui.h");
});

pub const BoardPanel = struct {
    const Self = @This();
    const width: usize = 3;
    const height: usize = 3;

    active_board: Board,
    scaling: f32,

    pub fn init(board: Board, scaling: f32) BoardPanel {
        return BoardPanel{
            .active_board = board,
            .scaling = scaling,
        };
    }

    pub fn draw(self: *BoardPanel, x: f32, y: f32, w: f32, h: f32, font_size: f32) void {
        _ = c.ImGui_SetNextWindowPos(.{ .x = x, .y = y }, 0);
        _ = c.ImGui_SetNextWindowSize(.{ .x = w, .y = h }, 0);

        _ = c.ImGui_BeginChild("Matrix", .{ .x = w, .y = h }, 0, 0);

        const font_scale = font_size + self.scaling;
        c.ImGui_SetWindowFontScale(font_scale);

        for (0..height) |row| {
            for (0..width) |col| {
                const val = self.active_board[row * width + col];
                if (val == 0) {
                    _ = c.ImGui_Text(" ");
                } else {
                    var buf: [4]u8 = undefined;
                    const txt = std.fmt.bufPrintZ(&buf, "{d}", .{val}) catch unreachable;
                    _ = c.ImGui_Text(txt.ptr);
                }
                if (col + 1 < width) c.ImGui_SameLine();
            }
        }

        c.ImGui_EndChild();
    }

    pub fn setBoard(self: *BoardPanel, board: Board) void {
        self.active_board = board;
    }
};
