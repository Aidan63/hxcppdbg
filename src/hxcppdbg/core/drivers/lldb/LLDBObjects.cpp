#include "LLDBObjects.hpp"

int hxcppdbg::core::drivers::lldb::LLDBObjects::lldbObjectsType = hxcpp_alloc_kind();

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBObjects> hxcppdbg::core::drivers::lldb::LLDBObjects::createFromFile(::String file)
{
    auto debugger = ::lldb::SBDebugger::Create();
    if (!debugger.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to create LLDB SBDebugger"));
    }

    debugger.SetAsync(false);

    auto target = debugger.CreateTarget(file.utf8_str());
    if (!target.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to create LLDB SBTarget"));
    }

    auto ptr = new hxcppdbg::core::drivers::lldb::LLDBObjects(debugger, target);

    return hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBObjects>(ptr);
}

hxcppdbg::core::drivers::lldb::LLDBObjects::LLDBObjects(::lldb::SBDebugger dbg, ::lldb::SBTarget tgt)
    : debugger(dbg), target(tgt)
{
    _hx_set_finalizer(this, finalise);
}

void hxcppdbg::core::drivers::lldb::LLDBObjects::destroy()
{
    if (!debugger.DeleteTarget(target))
    {
        hx::Throw(HX_CSTRING("Unable to delete LLDB SBTarget"));
    }

    ::lldb::SBDebugger::Destroy(debugger);
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess> hxcppdbg::core::drivers::lldb::LLDBObjects::launch(String cwd)
{
    auto options = target.GetLaunchInfo();
    options.SetWorkingDirectory(cwd.utf8_str());

    ::lldb::SBError error;
    auto process = target.Launch(options, error);

    if (!process.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to launch process"));
    }
    if (error.Fail())
    {
        hx::Throw(String(error.GetCString()));
    }

    auto exitCode   = process.GetExitStatus();
    auto resultDesc = process.GetExitDescription();

    auto ptr = new hxcppdbg::core::drivers::lldb::LLDBProcess(process);

    return hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess>(ptr);
}

int hxcppdbg::core::drivers::lldb::LLDBObjects::__GetType() const
{
    return lldbObjectsType;
}

::String hxcppdbg::core::drivers::lldb::LLDBObjects::toString()
{
    return HX_CSTRING("LLDBObjects");
}

void hxcppdbg::core::drivers::lldb::LLDBObjects::finalise(::Dynamic obj)
{
    static_cast<LLDBObjects*>(obj.mPtr)->destroy();
}