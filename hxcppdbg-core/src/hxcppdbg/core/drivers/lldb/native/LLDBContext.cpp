#include <hxcpp.h>
#include "LLDBContext.hpp"
#include <limits>

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
                                            _onBreakpoint(i, cpp::Int64Struct(thread.GetStopReasonDataAtIndex(0)));

                                            return;
                                        }
                                        break;

                                    case ::lldb::StopReason::eStopReasonException:
                                        //
                                        break;

                                    case ::lldb::StopReason::eStopReasonPlanComplete:
                                        //
                                        break;
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
                        //
                        break;
                }
            }
            else if (event.BroadcasterMatchesRef(interruptBroadcaster))
            {
                switch (event.GetType())
                {
                    case InterruptEvent::Pause:
                        {
                            _onBreak();

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

void hxcppdbg::core::drivers::lldb::native::LLDBContext::step()
{
    //
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

