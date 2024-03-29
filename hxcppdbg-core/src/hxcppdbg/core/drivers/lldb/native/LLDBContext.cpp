#include <hxcpp.h>
#include "LLDBContext.hpp"
#include <limits>
#include "fmt/format.h"

cpp::Pointer<hxcppdbg::core::drivers::lldb::native::LLDBContext> hxcppdbg::core::drivers::lldb::native::LLDBContext::create(String _cwd, String _exe)
{
    auto error = ::lldb::SBDebugger::InitializeWithErrorHandling();
    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }

    auto debugger = ::lldb::SBDebugger::Create();
    if (!debugger.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to create debugger"));
    }

    debugger.SetAsync(true);

    auto target = debugger.CreateTarget(_exe.utf8_str());
    if (!target.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to create target"));
    }

    auto options = target.GetLaunchInfo();
    options.SetWorkingDirectory(_cwd.utf8_str());
    options.SetLaunchFlags(::lldb::LaunchFlags::eLaunchFlagStopAtEntry);

    auto process = target.Launch(options, error);

    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }
    
    return cpp::Pointer<LLDBContext>(new LLDBContext(debugger, target, process));
}

hxcppdbg::core::drivers::lldb::native::LLDBContext::LLDBContext(::lldb::SBDebugger _debugger, ::lldb::SBTarget _target, ::lldb::SBProcess _process)
    : debugger(_debugger)
    , target(_target)
    , listener(_debugger.GetListener())
    , interruptBroadcaster(::lldb::SBBroadcaster("user-interrupt"))
    , exceptionBreakpoint(target.BreakpointCreateForException(::lldb::eLanguageTypeC_plus_plus, false, true))
    , process(_process)
{
    interruptBroadcaster.AddListener(listener, InterruptEvent::Pause);
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::wait(
    Dynamic _onException,
    Dynamic _onBreakpoint,
    Dynamic _onPaused,
    Dynamic _onExited)
{
    auto event = ::lldb::SBEvent();
    auto done  = false;

    hx::EnterGCFreeZone();

    while (!done)
    {
        if (listener.WaitForEvent(std::numeric_limits<uint32_t>::max(), event))
        {
            if (::lldb::SBProcess::EventIsProcessEvent(event))
            {
                auto val = ::lldb::SBProcess::GetStateFromEvent(event);

                switch (val)
                {
                    case ::lldb::eStateStopped:
                        {
                            auto process     = ::lldb::SBProcess::GetProcessFromEvent(event);
                            auto threadCount = process.GetNumThreads();

                            for (auto i = 0; i < threadCount; i++)
                            {
                                auto thread = process.GetThreadAtIndex(i);
                                auto reason = thread.GetStopReason();

                                switch (reason)
                                {
                                    case ::lldb::StopReason::eStopReasonInvalid:
                                        {
                                            break;
                                        }

                                    case ::lldb::StopReason::eStopReasonBreakpoint:
                                        {
                                            auto bp = thread.GetStopReasonDataAtIndex(0);
                                            if (bp == exceptionBreakpoint.GetID())
                                            {
                                                hx::ExitGCFreeZone();

                                                _onException(i);
                                            }
                                            else
                                            {
                                                hx::ExitGCFreeZone();
                                                
                                                _onBreakpoint(i, bp);
                                            }

                                            return;
                                        }

                                    case ::lldb::StopReason::eStopReasonException:
                                        {
                                            hx::ExitGCFreeZone();

                                            _onException(i);

                                            return;
                                        }

                                    default:
                                        {
                                            hx::ExitGCFreeZone();

                                            _onPaused();

                                            return;
                                        }
                                }
                            }
                            break;
                        }

                    case ::lldb::eStateExited:
                        {
                            auto process = ::lldb::SBProcess::GetProcessFromEvent(event);

                            hx::ExitGCFreeZone();

                            _onExited(process.GetExitStatus());

                            return;
                        }
                }
            }
            else if (event.BroadcasterMatchesRef(interruptBroadcaster))
            {
                switch (event.GetType())
                {
                    case InterruptEvent::Pause:
                        {
                            auto error = process.Stop();
                            if (error.Fail())
                            {
                                hx::ExitGCFreeZone();
                                hx::Throw(String::create(error.GetCString()));
                            }

                            _onPaused();

                            return;
                        }

                    case InterruptEvent::Stop:
                        {
                            //
                        }
                        break;

                    case InterruptEvent::Restart:
                        {
                            //
                        }
                        break;
                }
            }
            else
            {
                //
            }
        }
    }
}

bool hxcppdbg::core::drivers::lldb::native::LLDBContext::interrupt(int _event)
{
    switch (process.GetState())
    {
        case ::lldb::eStateStopped:
            return false;
        default:
            {
                interruptBroadcaster.BroadcastEventByType(static_cast<InterruptEvent>(_event));

                return true;
            }
    }
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::start()
{
    auto error = process.Continue();
    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::stop()
{
    //
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::resume()
{
    switch (process.GetState())
    {
        case ::lldb::eStateStopped:
            {
                auto error = process.Continue();
                if (error.Fail())
                {
                    hx::Throw(String::create(error.GetCString()));
                }

                break;
            }
        default:
            hx::Throw(HX_CSTRING("Process is not resumable"));
    }
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::step(int _threadIndex, int _type)
{
    auto thread = process.GetThreadAtIndex(_threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to get thread"));
    }

    switch (_type)
    {
        case 0:
            {
                hx::AutoGCFreeZone();

                thread.StepInto();

                break;
            }

        case 1:
            {
                hx::AutoGCFreeZone();

                thread.StepOver();

                break;
            }

        case 2:
            {
                hx::AutoGCFreeZone();

                thread.StepOut();

                break;
            }

        default:
            hx::Throw(HX_CSTRING("Unknown step mode"));
    }
}

int64_t hxcppdbg::core::drivers::lldb::native::LLDBContext::createBreakpoint(String _file, int _line)
{
    auto bp = target.BreakpointCreateByLocation(_file.utf8_str(), _line);
    if (!bp.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to create breakpoint"));
    }

    return bp.GetID();
}

bool hxcppdbg::core::drivers::lldb::native::LLDBContext::removeBreakpoint(int64_t _id)
{
    return target.BreakpointDelete(_id);
}

hx::Anon hxcppdbg::core::drivers::lldb::native::LLDBContext::getStackFrame(int _threadIndex, int _frameIndex)
{
    auto thread = process.GetThreadAtIndex(_threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to get thread"));
    }

    auto frame = thread.GetFrameAtIndex(_frameIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to get frame"));
    }

    auto lineEntry  = frame.GetLineEntry();
    auto fileSpec   = lineEntry.GetFileSpec();
    auto lineNumber = lineEntry.GetLine();
    auto directory  = fileSpec.GetDirectory();
    auto filename   = fileSpec.GetFilename();
    auto rawSymbol  = frame.GetFunctionName();

    auto filePath   = String::create(directory == nullptr ? filename : fmt::format("{0}/{1}", directory, filename).c_str());

    auto symbol        = std::string(frame.GetSymbol().GetName());
    auto anonNamespace = std::string("(anonymous namespace)::");
    auto buffer        = std::string();
    auto skip          = false;
    auto i             = 0;
    auto code          = char{ 0 };

    while (i < symbol.length())
    {
        switch (code = symbol.at(i))
        {
            case '(':
                if (!endsWith(buffer, "operator"))
                {
                    if (symbol.substr(i, anonNamespace.length()) == anonNamespace)
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

    auto anon = new hx::Anon_obj();
    anon->Add(HX_CSTRING("path"), filePath);
    anon->Add(HX_CSTRING("symbol"), String::create(buffer.c_str(), buffer.length()));
    anon->Add(HX_CSTRING("line"), lineNumber);

    return hx::Anon(anon);
}

Array<hx::Anon> hxcppdbg::core::drivers::lldb::native::LLDBContext::getStackFrames(int _threadIndex)
{
    auto thread = process.GetThreadAtIndex(_threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to get thread"));
    }

    auto frames = Array<hx::Anon>(0, 0);
    for (auto i = 0; i < thread.GetNumFrames(); i++)
    {
        frames->push(getStackFrame(_threadIndex, i));
    }

    return frames;
}

bool hxcppdbg::core::drivers::lldb::native::LLDBContext::endsWith(std::string const &_input, std::string const &_ending)
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

Array<hx::Anon> hxcppdbg::core::drivers::lldb::native::LLDBContext::getThreads()
{
    auto output = Array<hx::Anon>(0, 0);

    for (auto i = 0; i < process.GetNumThreads(); i++)
    {
        auto thread = process.GetThreadAtIndex(i);
        if (!thread.IsValid())
        {
            hx::Throw(HX_CSTRING("Invalid thread"));
        }

        // String::create(thread.GetName())

        auto anon = new hx::Anon_obj();
        anon->Add(HX_CSTRING("index"), i);
        anon->Add(HX_CSTRING("name"), HX_CSTRING("thread"));

        output->Add(anon);
    }

    return output;
}

Array<hx::Anon> hxcppdbg::core::drivers::lldb::native::LLDBContext::getLocals(int _threadIdx, int _frameIdx)
{
    auto thread = process.GetThreadAtIndex(_threadIdx);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to get thread"));
    }

    auto frame = thread.GetFrameAtIndex(_frameIdx);
    if (!frame.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to get frame"));
    }

    auto locals = frame.GetVariables(false, true, false, true);
    if (!locals.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to get local variables"));
    }

    auto output = Array<hx::Anon>(0, 0);

    for (auto i = 0; i < locals.GetSize(); i++)
    {
        auto local = locals.GetValueAtIndex(i);
        if (!local.IsValid())
        {
            hx::Throw(HX_CSTRING("Local variable is not valid"));
        }

        auto name = String::create(local.GetName());
        auto type = String::create(local.GetTypeName());
        auto anon = new hx::Anon_obj();

        anon->Add(HX_CSTRING("name"), name);
        anon->Add(HX_CSTRING("type"), type);

        output.Add(anon);
    }

    return output;
}

Array<hx::Anon> hxcppdbg::core::drivers::lldb::native::LLDBContext::getArguments(int _threadIdx, int _frameIdx)
{
    auto thread = process.GetThreadAtIndex(_threadIdx);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to get thread"));
    }

    auto frame  = thread.GetFrameAtIndex(_frameIdx);
    if (!frame.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to get frame"));
    }

    auto locals = frame.GetVariables(true, false, false, true);
    if (!locals.IsValid())
    {
        hx::Throw(HX_CSTRING("Failed to get local variables"));
    }

    auto output = Array<hx::Anon>(0, 0);

    for (auto i = 0; i < locals.GetSize(); i++)
    {
        auto local = locals.GetValueAtIndex(i);
        if (!local.IsValid())
        {
            hx::Throw(HX_CSTRING("Local variable is not valid"));
        }
        
        auto name = String::create(local.GetName());
        auto type = String::create(local.GetTypeName());
        auto anon = new hx::Anon_obj();

        anon->Add(HX_CSTRING("name"), name);
        anon->Add(HX_CSTRING("type"), type);

        output.Add(anon);
    }

    return output;
}