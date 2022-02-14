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

hx::Null<int> hxcppdbg::core::drivers::lldb::LLDBObjects::setBreakpoint(String cppFile, int cppLine)
{
    auto bp = target.BreakpointCreateByLocation(cppFile.utf8_str(), cppLine);
    if (!bp.IsValid())
    {
        return hx::Null<int>();
    }

    auto id = bp.GetID();
    bp.SetCallback(onBreakpointHit, this);

    return hx::Null<int>(id);
}

bool hxcppdbg::core::drivers::lldb::LLDBObjects::removeBreakpoint(int id)
{
    return target.BreakpointDelete(id);
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess> hxcppdbg::core::drivers::lldb::LLDBObjects::launch()
{
    auto ptr = new hxcppdbg::core::drivers::lldb::LLDBProcess(target);

    return hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess>(ptr);
}

void hxcppdbg::core::drivers::lldb::LLDBObjects::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(LLDBObjects);
	HX_MARK_MEMBER_NAME(onBreakpointHitCallback,"onBreakpointHitCallback");
	HX_MARK_END_CLASS();
}

#ifdef HXCPP_VISIT_ALLOCS
void hxcppdbg::core::drivers::lldb::LLDBObjects::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(onBreakpointHitCallback,"onBreakpointHitCallback");
}
#endif

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

bool hxcppdbg::core::drivers::lldb::LLDBObjects::onBreakpointHit(void *baton, ::lldb::SBProcess &process, ::lldb::SBThread &thread, ::lldb::SBBreakpointLocation &location)
{
    hx::ExitGCFreeZone();

    // This callback will be called while this thread is in a GC free zone.
    // Re-enter a GC zone and then exit before returning as the GC free zone is exited again once control returns from the calling lldb object.

    auto bp  = location.GetBreakpoint().GetID();
    auto tid = location.GetThreadID();
    auto obj = hx::ObjectPtr<LLDBObjects>(static_cast<LLDBObjects*>(baton));

    if (obj->onBreakpointHitCallback != null())
    {
        obj->onBreakpointHitCallback(bp, tid);
    }

    // auto count  = thread.GetNumFrames();
    // auto frames = Array<hx::Anon>(count, count);

    // for (int i = 0; i < count; i++)
    // {
    //     auto frame = thread.GetFrameAtIndex(i);

    //     // file, line, and function.
    //     auto lineEntry = frame.GetLineEntry();
    //     auto lineNum   = lineEntry.GetLine();
    //     auto funcName  = frame.GetFunctionName();
    //     auto pivot     = std::string(funcName).find_first_of('(');
    //     auto cleaned   = (pivot != std::string::npos) ? String::create(funcName, pivot) : String::create(funcName);
    // }

    hx::EnterGCFreeZone();

    return true;
}