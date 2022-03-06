#include <hxcpp.h>

#include "DbgEngObjects.hpp"

IDataModelManager* hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::manager = nullptr;

IDebugHost* hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::host = nullptr;

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

	auto system = PDEBUG_SYSTEM_OBJECTS4{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(PDEBUG_SYSTEM_OBJECTS4), (void**)&system)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugSystemObjects object from client"));
	}

	auto hostDataModelAccess = (IHostDataModelAccess*) nullptr;
	if (!SUCCEEDED(client->QueryInterface(__uuidof(IHostDataModelAccess), (void**)&hostDataModelAccess)))
	{
		hx::Throw(HX_CSTRING("Unable to get data model access"));
	}

	if (!SUCCEEDED(hostDataModelAccess->GetDataModel(&manager, &host)))
	{
		hx::Throw(HX_CSTRING("Unable to get data model manager and debug host"));
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

	return hx::ObjectPtr<DbgEngObjects>(new DbgEngObjects(client, control, symbols, system, std::move(events), _onBreakpointCb));
}

hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::DbgEngObjects(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, PDEBUG_SYSTEM_OBJECTS4 _system, std::unique_ptr<DebugEventCallbacks> _events, Dynamic _onBreakpointCb)
	: client(_client), control(_control), symbols(_symbols), system(_system), events(std::move(_events)), onBreakpointCb(_onBreakpointCb)
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

		output->__SetItem(i, hx::ObjectPtr<RawStackFrame>(new RawStackFrame(file, name, line, frame.FrameOffset)));
	}

	return output;
}

hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::getFrame(int _thread, int _index)
{
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

	return hx::ObjectPtr<RawStackFrame>(new RawStackFrame(file, name, line, frame.FrameOffset));
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::getVariables(int thread, int frame)
{
	if (!SUCCEEDED(system->SetCurrentThreadId(thread)))
	{
		hx::Throw(HX_CSTRING("Failed to set current thread"));
	}
	if (!SUCCEEDED(symbols->SetScopeFrameByIndex(frame)))
	{
		hx::Throw(HX_CSTRING("Failed to set scope frame"));
	}

	auto group = PDEBUG_SYMBOL_GROUP2{ nullptr };
	if (!SUCCEEDED(symbols->GetScopeSymbolGroup2(DEBUG_SCOPE_GROUP_LOCALS, nullptr, &group)))
	{
		hx::Throw(HX_CSTRING("Failed to set symbol group"));
	}

	auto count = ULONG{ 0 };
	if (!SUCCEEDED(group->GetNumberSymbols(&count)))
	{
		hx::Throw(HX_CSTRING("Failed to set symbol group count"));
	}

	auto hostSymbols = (IDebugHostSymbols*)nullptr;
	if (host->QueryInterface(__uuidof(IDebugHostSymbols), (void**)&hostSymbols))
	{
		hx::Throw(HX_CSTRING("Failed to get debug host symbols"));
	}

	auto ctx = (IDebugHostContext*)nullptr;
	if (!SUCCEEDED(host->GetCurrentContext(&ctx)))
	{
		hx::Throw(HX_CSTRING("Failed to get debug host symbols"));
	}

	auto output = Array<hx::ObjectPtr<RawFrameLocal>>(0, count);
	for (auto i = 0; i < count; i++)
	{
		auto offset = ULONG64{ 0 };
		if (!SUCCEEDED(group->GetSymbolOffset(i, &offset)))
		{
			hx::Throw(HX_CSTRING("Failed to get symbol offset"));
		}

		auto nameBuffer   = std::array<WCHAR, 1024>();
		auto nameSize     = ULONG{ 0 };
		auto displacement = ULONG64{ 0 };
		if (!SUCCEEDED(group->GetSymbolNameWide(i, nameBuffer.data(), nameBuffer.size(), &nameSize)))
		{
			hx::Throw(HX_CSTRING("Failed to get symbol name"));
		}

		auto module = ULONG64{ 0 };
		auto type   = ULONG{ 0 };
		if (!SUCCEEDED(symbols->GetSymbolTypeIdWide(nameBuffer.data(), &type, &module)))
		{
			continue;
		}

		auto hostModule = (IDebugHostModule*)nullptr;
		if (!SUCCEEDED(hostSymbols->FindModuleByLocation(ctx, module, &hostModule)))
		{
			hx::Throw(HX_CSTRING("Failed to find module"));
		}

		auto typeBuffer   = std::array<WCHAR, 1024>();
		auto typeSize     = ULONG{ 0 };
		if(!SUCCEEDED(symbols->GetTypeNameWide(module, type, typeBuffer.data(), typeBuffer.size(), &typeSize)))
		{
			hx::Throw(HX_CSTRING("Failed to find module"));
		}

		auto hostType = (IDebugHostType*)nullptr;
		if(!SUCCEEDED(hostModule->FindTypeByName(typeBuffer.data(), &hostType)))
		{
			hx::Throw(HX_CSTRING("Failed to find module"));
		}

		auto d =
			Debugger::DataModel::ClientEx::Object::CreateTyped(
				Debugger::DataModel::ClientEx::HostContext(ctx),
				Debugger::DataModel::ClientEx::Type(hostType),
				offset);

		std::wstring display;
		try
		{
			display = d.ToDisplayString();
		}
		catch (const std::exception& e)
		{
			auto buffer = std::array<WCHAR, 1024>();
			auto size   = ULONG{ 0 };
			group->GetSymbolValueTextWide(i, buffer.data(), buffer.size(), &size);

			display = std::wstring(buffer.data(), size - 1);
		}

		output->__SetItem(i,
			new RawFrameLocal(
				String::create(nameBuffer.data(), nameSize - 1),
				String::create(typeBuffer.data(), typeSize - 1),
				String::create(display.c_str(), display.length())));
	}

	return output;
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::getArguments(int thread, int frame)
{
	return null();
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
	if (!SUCCEEDED(system->SetCurrentThreadId(_thread)))
	{
		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	start(_status);
}