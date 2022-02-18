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

// Variable

hxcppdbg::core::drivers::lldb::Variable::Variable(String _name, String _value, String _type)
    : name(_name), value(_value), type(_type)
{
    //
}

void hxcppdbg::core::drivers::lldb::Variable::__Mark(HX_MARK_PARAMS)
{
    HX_MARK_BEGIN_CLASS(Frame);
	HX_MARK_MEMBER_NAME(name,"name");
    HX_MARK_MEMBER_NAME(value,"value");
    HX_MARK_MEMBER_NAME(type,"type");
	HX_MARK_END_CLASS();
}

#if HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::lldb::Variable::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(name,"name");
    HX_VISIT_MEMBER_NAME(value,"value");
    HX_VISIT_MEMBER_NAME(type,"type");
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

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame> hxcppdbg::core::drivers::lldb::LLDBProcess::stepOver(int threadIndex)
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

    ::lldb::SBError error;
    thread.StepOver(::lldb::RunMode::eOnlyDuringStepping, error);

    if (error.Fail())
    {
        hx::Throw(String::create(error.GetCString()));
    }

    return getStackFrame(threadIndex, 0);
}

hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame> hxcppdbg::core::drivers::lldb::LLDBProcess::getStackFrame(int threadIndex, int frameIndex)
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
    auto fileName  = String::create(lineEntry.GetFileSpec().GetFilename());
    auto funcName  = String::create(frame.GetFunctionName());
    auto symName   = String::create(frame.GetSymbol().GetName());
    auto lineNum   = lineEntry.GetLine();

    return hx::ObjectPtr<Frame>(new Frame(fileName, funcName, symName, lineNum));
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>> hxcppdbg::core::drivers::lldb::LLDBProcess::getStackFrames(int threadIndex)
{
    if (process.GetState() != ::lldb::StateType::eStateStopped)
    {
        return Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>>(0, 0);
    }

    auto thread = process.GetThreadAtIndex(threadIndex);
    if (!thread.IsValid())
    {
        hx::Throw(HX_CSTRING("Thread is not valid"));
    }
    
    auto count  = thread.GetNumFrames();
    auto frames = Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>>(0, count);

    for (int i = 0; i < count; i++)
    {
        frames->__SetItem(i, getStackFrame(threadIndex, i));
    }

    return frames;
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Variable>> hxcppdbg::core::drivers::lldb::LLDBProcess::getStackVariables(int threadIndex, int frameIndex)
{
    auto thread    = process.GetThreadAtIndex(threadIndex);
    auto frame     = thread.GetFrameAtIndex(frameIndex);
    auto variables = frame.GetVariables(true, true, true, true);
    auto output    = Array<hx::ObjectPtr<Variable>>(0, variables.GetSize());

    for (int i = 0; i < variables.GetSize(); i++)
    {
        auto variable = variables.GetValueAtIndex(i);
        auto name     = variable.GetName();
        auto type     = variable.GetTypeName();

        String varValue;
        if (std::string(type) == std::string("String"))
        {
            varValue = hxcppdbg::core::drivers::lldb::extractString(variable);
        }
        else
        {
            varValue = String::create(variable.GetValue());
        }

        output->__SetItem(i, hx::ObjectPtr<Variable>(new Variable(String::create(name), varValue, String::create(type))));
    }
    
    return output;
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