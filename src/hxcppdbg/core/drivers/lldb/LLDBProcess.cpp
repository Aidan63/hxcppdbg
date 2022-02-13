#include "LLDBProcess.hpp"

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

void hxcppdbg::core::drivers::lldb::LLDBProcess::dump()
{
    if (process.GetState() == ::lldb::StateType::eStateStopped)
    {
        auto thread = process.GetSelectedThread();
        auto frames = std::vector<::lldb::SBFrame>(thread.GetNumFrames());

        for (int i = 0; i < frames.size(); i++)
        {
            auto f = (frames[i] = thread.GetFrameAtIndex(i));

            // file, line, and function.
            auto lineEntry = f.GetLineEntry();
            auto fileName  = lineEntry.GetFileSpec().GetFilename();
            auto lineNum   = lineEntry.GetLine();
            auto funcName  = f.GetFunctionName();
            auto pivot     = std::string(funcName).find_first_of('(');
            auto cleaned   = (pivot != std::string::npos) ? String(funcName, pivot) : String(funcName);

            std::cout << cleaned.utf8_str() << " Line " << lineNum << std::endl;
        }
    }
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