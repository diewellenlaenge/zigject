const std = @import("std");
const win = std.os.windows;
const win32 = @import("win32");
const L = std.unicode.utf8ToUtf16LeStringLiteral;

pub export fn DllMain(hInstance: win.HINSTANCE, dwReason: win.DWORD, lpReserved: win.LPVOID) win.BOOL {
    _ = hInstance;
    _ = lpReserved;

    switch (dwReason) {
        win32.system.system_services.DLL_PROCESS_ATTACH => {
            _ = win32.ui.windows_and_messaging.MessageBoxW(null, L("Injectee!"), L("Injectee!"), win32.ui.windows_and_messaging.MESSAGEBOX_STYLE.OK);
        },
        win32.system.system_services.DLL_THREAD_ATTACH => {},
        win32.system.system_services.DLL_THREAD_DETACH => {},
        win32.system.system_services.DLL_PROCESS_DETACH => {},
        else => {},
    }

    return win.TRUE;
}
