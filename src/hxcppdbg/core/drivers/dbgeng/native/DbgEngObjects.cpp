#include <hxcpp.h>

#include "DbgEngObjects.hpp"

hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::createFromFile(String file, Dynamic _onBreakpointCb)
{
	// Should we request the highest version or not?
	// Don't know what the required windows version is for the different versions.
	auto client = PDEBUG_CLIENT7{ nullptr };
	if (!SUCCEEDED(DebugCreate(__uuidof(PDEBUG_CLIENT7), (void**)&client)))
	{
		hx::Throw(HX_CSTRING("Unable to create IDebugClient object"));
	}

	auto control = PDEBUG_CONTROL{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(PDEBUG_CONTROL), (void**)&control)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugControl object from client"));
	}

	auto symbols = PDEBUG_SYMBOLS5{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(PDEBUG_SYMBOLS5), (void**)&symbols)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugSymbol object from client"));
	}

	auto events = std::make_unique<DebugEventCallbacks>(client, _onBreakpointCb);
	if (!SUCCEEDED(client->SetEventCallbacksWide(events.get())))
	{
		hx::Throw(HX_CSTRING("Unable to set events callback"));
	}

	if (!SUCCEEDED(client->CreateProcessAndAttach(NULL, PSTR(file.utf8_str()), DEBUG_PROCESS, 0, DEBUG_ATTACH_DEFAULT)))
	{
		hx::Throw(HX_CSTRING("Unable to create and attach to process"));
	}

	// Even after the above create and attach call the process will not have been started.
	// Our custom callback class will suspend the process as soon as the process starts so we can do whatever we want.
	// Once the process has been suspended this wait for event function will return.
	hx::EnterGCFreeZone();

	if (!SUCCEEDED(control->WaitForEvent(0, INFINITE)))
	{
		hx::ExitGCFreeZone();
		hx::Throw(HX_CSTRING("Failed to wait for event"));
	}

	hx::ExitGCFreeZone();

	auto status = ULONG{ 0 };
	if (!SUCCEEDED(control->GetExecutionStatus(&status)))
	{
		hx::Throw(HX_CSTRING("Failed to get execution status"));
	}

	if (status != DEBUG_STATUS_BREAK)
	{
		hx::Throw(HX_CSTRING("Process is not suspended"));
	}

	return hx::ObjectPtr<DbgEngObjects>(new DbgEngObjects(client, control, symbols, std::move(events), _onBreakpointCb));
}

hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::DbgEngObjects(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, std::unique_ptr<DebugEventCallbacks> _events, Dynamic _onBreakpointCb)
	: client(_client), control(_control), symbols(_symbols), events(std::move(_events)), onBreakpointCb(_onBreakpointCb)
{
	//
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(DbgEngObjects);
	HX_MARK_MEMBER_NAME(onBreakpointCb, "onBreakpointCb");
	HX_MARK_END_CLASS();
}

#ifdef HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::__Visit(HX_VISIT_PARAMS)
{
	HX_VISIT_MEMBER_NAME(onBreakpointCb, "onBreakpointCb");
}

#endif

hx::Null<int> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::createBreakpoint(String _file, int _line)
{
	auto entry = DEBUG_SYMBOL_SOURCE_ENTRY();
    auto count = ULONG{ 0 };
	if (!SUCCEEDED(symbols->GetSourceEntriesByLine(_line, _file.utf8_str(), DEBUG_GSEL_NEAREST_ONLY, &entry, 1, &count)))
	{
		return null();
	}

	auto breakpoint = PDEBUG_BREAKPOINT{ nullptr };
	if (!SUCCEEDED(control->AddBreakpoint(DEBUG_BREAKPOINT_CODE, DEBUG_ANY_ID, &breakpoint)))
	{
		hx::Throw(HX_CSTRING("unable to add breakpoint"));
	}

	if (!SUCCEEDED(breakpoint->AddFlags(DEBUG_BREAKPOINT_ENABLED)))
	{
		hx::Throw(HX_CSTRING("unable to enable breakpoint"));
	}

	if (!SUCCEEDED(breakpoint->SetOffset(entry.Offset)))
	{
		hx::Throw(HX_CSTRING("unable to set offset"));
	}

	auto id = ULONG{ 0 };
	if (!SUCCEEDED(breakpoint->GetId(&id)))
	{
		hx::Throw(HX_CSTRING("unable to get id"));
	}

	return id;
}

bool hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::removeBreakpoint(int id)
{
	return false;
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame>> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::getCallStack(int _threadID)
{
	auto system = PDEBUG_SYSTEM_OBJECTS4{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(IDebugSystemObjects4), (void**)&system)))
	{
		hx::Throw(HX_CSTRING("Unable to get system object"));
	}

	if (!SUCCEEDED(system->SetCurrentThreadId(_threadID)))
	{
		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	auto frames = std::vector<DEBUG_STACK_FRAME>(128);
	auto filled = ULONG{ 0 };
	if (!SUCCEEDED(control->GetStackTrace(0, 0, 0, frames.data(), frames.capacity(), &filled)))
	{
		hx::Throw(HX_CSTRING("Unable to get call stack"));
	}

	auto output = Array<hx::ObjectPtr<RawStackFrame>>(0, filled);
	for (auto i = 0; i < filled; i++)
	{
		auto& frame = frames[i];

		auto line         = ULONG{ 0 };
		auto fileBuffer   = std::array<char, 1024>();
		auto fileSize     = ULONG{ 0 };
		auto displacement = ULONG64{ 0 };
		if (!SUCCEEDED(symbols->GetLineByOffset(frame.InstructionOffset, &line, fileBuffer.data(), fileBuffer.size(), &fileSize, &displacement)))
		{
			// 
		}

		auto nameBuffer   = std::array<char, 1024>();
		auto nameSize     = ULONG{ 0 };
		if (!SUCCEEDED(symbols->GetNameByOffset(frame.InstructionOffset, nameBuffer.data(), nameBuffer.size(), &nameSize, &displacement)))
		{
			auto str = std::string("unknown frame");

			std::copy(str.begin(), str.end(), nameBuffer.data());

			nameSize = str.length();
		}

		// -1 as the null terminating character is included as part of the size.
		auto file = String::create(fileBuffer.data(), fileSize - 1);
		auto name = String::create(nameBuffer.data(), nameSize - 1);

		output->__SetItem(i, hx::ObjectPtr<RawStackFrame>(new RawStackFrame(file, name, line)));
	}

	return output;
}

hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::getFrame(int _thread, int _index)
{
	auto system = PDEBUG_SYSTEM_OBJECTS4{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(IDebugSystemObjects4), (void**)&system)))
	{
		hx::Throw(HX_CSTRING("Unable to get system object"));
	}

	if (!SUCCEEDED(system->SetCurrentThreadId(_thread)))
	{
		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	auto frame  = DEBUG_STACK_FRAME{ 0 };
	auto filled = ULONG{ 0 };
	if (!SUCCEEDED(control->GetStackTrace(_index, 0, 0, &frame, 1, &filled)))
	{
		hx::Throw(HX_CSTRING("Unable to get call stack"));
	}

	auto line         = ULONG{ 0 };
	auto fileBuffer   = std::array<char, 1024>();
	auto fileSize     = ULONG{ 0 };
	auto displacement = ULONG64{ 0 };
	if (!SUCCEEDED(symbols->GetLineByOffset(frame.InstructionOffset, &line, fileBuffer.data(), fileBuffer.size(), &fileSize, &displacement)))
	{
		// 
	}

	auto nameBuffer   = std::array<char, 1024>();
	auto nameSize     = ULONG{ 0 };
	if (!SUCCEEDED(symbols->GetNameByOffset(frame.InstructionOffset, nameBuffer.data(), nameBuffer.size(), &nameSize, &displacement)))
	{
		auto str = std::string("unknown frame");

		std::copy(str.begin(), str.end(), nameBuffer.data());

		nameSize = str.length();
	}

	// -1 as the null terminating character is included as part of the size.
	auto file = String::create(fileBuffer.data(), fileSize - 1);
	auto name = String::create(nameBuffer.data(), nameSize - 1);

	return hx::ObjectPtr<RawStackFrame>(new RawStackFrame(file, name, line));
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::start(int status)
{
	if (!SUCCEEDED(control->SetExecutionStatus(status)))
	{
		hx::Throw(HX_CSTRING("Unable to change execution state"));
	}

	hx::EnterGCFreeZone();

	if (!SUCCEEDED(control->WaitForEvent(0, INFINITE)))
	{
		hx::ExitGCFreeZone();
		hx::Throw(HX_CSTRING("Unable to wait for event"));
	}

	hx::ExitGCFreeZone();
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::step(int _thread, int _status)
{
	auto system = PDEBUG_SYSTEM_OBJECTS4{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(IDebugSystemObjects4), (void**)&system)))
	{
		hx::Throw(HX_CSTRING("Unable to get system object"));
	}

	if (!SUCCEEDED(system->SetCurrentThreadId(_thread)))
	{
		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	start(_status);
}