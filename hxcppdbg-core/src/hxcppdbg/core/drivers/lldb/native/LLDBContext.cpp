#include <hxcpp.h>
#include "LLDBContext.hpp"
#include <limits>
#include "fmt/format.h"

void hxcppdbg::core::drivers::lldb::native::LLDBContext::create(String _exe, Dynamic _success, Dynamic _failure)
{
    auto debugger = ::lldb::SBDebugger::Create();
    if (debugger.IsValid())
    {
        debugger.SetAsync(true);

        auto target = debugger.CreateTarget(_exe.utf8_str());
        if (target.IsValid())
        {
            _success(::cpp::Pointer<LLDBContext>(new LLDBContext(debugger, target)));
        }
        else
        {
            _failure(HX_CSTRING("Unable to create LLDB target"));
        }
    }
    else
    {
        _failure(HX_CSTRING("Unable to create LLDB debugger"));
    }
}

hxcppdbg::core::drivers::lldb::native::LLDBContext::LLDBContext(::lldb::SBDebugger _debugger, ::lldb::SBTarget _target)
    : debugger(_debugger)
    , target(_target)
    , listener(_debugger.GetListener())
    , interruptBroadcaster(::lldb::SBBroadcaster("user-interrupt"))
    , exceptionBreakpoint(target.BreakpointCreateForException(::lldb::eLanguageTypeC_plus_plus, false, true))
    , process(std::nullopt)
{
    interruptBroadcaster.AddListener(listener, InterruptEvent::Pause);
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::wait(
    Dynamic _onException,
    Dynamic _onBreakpoint,
    Dynamic _onInterrupt,
    Dynamic _onBreak)
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
                    case ::lldb::eStateInvalid:
                        //
                        break;

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
                                    case ::lldb::StopReason::eStopReasonBreakpoint:
                                        {
                                            hx::ExitGCFreeZone();

                                            auto bp = thread.GetStopReasonDataAtIndex(0);
                                            if (bp == exceptionBreakpoint.GetID())
                                            {
                                                _onException(i);
                                            }
                                            {
                                                _onBreakpoint(i, cpp::Int64Struct(bp));
                                            }

                                            return;
                                        }

                                    case ::lldb::StopReason::eStopReasonException:
                                        {
                                            hx::ExitGCFreeZone();

                                            _onException(i);

                                            return;
                                        }

                                    case ::lldb::StopReason::eStopReasonPlanComplete:
                                        {
                                            hx::ExitGCFreeZone();

                                            _onBreak();

                                            return;
                                        }
                                }
                            }
                            break;
                        }

                    case ::lldb::eStateRunning:
                        //
                        break;

                    case ::lldb::eStateStepping:
                        //
                        break;

                    case ::lldb::eStateCrashed:
                        //
                        break;

                    case ::lldb::eStateExited:
                        {
                            hx::ExitGCFreeZone();

                            _onInterrupt();

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
                            hx::ExitGCFreeZone();

                            _onInterrupt();

                            return;
                        }

                    case InterruptEvent::Stop:
                        {
                            //
                        }
                        break;

                    case InterruptEvent::Restart:
                        {
                            if (process.has_value())
                            {
                                //
                            }
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

void hxcppdbg::core::drivers::lldb::native::LLDBContext::interrupt(int _event)
{
    interruptBroadcaster.BroadcastEventByType(static_cast<InterruptEvent>(_event));
}

bool hxcppdbg::core::drivers::lldb::native::LLDBContext::suspend()
{
    switch (process->GetState())
    {
        case ::lldb::eStateStopped:
            return true;
        default:
            {
                auto error = process->Stop();
                if (error.Fail())
                {
                    hx::Throw(String::create(error.GetCString()));
                }
                
                return false;
            }
    }
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::start(String _cwd)
{
    auto options = target.GetLaunchInfo();
    options.SetWorkingDirectory(_cwd.utf8_str());

    auto error = ::lldb::SBError();
    auto proc  = target.Launch(options, error);

    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }
    
    process = std::optional<::lldb::SBProcess>(proc);
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::stop()
{
    //
}

void hxcppdbg::core::drivers::lldb::native::LLDBContext::resume()
{
    switch (process->GetState())
    {
        case ::lldb::eStateStopped:
            {
                auto error = process->Continue();
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
    if (!process.has_value())
    {
        hx::Throw(HX_CSTRING("Process has not started"));
    }

    auto thread = process.value().GetThreadAtIndex(_threadIndex);
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

cpp::Int64Struct hxcppdbg::core::drivers::lldb::native::LLDBContext::createBreakpoint(String _file, int _line)
{
    auto bp = target.BreakpointCreateByLocation(_file.utf8_str(), _line);
    if (!bp.IsValid())
    {
        hx::Throw(HX_CSTRING("Unable to create breakpoint"));
    }

    return cpp::Int64Struct(bp.GetID());
}

bool hxcppdbg::core::drivers::lldb::native::LLDBContext::removeBreakpoint(cpp::Int64Struct _id)
{
    return target.BreakpointDelete(_id.get());
}

hx::Anon hxcppdbg::core::drivers::lldb::native::LLDBContext::getStackFrame(int _threadIndex, int _frameIndex)
{
    if (!process.has_value())
    {
        hx::Throw(HX_CSTRING("Process has not started"));
    }

    auto thread = process.value().GetThreadAtIndex(_threadIndex);
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
    if (!process.has_value())
    {
        hx::Throw(HX_CSTRING("Process has not started"));
    }

    auto thread = process.value().GetThreadAtIndex(_threadIndex);
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