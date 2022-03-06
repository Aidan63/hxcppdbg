#include <hxcpp.h>

#include "LLDBProcess.hpp"

int hxcppdbg::core::drivers::lldb::native::LLDBProcess::lldbProcessType = hxcpp_alloc_kind();

void hxcppdbg::core::drivers::lldb::native::LLDBProcess::finalise(Dynamic obj)
{
    static_cast<hxcppdbg::core::drivers::lldb::native::LLDBProcess*>(obj.mPtr)->destroy();
}

hxcppdbg::core::drivers::lldb::native::LLDBProcess::LLDBProcess(::lldb::SBTarget t)
    : target(t)
{
    _hx_set_finalizer(this, finalise);
}

int hxcppdbg::core::drivers::lldb::native::LLDBProcess::getState()
{
    return process.GetState();
}

void hxcppdbg::core::drivers::lldb::native::LLDBProcess::start(String cwd)
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

void hxcppdbg::core::drivers::lldb::native::LLDBProcess::resume()
{
    hx::EnterGCFreeZone();
    auto error = process.Continue();
    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        hx::Throw(String(error.GetCString()));
    }
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> hxcppdbg::core::drivers::lldb::native::LLDBProcess::stepIn(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return null();
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }

    hx::EnterGCFreeZone();

    thread.StepInto();

    hx::ExitGCFreeZone();

    return getStackFrame(threadIndex, 0);
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> hxcppdbg::core::drivers::lldb::native::LLDBProcess::stepOver(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return null();
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }

    hx::EnterGCFreeZone();

    ::lldb::SBError error;
    thread.StepOver(::lldb::RunMode::eOnlyDuringStepping, error);

    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }

    return getStackFrame(threadIndex, 0);
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> hxcppdbg::core::drivers::lldb::native::LLDBProcess::stepOut(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return null();
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }

    hx::EnterGCFreeZone();

    ::lldb::SBError error;
    thread.StepOut(error);

    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }

    return getStackFrame(threadIndex, 0);
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> hxcppdbg::core::drivers::lldb::native::LLDBProcess::getStackFrame(int threadIndex, int frameIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return null();
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }

    auto frame = thread.GetFrameAtIndex(frameIndex);
    if (!frame.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to get frame 0"));
    }

    auto lineEntry = frame.GetLineEntry();
    auto fileSpec  = lineEntry.GetFileSpec();
    auto dir       = fileSpec.GetDirectory();
    auto absFile   = dir == nullptr ? std::string("") : std::string(dir) + std::string("/") + std::string(fileSpec.GetFilename());
    auto fileName  = String::create(absFile.c_str());
    auto funcName  = String::create(frame.GetFunctionName());
    auto symName   = String::create(frame.GetSymbol().GetName());
    auto lineNum   = lineEntry.GetLine();

    return hx::ObjectPtr<RawStackFrame>(new RawStackFrame(fileName, funcName, symName, lineNum));
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame>> hxcppdbg::core::drivers::lldb::native::LLDBProcess::getStackFrames(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame>>(0, 0);
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }
    
    auto count  = thread.GetNumFrames();
    auto frames = Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame>>(0, count);

    for (int i = 0; i < count; i++)
    {
        frames->__SetItem(i, getStackFrame(threadIndex, i));
    }

    return frames;
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackLocal>> hxcppdbg::core::drivers::lldb::native::LLDBProcess::getStackVariables(int threadIndex, int frameIndex)
{
    auto thread    = process.GetThreadAtIndex(threadIndex);
    auto frame     = thread.GetFrameAtIndex(frameIndex);
    auto variables = frame.GetVariables(true, true, true, true);
    auto output    = Array<hx::ObjectPtr<RawStackLocal>>(0, variables.GetSize());

    for (int i = 0; i < variables.GetSize(); i++)
    {
        auto variable = variables.GetValueAtIndex(i);
        auto name     = variable.GetName();
        auto type     = variable.GetTypeName();

        String varValue;
        if (std::string(type) == std::string("String"))
        {
            varValue = hxcppdbg::core::drivers::lldb::native::extractString(variable);
        }
        else
        {
            varValue = String::create(variable.GetValue());
        }

        output->__SetItem(i, hx::ObjectPtr<RawStackLocal>(new RawStackLocal(String::create(name), varValue, String::create(type))));
    }
    
    return output;
}

void hxcppdbg::core::drivers::lldb::native::LLDBProcess::destroy()
{
    process.Destroy();
}

int hxcppdbg::core::drivers::lldb::native::LLDBProcess::__GetType() const
{
    return lldbProcessType;
}

String hxcppdbg::core::drivers::lldb::native::LLDBProcess::toString()
{
    return HX_CSTRING("LLDBProcess");
}