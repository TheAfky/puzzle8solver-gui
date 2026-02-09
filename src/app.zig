const std = @import("std");
const gl = @import("gl");

const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", "1");
    @cInclude("GLFW/glfw3.h");
    @cInclude("dcimgui.h");
    @cInclude("backends/dcimgui_impl_glfw.h");
    @cInclude("backends/dcimgui_impl_opengl3.h");
});

const GLSL_VERSION = "#version 130";
const GL_CONTEXT_MAJOR: c_int = 3;
const GL_CONTEXT_MINOR: c_int = 0;

fn glfwErrorCallback(errn: c_int, str: [*c]const u8) callconv(.c) void {
    std.log.err("GLFW Error {d}: {s}", .{ errn, str });
}

pub const App = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    window: *c.GLFWwindow,
    procs: gl.ProcTable,
    window_width: c_int,
    window_height: c_int,
    scaling: f16,

    pub fn init(allocator: std.mem.Allocator, scaling: f16) !App {
        var self: Self = undefined;
        self.allocator = allocator;
        self.window_width = @intFromFloat(480 * scaling);
        self.window_height = @intFromFloat(320 * scaling);
        self.scaling = scaling;

        try initializeGlfwOpenGl(&self);
        try initializeImGui(&self);

        return self;
    }

    fn initializeGlfwOpenGl(self: *Self) !void {
        _ = c.glfwSetErrorCallback(glfwErrorCallback);
        _ = c.glfwInit();

        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, GL_CONTEXT_MAJOR);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, GL_CONTEXT_MINOR);

        self.window = c.glfwCreateWindow(self.window_width, self.window_height, "Puzzle8solver", null, null) orelse return error.WindowCreationFailed;

        c.glfwMakeContextCurrent(self.window);
        c.glfwSetWindowSizeLimits(self.window, self.window_width, self.window_height, -1, -1);
        c.glfwSwapInterval(1);

        // OpenGL procreation table
        self.procs = undefined;
        if (!self.procs.init(c.glfwGetProcAddress)) {
            return error.GlfwInitFailed;
        }
    }

    fn initializeImGui(self: *Self) !void {
        _ = c.CIMGUI_CHECKVERSION();
        _ = c.ImGui_CreateContext(null);

        const io = c.ImGui_GetIO();
        io.*.ConfigFlags |= c.ImGuiConfigFlags_NavEnableKeyboard;
        io.*.IniFilename = "";

        _ = c.cImGui_ImplGlfw_InitForOpenGL(self.window, true);
        _ = c.cImGui_ImplOpenGL3_InitEx(GLSL_VERSION);

        // c.ImGui_StyleColorsDark(null);
        c.ImGui_StyleColorsLight(null);

        const style = c.ImGui_GetStyle();
        style.*.FontScaleDpi = self.scaling;
        c.ImGuiStyle_ScaleAllSizes(style, self.scaling);
    }

    pub fn deinit(self: *Self) void {
        deinitializeGlfwOpenGl(self);
        deinitializeImGui(self);
    }

    fn deinitializeGlfwOpenGl(self: *Self) void {
        gl.makeProcTableCurrent(null);
        c.glfwDestroyWindow(self.window);
        c.glfwTerminate();
    }

    fn deinitializeImGui() void {
        c.ImGui_DestroyContext(null);
        c.cImGui_ImplGlfw_Shutdown();
        c.cImGui_ImplOpenGL3_Shutdown();
    }

    pub fn run(self: *Self) !void {
        while (c.glfwWindowShouldClose(self.window) != c.GLFW_TRUE) {
            c.glfwPollEvents();
            newFrame();

            c.ImGui_Render();
            drawFrame(self);
        }
    }

    fn newFrame() void {
        c.cImGui_ImplOpenGL3_NewFrame();
        c.cImGui_ImplGlfw_NewFrame();
        c.ImGui_NewFrame();
    }

    fn drawClear(self: *Self) void {
        c.glfwGetFramebufferSize(self.window, &self.window_width, &self.window_height);
        gl.makeProcTableCurrent(&self.procs);
        gl.Viewport(0, 0, self.window_width, self.window_height);
        gl.ClearColor(0, 0, 0, 1);
        gl.Clear(gl.COLOR_BUFFER_BIT);
    }

    fn drawFrame(self: *Self) void {
        drawClear(self);
        c.cImGui_ImplOpenGL3_RenderDrawData(c.ImGui_GetDrawData());
        c.glfwSwapBuffers(self.window);
    }
};
