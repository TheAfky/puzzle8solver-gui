const std = @import("std");

const StepsPanel = @import("steps_panel.zig").StepsPanel;
const SolutionInfoPanel = @import("solution_info_panel.zig").SolutionInfoPanel;
const puzzle8solver = @import("puzzle8solver");
const Board = puzzle8solver.Board(3, 3);

const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", "1");
    @cInclude("GLFW/glfw3.h");
    @cInclude("dcimgui.h");
    @cInclude("backends/dcimgui_impl_glfw.h");
    @cInclude("backends/dcimgui_impl_opengl3.h");
});

pub const NewSolveWindow = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    start_buf: [18]u8,
    end_buf: [18]u8,
    selected_solver: i32,
    steps_panel: *StepsPanel,
    solution_info_panel: *SolutionInfoPanel,

    pub fn init(allocator: std.mem.Allocator, steps_panel: *StepsPanel, solution_info_panel: *SolutionInfoPanel) Self {
        return Self{
            .allocator = allocator,
            .start_buf = [_]u8{0} ** 18,
            .end_buf = [_]u8{0} ** 18,
            .selected_solver = 0,
            .steps_panel = steps_panel,
            .solution_info_panel = solution_info_panel,
        };
    }

    pub fn updatePointers(self: *Self, steps_panel: *StepsPanel, solution_info_panel: *SolutionInfoPanel) void {
        self.steps_panel = steps_panel;
        self.solution_info_panel = solution_info_panel;
    }

    pub fn draw(self: *Self, p_open: *bool, scaling: f32) !void {
        if (!p_open.*) return;
        _ = c.ImGui_SetNextWindowSize(.{ .x = 384 * scaling, .y = 256 * scaling }, 0);
        _ = c.ImGui_Begin("New Solve", p_open, c.ImGuiWindowFlags_NoCollapse | c.ImGuiWindowFlags_NoResize);

        _ = c.ImGui_Text("Boards");
        _ = c.ImGui_InputText("Start", &self.start_buf, self.start_buf.len, 0);
        if (c.ImGui_IsItemHovered(0)) {
            _ = c.ImGui_BeginTooltip();
            _ = c.ImGui_Text("3x3 board start position, e.g. 1,2,3,4,5,6,7,8,0");
            c.ImGui_EndTooltip();
        }

        _ = c.ImGui_InputText("End", &self.end_buf, self.end_buf.len, 0);
        if (c.ImGui_IsItemHovered(0)) {
            _ = c.ImGui_BeginTooltip();
            _ = c.ImGui_Text("3x3 board goal position, e.g. 1,2,3,4,5,6,7,8,0");
            c.ImGui_EndTooltip();
        }

        c.ImGui_Separator();
        _ = c.ImGui_Text("Solver");
        const items = [_]u8{
            'B', 'F', 'S', 0, 0,
        };

        _ = c.ImGui_Combo("##solver", &self.selected_solver, &items);
        c.ImGui_Separator();

        if (c.ImGui_Button("Solve")) {
            if (try generateSolution(self)) {
                p_open.* = false;
            }
        }

        if (c.ImGui_Button("Cancel")) p_open.* = false;
        c.ImGui_End();
    }

    fn generateSolution(self: *Self) !bool {
        var start_board = parseBufferToBoard(self.start_buf) catch {
            self.start_buf = [_]u8{0} ** 18;
            return false;
        };
        const end_board = parseBufferToBoard(self.end_buf) catch {
            self.end_buf = [_]u8{0} ** 18;
            return false;
        };

        switch (self.selected_solver) {
            0 => {
                var solution = puzzle8solver.solvePuzzleBFS(self.allocator, 3, 3, &start_board, &end_board) catch |err| {
                    if (err == error.NoSolution) {
                        self.start_buf = [_]u8{0} ** 18;
                        return false;
                    }
                    return err;
                };
                defer solution.moves.deinit(self.allocator);
                self.solution_info_panel.setCounts(solution.number_of_nodes, solution.moves.items.len);
                self.steps_panel.clearBoards();
                try self.steps_panel.appendBoard(start_board);
                for (solution.moves.items) |move| {
                    try puzzle8solver.applyMoveToBoard(3, 3, &start_board, move);
                    try self.steps_panel.appendBoard(start_board);
                }
            },
            else => unreachable,
        }

        return true;
    }

    fn parseBufferToBoard(buffer: [18]u8) !Board {
        var board: Board = undefined;
        var seen_number: [9]bool = [_]bool{false} ** 9;
        var number_of_digits: usize = 0;
        var i: usize = 0;

        while (i < buffer.len and buffer[i] != 0) {
            if (i >= buffer.len) break;

            // Read next character and check if the number is in range
            const character = buffer[i];
            if (character < '0' or character > '8') return error.InvalidNumber;
            const number = character - '0';

            if (seen_number[number]) return error.DuplicateNumber;
            seen_number[number] = true;

            // Add number to board
            board[number_of_digits] = @intCast(number);
            number_of_digits += 1;

            i += 1;
            if (number_of_digits < 9) {
                // Check comma after any number
                if (i >= buffer.len or buffer[i] != ',') return error.InvalidFormat;
                i += 1;
            }
        }

        if (number_of_digits != 9) return error.InvalidFormat;
        return board;
    }
};
