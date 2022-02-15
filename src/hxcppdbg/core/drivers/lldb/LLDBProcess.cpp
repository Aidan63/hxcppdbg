#include "LLDBProcess.hpp"

// Frame

hxcppdbg::core::drivers::lldb::Frame::Frame(String _file, String _function, String _symbol, int _line)
    : file(_file), func(_function), line(_line), symbol(_symbol)
{
    //
}

void hxcppdbg::core::drivers::lldb::Frame::__Mark(HX_MARK_PARAMS)
{
    HX_MARK_BEGIN_CLASS(Frame);
	HX_MARK_MEMBER_NAME(file,"file");
    HX_MARK_MEMBER_NAME(func,"func");
    HX_MARK_MEMBER_NAME(symbol,"symbol");
	HX_MARK_END_CLASS();
}

#if HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::lldb::Frame::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(file,"onBreakpointHitCallback");
    HX_VISIT_MEMBER_NAME(func,"func");
    HX_VISIT_MEMBER_NAME(symbol,"symbol");
}

#endif

// LLDBProcess

int hxcppdbg::core::drivers::lldb::LLDBProcess::lldbProcessType = hxcpp_alloc_kind();

void hxcppdbg::core::drivers::lldb::LLDBProcess::finalise(Dynamic obj)
{
    static_cast<hxcppdbg::core::drivers::lldb::LLDBProcess*>(obj.mPtr)->destroy();
}

hxcppdbg::core::drivers::lldb::LLDBProcess::LLDBProcess(::lldb::SBTarget t)
    : target(t)
{
    _hx_set_finalizer(this, finalise);
}

int hxcppdbg::core::drivers::lldb::LLDBProcess::getState()
{
    return process.GetState();
}

void hxcppdbg::core::drivers::lldb::LLDBProcess::start(String cwd)
{
    auto options = target.GetLaunchInfo();
    options.SetWorkingDirectory(cwd.utf8_str());

    hx::EnterGCFreeZone();

    ::lldb::SBError error;
    process = target.Launch(options, error);

    hx::ExitGCFreeZone();

    if (!process.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to launch process"));
    }
    if (error.Fail())
    {
        hx::Throw(String(error.GetCString()));
    }
}

void hxcppdbg::core::drivers::lldb::LLDBProcess::resume()
{
    hx::EnterGCFreeZone();
    auto error = process.Continue();
    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        hx::Throw(String(error.GetCString()));
    }
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>> hxcppdbg::core::drivers::lldb::LLDBProcess::getStackFrames(int threadID)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>>(0, 0);
    }

    auto thread = process.GetThreadAtIndex(threadID);
    if (!thread.IsValid()) {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }
    
    auto count  = thread.GetNumFrames();
    auto frames = Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>>(0, count);

    for (int i = 0; i < count; i++)
    {
        auto frame = thread.GetFrameAtIndex(i);

        // file, line, and function.
        auto lineEntry = frame.GetLineEntry();
        auto fileName  = String::create(lineEntry.GetFileSpec().GetFilename());
        auto funcName  = String::create(frame.GetFunctionName());
        auto symName   = String::create(frame.GetSymbol().GetName());
        auto lineNum   = lineEntry.GetLine();
        auto ptr       = hx::ObjectPtr<Frame>(new Frame(fileName, funcName, symName, lineNum));

        frames->__SetItem(i, ptr);
    }

    return frames;
}

void hxcppdbg::core::drivers::lldb::LLDBProcess::destroy()
{
    process.Destroy();
}

int hxcppdbg::core::drivers::lldb::LLDBProcess::__GetType() const
{
    return lldbProcessType;
}

String hxcppdbg::core::drivers::lldb::LLDBProcess::toString()
{
    return HX_CSTRING("LLDBProcess");
}