//! This example is ported from : https://github.com/microsoft/Windows-classic-samples/blob/master/Samples/Win7Samples/begin/LearnWin32/HelloWorld/cpp/main.cpp
pub const UNICODE = true;

const WINAPI = @import("std").os.windows.WINAPI;

usingnamespace @import("win32").zig;
usingnamespace @import("win32").api.system_services;
usingnamespace @import("win32").api.windows_and_messaging;
usingnamespace @import("win32").api.gdi;

// TODO: these types don't seem to be defined in win32metadata?
const PWSTR = [*:0]u16;
const UINT = u32;

pub export fn wWinMain(hInstance: HINSTANCE, _: HINSTANCE, pCmdLine: PWSTR, nCmdShow: c_int) callconv(WINAPI) c_int
{

    // Register the window class.
    const CLASS_NAME = L("Sample Window Class");

    const wc = WNDCLASS {
        .style = 0,
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        // TODO: autogen bindings don't allow for null, should win32metadata allow Option for fields? Or should all strings allow NULL?
        .lpszMenuName = L("Some Menu Name"),
        .lpszClassName = CLASS_NAME,
    };

    _ = RegisterClass(&wc);

    // Create the window.

    const hwnd = CreateWindowEx(
        0,                              // Optional window styles.
        CLASS_NAME,                     // Window class
        L("Learn to Program Windows"),  // Window text
        WS_OVERLAPPEDWINDOW,            // Window style

        // Size and position
        CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,

        null,       // Parent window
        null,       // Menu
        hInstance,  // Instance handle
        null        // Additional application data
    );
    if (hwnd == null)
    {
        return 0;
    }

    _ = ShowWindow(hwnd, nCmdShow);

    // Run the message loop.
    var msg : MSG = undefined;
    while (GetMessage(&msg, null, 0, 0) != 0)
    {
        _ = TranslateMessage(&msg);
        _ = DispatchMessage(&msg);
    }

    return 0;
}

fn WindowProc(hwnd: HWND , uMsg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(WINAPI) LRESULT
{
    switch (uMsg)
    {
        WM_DESTROY =>
        {
            PostQuitMessage(0);
            return 0;
        },
        WM_PAINT =>
        {
            // Cannot simply use PAINTSTRUCT because of: https://github.com/microsoft/win32metadata/issues/215
            //var ps: PAINTSTRUCT = undefined;
            var workaround_issue_215_ps : extern struct {
                ps: PAINTSTRUCT,
                reserved: [31]u8, // add the missing padding
            } = undefined;
            const hdc = BeginPaint(hwnd, &workaround_issue_215_ps.ps);

            // All painting occurs here, between BeginPaint and EndPaint.
            _ = FillRect(hdc, &workaround_issue_215_ps.ps.rcPaint, @intToPtr(HBRUSH, @as(usize, COLOR_WINDOW+1)));
            _ = EndPaint(hwnd, &workaround_issue_215_ps.ps);
            return 0;
        },
        else => {},
    }

    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}
