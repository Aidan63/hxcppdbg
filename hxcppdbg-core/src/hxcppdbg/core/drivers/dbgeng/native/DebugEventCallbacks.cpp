#include <hxcpp.h>

#include "DebugEventCallbacks.hpp"
#include "DbgEngContext.hpp"

hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::DebugEventCallbacks()
{
    //
}

ULONG hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::AddRef()
{
    return 1;
}

ULONG hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::Release()
{
    return 0;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::GetInterestMask(PULONG mask)
{
    *mask =
        DEBUG_EVENT_BREAKPOINT |
        DEBUG_EVENT_EXCEPTION |
        DEBUG_EVENT_CREATE_PROCESS |
        DEBUG_EVENT_EXIT_PROCESS |
        DEBUG_EVENT_CREATE_THREAD |
        DEBUG_EVENT_EXIT_THREAD;
    return S_OK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::Breakpoint(PDEBUG_BREAKPOINT2 bp)
{
    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::Exception(PEXCEPTION_RECORD64, ULONG firstChance)
{
    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::CreateThread(ULONG64 Handle, ULONG64 DataOffset, ULONG64 StartOffset)
{
    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::ExitThread(ULONG ExitCode)
{
    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::CreateProcess(
    ULONG64 ImageFileHandle,
    ULONG64 Handle,
    ULONG64 BaseOffset,
    ULONG ModuleSize,
    PCWSTR ModuleName,
    PCWSTR ImageName,
    ULONG CheckSum,
    ULONG TimeDateStamp,
    ULONG64 InitialThreadHandle,
    ULONG64 ThreadDataOffset,
    ULONG64 StartOffset
)
{
    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::ExitProcess(ULONG ExitCode)
{
    return DEBUG_STATUS_BREAK;
}