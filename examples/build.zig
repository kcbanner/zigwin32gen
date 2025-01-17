const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;
const CrossTarget = std.zig.CrossTarget;
const Mode = std.builtin.Mode;

pub fn build(b: *Builder) !void {
    const target = b.standardTargetOptions(.{});
    if (builtin.os.tag != .windows) {
        if (target.os_tag == null or target.os_tag.? != .windows) {
            std.log.err("target is not windows", .{});
            std.log.info("try building with one of -Dtarget=native-windows, -Dtarget=x86-windows or -Dtarget=x86_64-windows\n", .{});
            std.os.exit(1);
        }
    }

    const mode = b.standardReleaseOptions();
    try makeExe(b, target, mode, "helloworld", .Console);
    try makeExe(b, target, mode, "helloworld-window", .Windows);
    try makeExe(b, target, mode, "d2dcircle", .Windows);
    try makeExe(b, target, mode, "opendialog", .Windows);
    try makeExe(b, target, mode, "wasapi", .Console);
    try makeExe(b, target, mode, "net", .Console);
}

fn makeExe(
    b: *Builder,
    target: CrossTarget,
    mode: Mode,
    root: []const u8,
    subsystem: std.Target.SubSystem,
) !void {
    const src = try std.mem.concat(b.allocator, u8, &[_][]const u8 {root, ".zig"});
    const exe = b.addExecutable(root, src);
    exe.single_threaded = true;
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.subsystem = subsystem;
    exe.install();
    exe.addPackage(.{
        .name = "win32",
        .source = .{ .path = "../zigwin32/win32.zig" },
    });

    //const run_cmd = exe.run();
    //run_cmd.step.dependOn(b.getInstallStep());

    //const run_step = b.step("run", "Run the app");
    //run_step.dependOn(&run_cmd.step);
}
