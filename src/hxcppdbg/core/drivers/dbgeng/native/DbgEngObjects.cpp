#include <hxcpp.h>

#ifndef INCLUDED_haxe_Exception
#include <hxcppdbg/core/drivers/dbgeng/utils/HResultException.h>
#endif

#ifndef INCLUDED_haxe_ds_Option
#include <haxe/ds/Option.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_ds_Result
#include <hxcppdbg/core/ds/Result.h>
#endif

#include "DbgEngObjects.hpp"

IDataModelManager* hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::manager = nullptr;

IDebugHost* hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::host = nullptr;

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::createFromFile(String file, Dynamic _onBreakpointCb)
{
	auto result = HRESULT{ S_OK };

	// Should we request the highest version or not?
	// Don't know what the required windows version is for the different versions.
	auto client = PDEBUG_CLIENT7{ nullptr };
	if (!SUCCEEDED(result = DebugCreate(__uuidof(PDEBUG_CLIENT7), (void**)&client)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to create IDebugClient object"), result));
	}

	auto control = PDEBUG_CONTROL{ nullptr };
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(PDEBUG_CONTROL), (void**)&control)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get IDebugControl object from client"), result));
	}

	auto symbols = PDEBUG_SYMBOLS5{ nullptr };
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(PDEBUG_SYMBOLS5), (void**)&symbols)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get IDebugSymbol object from client"), result));
	}

	auto system = PDEBUG_SYSTEM_OBJECTS4{ nullptr };
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(PDEBUG_SYSTEM_OBJECTS4), (void**)&system)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get IDebugSystemObjects object from client"), result));
	}

	auto hostDataModelAccess = (IHostDataModelAccess*) nullptr;
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IHostDataModelAccess), (void**)&hostDataModelAccess)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get data model access"), result));
	}

	if (!SUCCEEDED(result = hostDataModelAccess->GetDataModel(&manager, &host)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get data model manager and debug host"), result));
	}

	auto events = std::make_unique<DebugEventCallbacks>(client, _onBreakpointCb);
	if (!SUCCEEDED(result = client->SetEventCallbacksWide(events.get())))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to set events callback"), result));
	}

	if (!SUCCEEDED(result = client->CreateProcessAndAttach(NULL, PSTR(file.utf8_str()), DEBUG_PROCESS, 0, DEBUG_ATTACH_DEFAULT)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to create and attach to process"), result));
	}

	// Even after the above create and attach call the process will not have been started.
	// Our custom callback class will suspend the process as soon as the process starts so we can do whatever we want.
	// Once the process has been suspended this wait for event function will return.
	hx::EnterGCFreeZone();

	if (!SUCCEEDED(result = control->WaitForEvent(0, INFINITE)))
	{
		hx::ExitGCFreeZone();

		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to wait for event"), result));
	}

	hx::ExitGCFreeZone();

	auto status = ULONG{ 0 };
	if (!SUCCEEDED(result = control->GetExecutionStatus(&status)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get execution status"), result));
	}

	if (status != DEBUG_STATUS_BREAK)
	{
		hx::Throw(HX_CSTRING("Process is not suspended"));

		return hxcppdbg::core::ds::Result_obj::Error(haxe::Exception_obj::__new(HX_CSTRING(""), nullptr, nullptr));
	}

	return hxcppdbg::core::ds::Result_obj::Success(new DbgEngObjects_obj(client, control, symbols, system, std::move(events), _onBreakpointCb));
}

hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::DbgEngObjects_obj(PDEBUG_CLIENT7 _client, PDEBUG_CONTROL _control, PDEBUG_SYMBOLS5 _symbols, PDEBUG_SYSTEM_OBJECTS4 _system, std::unique_ptr<DebugEventCallbacks> _events, Dynamic _onBreakpointCb)
	: client(_client), control(_control), symbols(_symbols), system(_system), events(std::move(_events)), onBreakpointCb(_onBreakpointCb)
{
	//
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(DbgEngObjects);
	HX_MARK_MEMBER_NAME(onBreakpointCb, "onBreakpointCb");
	HX_MARK_END_CLASS();
}

#ifdef HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::__Visit(HX_VISIT_PARAMS)
{
	HX_VISIT_MEMBER_NAME(onBreakpointCb, "onBreakpointCb");
}

#endif

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::createBreakpoint(String _file, int _line)
{
	auto result = HRESULT{ S_OK };

	auto entry = DEBUG_SYMBOL_SOURCE_ENTRY();
    auto count = ULONG{ 0 };
	if (!SUCCEEDED(result = symbols->GetSourceEntriesByLine(_line, _file.utf8_str(), DEBUG_GSEL_NEAREST_ONLY, &entry, 1, &count)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get source entries by line"), result));
	}

	auto breakpoint = PDEBUG_BREAKPOINT{ nullptr };
	if (!SUCCEEDED(result = control->AddBreakpoint(DEBUG_BREAKPOINT_CODE, DEBUG_ANY_ID, &breakpoint)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to add breakpoint"), result));
	}

	if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ENABLED)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to enable breakpoint"), result));
	}

	if (!SUCCEEDED(result = breakpoint->SetOffset(entry.Offset)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to set breakpoint offset"), result));
	}

	auto id = ULONG{ 0 };
	if (!SUCCEEDED(breakpoint->GetId(&id)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get breakpoint ID"), result));
	}

	return hxcppdbg::core::ds::Result_obj::Success(id);
}

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::removeBreakpoint(int id)
{
	auto result = HRESULT{ S_OK };

	auto breakpoint = PDEBUG_BREAKPOINT{ nullptr };
	if (!SUCCEEDED(result = control->GetBreakpointById(id, &breakpoint)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get breakpoint by id"), result));
	}

	if (!SUCCEEDED(result = control->RemoveBreakpoint(breakpoint)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to remove breakpoint"), result));
	}

	return haxe::ds::Option_obj::None;
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame>> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getCallStack(int _threadID)
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

hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getFrame(int _thread, int _index)
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

Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getVariables(int thread, int frame)
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

	auto output = Array<hx::ObjectPtr<RawFrameLocal>>(0, 0);
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

		output->Add(
			new RawFrameLocal(
				String::create(nameBuffer.data(), nameSize - 1),
				String::create(typeBuffer.data(), typeSize - 1),
				String::create(display.c_str(), display.length())));
	}

	return output;
}

Array<hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getArguments(int thread, int frame)
{
	return null();
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::start(int status)
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

void hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::step(int _thread, int _status)
{
	if (!SUCCEEDED(system->SetCurrentThreadId(_thread)))
	{
		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	start(_status);
}