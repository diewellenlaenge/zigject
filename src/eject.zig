const std = @import("std");
const L = std.unicode.utf8ToUtf16LeStringLiteral;
const heap = std.heap;

const win = std.os.windows;
const win32 = @import("lib/zigwin32/win32.zig");
const threading = win32.system.threading;
const loader = win32.system.library_loader;
const foundation = win32.foundation;

pub const EjectError = error {
    OpenProcess,
    GetModuleHandleW,
    GetProcAddress,
    CreateRemoteThread,
    FreeLibrary,
    GetExitCodeThread,
};

pub fn RemoteThread(process_id: win.DWORD, module: ?win.HMODULE) EjectError!bool {
    const process = threading.OpenProcess(threading.PROCESS_ALL_ACCESS, win.FALSE, process_id) orelse return EjectError.OpenProcess;
    defer _ = win32.foundation.CloseHandle(process);

    const kernel32 = loader.GetModuleHandleW(L("kernel32.dll")) orelse return EjectError.GetModuleHandleW;
    const freeLibrary = loader.GetProcAddress(kernel32, "FreeLibrary") orelse return EjectError.GetProcAddress;
    const thread = threading.CreateRemoteThread(process, null, 0, @ptrCast(threading.LPTHREAD_START_ROUTINE, freeLibrary), module, 0, null) orelse return EjectError.CreateRemoteThread;

    _ = threading.WaitForSingleObject(thread, win.INFINITE);
    var result: win.BOOL = win.FALSE;

    if (threading.GetExitCodeThread(thread, @ptrCast(*u32, &result)) == win.FALSE) {
        return EjectError.GetExitCodeThread;
    }

    return result == win.TRUE;
}
