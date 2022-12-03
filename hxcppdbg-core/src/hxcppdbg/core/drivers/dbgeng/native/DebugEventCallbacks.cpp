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
        DEBUG_EVENT_EXCEPTION;
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