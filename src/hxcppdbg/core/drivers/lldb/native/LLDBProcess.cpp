#include <hxcpp.h>

#ifndef INCLUDED_haxe_Exception
#include <haxe/Exception.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_ds_Result
#include <hxcppdbg/core/ds/Result.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_stack_NativeFrame
#include <hxcppdbg/core/stack/NativeFrame.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_locals_NativeLocal
#include <hxcppdbg/core/locals/NativeLocal.h>
#endif

#ifndef INCLUDED_haxe_io_Path
#include <haxe/io/Path.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_drivers_StopReason
#include <hxcppdbg/core/drivers/StopReason.h>
#endif

#include "LLDBProcess.hpp"
#include <SBTypeSummary.h>
#include <SBStream.h>

int hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::lldbProcessType = hxcpp_alloc_kind();

void hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::finalise(Dynamic obj)
{
    static_cast<hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj*>(obj.mPtr)->destroy();
}

hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::LLDBProcess_obj(::lldb::SBTarget t) :
    target(t), exceptionBreakpoint(target.BreakpointCreateForException(::lldb::LanguageType::eLanguageTypeC_plus_plus, false, true).GetID())
{
    _hx_set_finalizer(this, finalise);
}

int hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::getState()
{
    return process.GetState();
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::start(String cwd)
{
    auto options = target.GetLaunchInfo();
    options.SetWorkingDirectory(cwd.utf8_str());

    hx::EnterGCFreeZone();

    ::lldb::SBError error;
    process = target.Launch(options, error);

    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(String::create(error.GetCString()), nullptr, nullptr));
    }

    return findStopReason();
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::resume()
{
    hx::EnterGCFreeZone();
    auto error = process.Continue();
    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(String::create(error.GetCString()), nullptr, nullptr));
    }

    return findStopReason();
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::stepIn(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("process is not suspended"), nullptr, nullptr));
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Thread is not valid"), nullptr, nullptr));
    }

    hx::EnterGCFreeZone();

    thread.StepInto();

    hx::ExitGCFreeZone();

    return findStopReason();
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::stepOver(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("process is not suspended"), nullptr, nullptr));
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Thread is not valid"), nullptr, nullptr));
    }

    hx::EnterGCFreeZone();

    auto error = ::lldb::SBError();
    thread.StepOver(::lldb::RunMode::eOnlyDuringStepping, error);

    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(String::create(error.GetCString()), nullptr, nullptr));
    }

    return findStopReason();
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::stepOut(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("process is not suspended"), nullptr, nullptr));
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Thread is not valid"), nullptr, nullptr));
    }

    hx::EnterGCFreeZone();

    ::lldb::SBError error;
    thread.StepOut(error);

    hx::ExitGCFreeZone();

    if (error.Fail())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(String::create(error.GetCString()), nullptr, nullptr));
    }

    return findStopReason();
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::getStackFrame(int threadIndex, int frameIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("process is not suspended"), nullptr, nullptr));
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Thread is not valid"), nullptr, nullptr));
    }

    auto frame = thread.GetFrameAtIndex(frameIndex);
    if (!frame.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to read frame"), nullptr, nullptr));
    }

    return hxcppdbg::core::ds::Result_obj::Success(createNativeFrame(frame));
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::getStackFrames(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("process is not suspended"), nullptr, nullptr));
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Thread is not valid"), nullptr, nullptr));
    }
    
    auto count  = thread.GetNumFrames();
    auto frames = Array<hxcppdbg::core::stack::NativeFrame>(0, count);

    for (int i = 0; i < count; i++)
    {
        auto frame = thread.GetFrameAtIndex(i);
        if (!frame.IsValid())
        {
            return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to read frame"), nullptr, nullptr));
        }

        frames->__SetItem(i, createNativeFrame(frame));
    }

    return hxcppdbg::core::ds::Result_obj::Success(frames);
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::getStackVariables(int threadIndex, int frameIndex)
{
    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Thread is not valid"), nullptr, nullptr));
    }

    auto frame = thread.GetFrameAtIndex(frameIndex);
    if (!frame.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to read frame"), nullptr, nullptr));
    }

    auto variables = frame.GetVariables(false, true, true, true);
    if (!variables.IsValid())
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Unable to get local variables"), nullptr, nullptr));
    }

    auto output = Array<hxcppdbg::core::locals::NativeLocal>(0, variables.GetSize());
    for (int i = 0; i < variables.GetSize(); i++)
    {
        auto variable = variables.GetValueAtIndex(i);
        auto name     = variable.GetName();
        auto type     = variable.GetTypeName();
        auto value    = String::create(variable.GetSummary());
        auto local    = hxcppdbg::core::locals::NativeLocal_obj::__new(String::create(name), value, String::create(value));

        output->__SetItem(i, local);
    }
    
    return hxcppdbg::core::ds::Result_obj::Success(output);
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::findStopReason()
{
    if (process.GetState() == ::lldb::StateType::eStateStopped)
    {
        // Figure out what caused us to be suspended.
        auto threadCount = process.GetNumThreads();
        for (auto i = 0; i < threadCount; i++)
        {
            auto thread = process.GetThreadAtIndex(i);
            auto reason = thread.GetStopReason();

            switch (reason)
            {
                case ::lldb::StopReason::eStopReasonBreakpoint:
                    {
                        auto breakpointID = thread.GetStopReasonDataAtIndex(0);

                        if (breakpointID == exceptionBreakpoint)
                        {
                            return hxcppdbg::core::ds::Result_obj::Success(hxcppdbg::core::drivers::StopReason_obj::ExceptionThrown(i));
                        }
                        else
                        {
                            return hxcppdbg::core::ds::Result_obj::Success(hxcppdbg::core::drivers::StopReason_obj::BreakpointHit(breakpointID, i));
                        }
                    }
                case ::lldb::StopReason::eStopReasonPlanComplete:
                    return hxcppdbg::core::ds::Result_obj::Success(hxcppdbg::core::drivers::StopReason_obj::Natural);
                default:
                    continue;
            }
        }

        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("No thread is stopped at a breakpoint"), nullptr, nullptr));
    }
    else
    {
        return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING("Process is not stopped"), nullptr, nullptr));
    }
}

hxcppdbg::core::stack::NativeFrame hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::createNativeFrame(::lldb::SBFrame _frame)
{
    auto lineEntry = _frame.GetLineEntry();
    auto fileSpec  = lineEntry.GetFileSpec();
    auto dir       = fileSpec.GetDirectory();
    auto absFile   = dir == nullptr ? "" : std::string(dir) + std::string("/") + std::string(fileSpec.GetFilename());
    auto fileName  = haxe::io::Path_obj::normalize(String::create(absFile.c_str()));
    auto symName   = std::string(_frame.GetSymbol().GetName());
    auto lineNum   = lineEntry.GetLine();

    auto anonNamespace = std::string("(anonymous namespace)::");
    auto buffer        = std::string();
    auto skip          = false;
    auto i             = 0;
    auto code          = char{ 0 };

    while (i < symName.length())
    {
        switch (code = symName.at(i))
        {
            case '(':
                if (!endsWith(buffer, "operator"))
                {
                    if (symName.substr(i, anonNamespace.length()) == anonNamespace)
                    {
                        i += anonNamespace.length();

                        continue;
                    }
                    else
                    {
                        skip = true;
                    }
                }
                else
                {
                    buffer.push_back(code);
                }
                break;
            
            case ')':
                if (skip)
                {
                    skip = false;
                }
                else
                {
                    buffer.push_back(code);
                }
                break;

            default:
                if (!skip)
                {
                    buffer.push_back(code);
                }
        }

        i++;
    }

    auto sym = String::create(buffer.c_str(), buffer.length());

    return hxcppdbg::core::stack::NativeFrame_obj::__new(fileName, sym, lineNum);
}

bool hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::endsWith(std::string const &_input, std::string const &_ending)
{
    if (_input.length() >= _ending.length())
    {
        return (0 == _input.compare(_input.length() - _ending.length(), _ending.length(), _ending));
    }
    else
    {
        return false;
    }
}

void hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::destroy()
{
    process.Destroy();
}

int hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::__GetType() const
{
    return lldbProcessType;
}

String hxcppdbg::core::drivers::lldb::native::LLDBProcess_obj::toString()
{
    return HX_CSTRING("LLDBProcess");
}