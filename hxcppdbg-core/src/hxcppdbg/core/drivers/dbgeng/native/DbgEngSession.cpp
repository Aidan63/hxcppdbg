#include "hxcpp.h"
#include "DbgEngSession.hpp"
#include "DbgEngContext.hpp"
#include "NativeModelData.hpp"

#include <filesystem>

using namespace hxcppdbg::core::drivers::dbgeng::native;
using namespace Debugger::DataModel::ClientEx;

DbgEngSession::DbgEngSession(
	cpp::Pointer<DbgEngContext> _ctx,
	std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>> _models)
	: ctx(_ctx)
	, models(std::move(_models))
	, stepOutBreakpointId(DEBUG_ANY_ID)
{
	//
}

int64_t DbgEngSession::createBreakpoint(String _file, int _line)
{
    auto result = S_OK;

    auto entry = DEBUG_SYMBOL_SOURCE_ENTRY();
    auto count = 0UL;
    if (!SUCCEEDED(result = (*ctx).symbols->GetSourceEntriesByLineWide(_line, _file.wchar_str(), DEBUG_GSEL_NEAREST_ONLY, &entry, 1, &count)))
    {
        hx::Throw(HX_CSTRING("Unable to get source entries"));
    }

    auto breakpoint = (IDebugBreakpoint*)nullptr;
    if (!SUCCEEDED(result = (*ctx).control->AddBreakpoint(DEBUG_BREAKPOINT_CODE, DEBUG_ANY_ID, &breakpoint)))
    {
        hx::Throw(HX_CSTRING("Unable to add breakpoint"));
    }

    if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ENABLED)))
    {
        hx::Throw(HX_CSTRING("Unable to add enabled flag to breakpoint"));
    }

    if (!SUCCEEDED(result = breakpoint->SetOffset(entry.Offset)))
    {
        hx::Throw(HX_CSTRING("Unable to breakpoint offset"));
    }

    auto id = 0UL;
    if (!SUCCEEDED(result = breakpoint->GetId(&id)))
    {
        hx::Throw(HX_CSTRING("Unable to get breakpoint Id"));
    }

    return id;
}

void DbgEngSession::removeBreakpoint(int64_t _id)
{
    auto result = 0UL;

    auto breakpoint = (IDebugBreakpoint*)nullptr;
    if (!SUCCEEDED(result = (*ctx).control->GetBreakpointById(_id, &breakpoint)))
    {
        hx::Throw(HX_CSTRING("Unable to get breakpoint from Id"));
    }

    if (!SUCCEEDED(result = (*ctx).control->RemoveBreakpoint(breakpoint)))
    {
        hx::Throw(HX_CSTRING("Unable to remove breakpoint"));
    }
}

Array<int> DbgEngSession::getThreads()
{
    try
    {
        auto threads = Object::CurrentProcess().KeyValue(L"Threads");
        auto count   = threads.CallMethod(L"Count").As<int>();
        auto output  = Array<int>(0, count);

        for (auto&& thread : threads)
        {
            output->Add(thread.KeyValue(L"Id").As<int>());
        }

        return output;
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

Dynamic DbgEngSession::getFrame(int _threadIndex, int _frameIndex)
{
    auto result = S_OK;

    auto systemId = 0UL;
    if (!SUCCEEDED(result = (*ctx).system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &systemId)))
    {
        hx::Throw(HX_CSTRING("Unable to get thread Id"));
    }

    try
    {
        auto findThread = [systemId](const Object&, const Object& _thread) { return _thread.KeyValue(L"Id").As<int>() == systemId; };
        auto thread     = Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", findThread);
        auto findFrame  = [_frameIndex](const Object&, const Object& frame) { return frame.KeyValue(L"Attributes").KeyValue(L"FrameNumber").As<int>() == _frameIndex; };
        auto frame      = thread.KeyValue(L"Stack").KeyValue(L"Frames").CallMethod(L"First", findFrame);

        return readFrame(frame);
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

Array<Dynamic> DbgEngSession::getCallStack(int _threadIndex)
{
    auto result = S_OK;

    auto systemId = 0UL;
    if (!SUCCEEDED(result = (*ctx).system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &systemId)))
    {
        hx::Throw(HX_CSTRING("Unable to get thread Id"));
    }

    try
    {
        auto predicate = [systemId](const Object&, const Object& _thread) { return _thread.KeyValue(L"Id").As<int>() == systemId; };
        auto thread    = Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", predicate);
        auto frames    = thread.KeyValue(L"Stack").KeyValue(L"Frames");
        auto count     = frames.CallMethod(L"Count").As<int>();
        auto output    = Array<Dynamic>(0, count);

        for (auto&& frame : frames)
        {
            output->Add(readFrame(frame));
        }

        return output;
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

cpp::Pointer<models::IDbgEngKeyable<String, Dynamic>> DbgEngSession::getVariables(int _threadIndex, int _frameIndex)
{
    auto result = S_OK;

    auto systemId = 0UL;
    if (!SUCCEEDED(result = (*ctx).system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &systemId)))
    {
        hx::Throw(HX_CSTRING("Unable to get thread Id"));
    }

    try
    {
        auto findThread = [systemId](const Object&, const Object& thread) { return thread.KeyValue(L"Id").As<int>() == systemId; };
        auto thread     = Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", findThread);
        auto findFrame  = [_frameIndex](const Object&, const Object& frame) { return frame.KeyValue(L"Attributes").KeyValue(L"FrameNumber").As<int>() == _frameIndex; };
        auto frame      = thread.KeyValue(L"Stack").KeyValue(L"Frames").CallMethod(L"First", findFrame);

        return new models::LazyLocalStore(frame.KeyValue(L"LocalVariables"));
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
    
}

cpp::Pointer<models::IDbgEngKeyable<String, Dynamic>> DbgEngSession::getArguments(int _threadIndex, int _frameIndex)
{
    hx::Throw(HX_CSTRING("Not Implemented"));

	return null();
}

void DbgEngSession::go()
{
	auto result = S_OK;

	auto current = 0UL;
	if (!SUCCEEDED(result = (*ctx).control->GetExecutionStatus(&current)))
	{
		hx::Throw(HX_CSTRING("Unable to get the target status"));
	}

	if (current != DEBUG_STATUS_BREAK)
	{
		hx::Throw(HX_CSTRING("Target is not suspended"));
	}

	if (!SUCCEEDED(result = (*ctx).control->SetExecutionStatus(DEBUG_STATUS_GO)))
	{
		hx::Throw(HX_CSTRING("Unable to set target execution status"));
	}
}

void DbgEngSession::step(int _threadIndex, int _step)
{
	auto result = S_OK;

	auto status = 0UL;
	if (!SUCCEEDED(result = (*ctx).control->GetExecutionStatus(&status)))
	{
		hx::Throw(HX_CSTRING("Unable to get the current execution status"));
	}

	if (status != DEBUG_STATUS_BREAK)
	{
		hx::Throw(HX_CSTRING("Target is not suspended"));
	}

	auto threadId = 0UL;
	if (!SUCCEEDED(result = (*ctx).system->GetThreadIdsByIndex(_threadIndex, 1, &threadId, nullptr)))
	{
		hx::Throw(HX_CSTRING("Failed to get thread ID from index"));
	}

	if (!SUCCEEDED(result = (*ctx).system->SetCurrentThreadId(threadId)))
	{
		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	auto mode = 0;
	switch (_step)
	{
	case 0:
		{
			mode = DEBUG_STATUS_STEP_INTO;

			break;
		}
	case 1:
		{
			mode = DEBUG_STATUS_STEP_OVER;

			break;
		}
	case 2:
		{
			auto offset = uint64_t{ 0 };
			if (!SUCCEEDED(result = (*ctx).control->GetReturnOffset(&offset)))
			{
				hx::Throw(HX_CSTRING("Unable to get return address"));
			}

			auto breakpoint = ComPtr<IDebugBreakpoint>();
			if (!SUCCEEDED(result = (*ctx).control->AddBreakpoint(DEBUG_BREAKPOINT_CODE, DEBUG_ANY_ID, &breakpoint)))
			{
				hx::Throw(HX_CSTRING("Unable to create breakpoint"));
			}

			if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ENABLED)))
			{
				hx::Throw(HX_CSTRING("Unable to enable breakpoint"));
			}

			if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ONE_SHOT)))
			{
				hx::Throw(HX_CSTRING("Unable to set the breakpoint to one shot"));
			}

			if (!SUCCEEDED(result = breakpoint->SetMatchThreadId(threadId)))
			{
				hx::Throw(HX_CSTRING("Unable to set the breakpoint to one shot"));
			}

			if (!SUCCEEDED(result = breakpoint->SetOffset(offset)))
			{
				hx::Throw(HX_CSTRING("Unable to set breakpoint offset"));
			}

			if (!SUCCEEDED(result = breakpoint->GetId(&stepOutBreakpointId)))
			{
				hx::Throw(HX_CSTRING("Unable to get breakpoint Id"));
			}

			mode = DEBUG_STATUS_GO;

			break;
		}
	default:
		hx::Throw(HX_CSTRING("Unsupported step mode"));
	}

	if (!SUCCEEDED(result = (*ctx).control->SetExecutionStatus(mode)))
	{
		hx::Throw(HX_CSTRING("Unable to change execution state"));
	}
}

void DbgEngSession::end()
{
	auto result = 0;
	
	if (!SUCCEEDED(result = (*ctx).client->TerminateCurrentProcess()))
	{
		hx::Throw(HX_CSTRING("Unable to terminate process"));
	}
}

bool DbgEngSession::interrupt()
{
    // It seems like we can use GetExecutionStatus from other threads, but I'm not entirely sure...

	auto status = 0UL;
	if (!SUCCEEDED((*ctx).control->GetExecutionStatus(&status)))
	{
		hx::Throw(HX_CSTRING("Unable to get execution status"));
	}

	if (status == DEBUG_STATUS_BREAK)
	{
		return false;
	}

	if (!SUCCEEDED((*ctx).control->SetInterrupt(DEBUG_INTERRUPT_EXIT)))
	{
		hx::Throw(HX_CSTRING("Unable to set interrupt"));
	}

	return true;
}

void DbgEngSession::wait(
	Dynamic _onBreakpoint,
	Dynamic _onException,
	Dynamic _onPaused,
	Dynamic _onExited,
	Dynamic _onThreadCreated,
	Dynamic _onThreadExited)
{
	hx::EnterGCFreeZone();

	auto result = S_OK;

	switch (result = (*ctx).control->WaitForEvent(DEBUG_WAIT_DEFAULT, INFINITE))
	{
		case S_OK:
			{
				hx::ExitGCFreeZone();

				auto type       = 0UL;
				auto processIdx = 0UL;
				auto threadIdx  = 0UL;

				if (!SUCCEEDED((*ctx).control->GetLastEventInformation(&type, &processIdx, &threadIdx, nullptr, 0, nullptr, nullptr, 0, nullptr)))
				{
					hx::Throw(HX_CSTRING("Unable to get last event information"));
				}
				else
				{
					switch (type)
					{
						case 0:
							{
								_onPaused();
							}
							break;

						case DEBUG_EVENT_CREATE_PROCESS:
							{
								hx::Throw(HX_CSTRING("Unexpected process created event"));
							}
							break;

						case DEBUG_EVENT_EXIT_PROCESS:
							{
								auto code = 0UL;
								if (S_OK == (*ctx).client->GetExitCode(&code))
								{
									_onExited(code);
								}
								else
								{
									hx::Throw(HX_CSTRING("Process exited but unable to get exit code"));
								}
							}
							break;

						case DEBUG_EVENT_CREATE_THREAD:
							{
								_onThreadCreated();
							}
							break;

						case DEBUG_EVENT_EXIT_THREAD:
							{
								_onThreadExited();
							}
							break;

						case DEBUG_EVENT_BREAKPOINT:
							{
								auto event = DEBUG_LAST_EVENT_INFO_BREAKPOINT();
								if (!SUCCEEDED((*ctx).control->GetLastEventInformation(&type, &processIdx, &threadIdx, &event, sizeof(DEBUG_LAST_EVENT_INFO_BREAKPOINT), nullptr, nullptr, 0, nullptr)))
								{
									hx::Throw(HX_CSTRING("Unable to get last event breakpoint information"));
								}
								else
								{
									if (event.Id == stepOutBreakpointId)
									{
										stepOutBreakpointId = DEBUG_ANY_ID;

										_onPaused();
									}
									else
									{
										_onBreakpoint(threadIdx, event.Id);
									}
								}
							}
							break;

						case DEBUG_EVENT_EXCEPTION:
							{
								auto event = DEBUG_LAST_EVENT_INFO_EXCEPTION();
								if (!SUCCEEDED((*ctx).control->GetLastEventInformation(&type, &processIdx, &threadIdx, &event, sizeof(DEBUG_LAST_EVENT_INFO_EXCEPTION), nullptr, nullptr, 0, nullptr)))
								{
									hx::Throw(HX_CSTRING("Unable to get last event exception information"));
								}
								else
								{
									_onException(threadIdx, event.ExceptionRecord.ExceptionCode, tryFindThrownObject(threadIdx));
								}

							}
							break;

						default:
							{
								hx::Throw(HX_CSTRING("Unaccounted for last event type"));
							}
					}
				}
			}
			break;

		case E_PENDING:
			{
				// Exit iterrupt was issued due to a pause request.
				// Restart execution so we can ignore any generated exceptions to break the process.

				hx::ExitGCFreeZone();

				if (!SUCCEEDED((*ctx).control->SetExecutionStatus(DEBUG_STATUS_GO)))
				{
					hx::Throw(HX_CSTRING("Unable to set execution status"));
				}

				if (!SUCCEEDED((*ctx).control->SetInterrupt(DEBUG_INTERRUPT_ACTIVE)))
				{
					hx::Throw(HX_CSTRING("Unable to set active interrupt"));
				}

				hx::EnterGCFreeZone();

				if (!SUCCEEDED((*ctx).control->WaitForEvent(DEBUG_WAIT_DEFAULT, INFINITE)))
				{
					hx::ExitGCFreeZone();

					hx::Throw(HX_CSTRING("Unable to wait for event"));
				}

				hx::ExitGCFreeZone();

				_onPaused();
			}
			break;

		case E_UNEXPECTED:
			{
				hx::ExitGCFreeZone();

				auto exitCode = 0UL;
				if (S_OK == (*ctx).client->GetExitCode(&exitCode))
				{
					_onExited(exitCode);
				}
				else
				{
					hx::Throw(HX_CSTRING("Unknown WaitForEvent return value"));
				}
			}
			break;

		default:
			{
				hx::ExitGCFreeZone();
				
				hx::Throw(HX_CSTRING("Unknown WaitForEvent return value"));
			}
	}
}

NativeModelData DbgEngSession::tryFindThrownObject(int _threadIndex)
{
	auto result = S_OK;

	auto systemId = 0ul;
	if (!SUCCEEDED(result = (*ctx).system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &systemId)))
	{
		hx::Throw(HX_CSTRING("Unable to get thread from index"));
	}

	try
	{
		auto predicate = [systemId](const Object&, const Object& thread) { return thread.KeyValue(L"Id").As<int>() == systemId; };
		auto thread    = Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", predicate);
		auto frames    = thread.KeyValue(L"Stack").KeyValue(L"Frames");

		for (auto&& frame : frames)
		{
			auto converted = readFrame(frame)->__Field(HX_CSTRING("func"), hx::PropertyAccess::paccDynamic).asString();

			if (converted == HX_CSTRING("hx::Throw") || converted == HX_CSTRING("hx::Rethrow"))
			{
				return
					frame
						.KeyValue(L"Parameters")
						.KeyValue(L"inDynamic")
						.Dereference()
						.GetValue()
						.TryCastToRuntimeType()
						.KeyValue(L"HxcppdbgModelData")
						.As<NativeModelData>();
			}
		}

		return null();
	}
	catch (const std::exception&)
	{
		return null();
	}
}

int DbgEngSession::backtickCount(const std::wstring& _input)
{
	auto count = 0;

	for (auto&& character : _input)
	{
		if (character == L'`')
		{
			count++;
		}
		else
		{
			return count;
		}
	}

	return count;
}

bool DbgEngSession::endsWith(const std::wstring& _input, const std::wstring& _ending)
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

String DbgEngSession::cleanFunctionName(const std::wstring& _input)
{
	// dbgeng symbol names are prefixed with the module followed by a '!' before the rest of the symbol name.
	auto modulePivot   = _input.find_first_of(L'!');
	auto withoutModule = _input.substr(modulePivot + 1);

	// Here are some examples of dbgeng symbols and what I think parts of it mean...
	// There's next to no information about the ` and ' characters as they seem to be msvc internal stuff.
	//
	// sub::Resources_obj::subscribe
	// `Main_obj::main'::`2'::_hx_Closure_0::_hx_run
	// ``Main_obj::main'::`2'::_hx_Closure_1::_hx_run'::`2'::_hx_Closure_0::_hx_run(int i)
	// haxe::`anonymous namespace'::__default_trace::_hx_run(Dynamic v, Dynamic infos)
	//
	// The number of prefixed backticks refers too the number of "nameless" frames. The bottom symbol name was from
	// two nested closures which are implemented as structs defined in the function.
	// The text between the single quotes are not part of the namespace type path and the number of these quotes
	// should match the number of initial backticks.
	// What the stuff between the single quotes means I'm not sure of (number of frames which include that "frameless" code?)
	// but I also don't think we need to care.
	auto count            = backtickCount(withoutModule);
	auto buffer           = std::wstring();
	auto withoutBackticks = withoutModule.substr(count);
	auto anonNamespace    = std::wstring(L"`anonymous namespace'::");

	auto skip = false;
	auto i    = int{ 0 };
	while (i < withoutBackticks.length())
	{
		switch (withoutBackticks.at(i))
		{
			case L'\'':
				skip = !skip;
				break;
			case L'(':
				if (endsWith(buffer, std::wstring(L"operator")))
				{
					buffer.push_back(L'(');
				}
				else
				{
					// If we enconter an open bracket then we are at the last part of a function (its arguments) so we can skip the rest.
					// arguments are handled based on the sourcemap, not the symbol name.
					break;
				}
				break;
			case L'`':
				if (!skip)
				{
					if (withoutBackticks.substr(i, anonNamespace.length()) == anonNamespace)
					{
						i += anonNamespace.length();

						continue;
					}
				}
				else
				{
					buffer.push_back(L'`');
				}
				break;
			default:
				buffer.push_back(withoutBackticks[i]);
				break;
		}

		i++;
	}

	return String::create(buffer.data(), buffer.length());
}

Dynamic DbgEngSession::readFrame(const Debugger::DataModel::ClientEx::Object& _frame)
{
    auto attributes = _frame.KeyValue(L"Attributes");
    auto offset     = attributes.KeyValue(L"InstructionOffset").As<uint64_t>();
    auto address    = attributes.KeyValue(L"FrameOffset").As<uint64_t>();

    auto nameBuffer = std::array<wchar_t, 1024>();
    auto nameLength = 0UL;

    auto line = 0UL;

    auto fileName = SUCCEEDED((*ctx).symbols->GetLineByOffsetWide(offset, &line, nameBuffer.data(), nameBuffer.size(), &nameLength, nullptr))
        ? String::create(nameBuffer.data(), nameLength - 1)
        : HX_CSTRING("Unknown file");

    auto funcName = SUCCEEDED((*ctx).symbols->GetNameByOffsetWide(offset, nameBuffer.data(), nameBuffer.size(), &nameLength, nullptr))
        ? cleanFunctionName(std::wstring(nameBuffer.data(), nameLength - 1))
        : HX_CSTRING("Unknown function");

    return
        hx::AnonStruct4_obj<String, String, int, cpp::Int64>::Create(
            HX_CSTRING("file"), fileName,
            HX_CSTRING("func"), funcName,
            HX_CSTRING("line"), line,
            HX_CSTRING("address"), address);
}