#include <hxcpp.h>

#ifndef INCLUDED_haxe_Exception
#include <haxe/Exception.h>
#endif

#ifndef INCLUDED_haxe_ds_Option
#include <haxe/ds/Option.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_ds_Result
#include <hxcppdbg/core/ds/Result.h>
#endif

#include "LLDBObjects.hpp"
#include "LLDBProcess.hpp"

int hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::lldbObjectsType = hxcpp_alloc_kind();

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::createFromFile(::String file)
{
    auto debugger = ::lldb::SBDebugger::Create();
    if (!debugger.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to create LLDB SBDebugger"), nullptr, nullptr));
    }

    debugger.SetAsync(false);

    auto target = debugger.CreateTarget(file.utf8_str());
    if (!target.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to create LLDB SBTarget"), nullptr, nullptr));
    }

    return hxcppdbg::core::ds::Result_obj::Success(new hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj(debugger, target));
}

hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::LLDBObjects_obj(::lldb::SBDebugger dbg, ::lldb::SBTarget tgt)
    : debugger(dbg), target(tgt)
{
    _hx_set_finalizer(this, finalise);
}

void hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::destroy()
{
    if (debugger.DeleteTarget(target))
    {
        ::lldb::SBDebugger::Destroy(debugger);
    }
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::setBreakpoint(String cppFile, int cppLine)
{
    auto bp = target.BreakpointCreateByLocation(cppFile.utf8_str(), cppLine);
    if (!bp.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to create breakpoint"), nullptr, nullptr));
    }

    auto id = bp.GetID();
    bp.SetCallback(onBreakpointHit, this);

    return hxcppdbg::core::ds::Result_obj::Success(id);
}

haxe::ds::Option hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::removeBreakpoint(int id)
{
    if (target.BreakpointDelete(id))
    {
        return haxe::ds::Option_obj::None;
    }
    else
    {
        return haxe::ds::Option_obj::Some(haxe::Exception_obj::__new(HX_CSTRING("Unable to remove breakpoint"), nullptr, nullptr));
    }
}

hxcppdbg::core::drivers::lldb::native::LLDBProcess hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::launch()
{
    return new hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj(target);
}

void hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(LLDBObjects_obj);
	HX_MARK_MEMBER_NAME(onBreakpointHitCallback,"onBreakpointHitCallback");
	HX_MARK_END_CLASS();
}

#ifdef HXCPP_VISIT_ALLOCS
void hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(onBreakpointHitCallback,"onBreakpointHitCallback");
}
#endif

int hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::__GetType() const
{
    return lldbObjectsType;
}

::String hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::toString()
{
    return HX_CSTRING("LLDBObjects_obj");
}

void hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::finalise(::Dynamic obj)
{
    static_cast<LLDBObjects_obj*>(obj.mPtr)->destroy();
}

bool hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::onBreakpointHit(void *baton, ::lldb::SBProcess &process, ::lldb::SBThread &thread, ::lldb::SBBreakpointLocation &location)
{
    // hx::ExitGCFreeZone();

    // This callback will be called while this thread is in a GC free zone.
    // Re-enter a GC zone and then exit before returning as the GC free zone is exited again once control returns from the calling lldb object.

    auto bp  = location.GetBreakpoint().GetID();
    auto tid = location.GetThreadID();
    auto obj = LLDBObjects(static_cast<LLDBObjects_obj*>(baton));

    if (obj->onBreakpointHitCallback != null())
    {
        obj->onBreakpointHitCallback(bp, tid);
    }

    // hx::EnterGCFreeZone();

    return true;
}