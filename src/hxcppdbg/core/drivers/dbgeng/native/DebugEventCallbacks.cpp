#include <hxcpp.h>

#include "DebugEventCallbacks.hpp"

hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::DebugEventCallbacks(PDEBUG_CLIENT7 _client, Dynamic _onBreakpointCb)
    : client(_client), onBreakpointCb(_onBreakpointCb)
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
        DEBUG_EVENT_EXIT_PROCESS;
    return S_OK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::Breakpoint(PDEBUG_BREAKPOINT2 bp)
{
    auto sys = PDEBUG_SYSTEM_OBJECTS4{ nullptr };
    if (!SUCCEEDED(client->QueryInterface(__uuidof(IDebugSystemObjects4), (void**)&sys)))
    {
        hx::Throw(HX_CSTRING("Unable to get IDebugSystemObjects4"));
    }

    auto threadID = ULONG{ 0 };
    if (!SUCCEEDED(sys->GetEventThread(&threadID)))
    {
        hx::Throw(HX_CSTRING("Unable to get thread ID"));
    }

    auto breakpointID = ULONG{ 0 };
    if (!SUCCEEDED(bp->GetId(&breakpointID)))
    {
        hx::Throw(HX_CSTRING("Unable to get breakpoint ID"));
    }

    onBreakpointCb(breakpointID, threadID);

    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::Exception(PEXCEPTION_RECORD64, ULONG firstChance)
{
    return DEBUG_STATUS_NO_CHANGE;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::CreateProcess(
    _In_ ULONG64 imageFileHandle,
    _In_ ULONG64 handle,
    _In_ ULONG64 baseOffset,
    _In_ ULONG moduleSize,
    _In_ PCWSTR moduleName,
    _In_ PCWSTR imageName,
    _In_ ULONG checkSum,
    _In_ ULONG timeDateStamp,
    _In_ ULONG64 initialThreadHandle,
    _In_ ULONG64 threadDataOffset,
    _In_ ULONG64 startOffset)
{
    return DEBUG_STATUS_BREAK;
}

HRESULT hxcppdbg::core::drivers::dbgeng::native::DebugEventCallbacks::ExitProcess(ULONG ExitCode)
{
    return DEBUG_STATUS_NO_CHANGE;
}