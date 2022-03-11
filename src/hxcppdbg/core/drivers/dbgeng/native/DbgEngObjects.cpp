#include <hxcpp.h>

#ifndef INCLUDED_hxcppdbg_core_drivers_dbgeng_utils_HResultException
#include <hxcppdbg/core/drivers/dbgeng/utils/HResultException.h>
#endif

#ifndef INCLUDED_haxe_ds_Option
#include <haxe/ds/Option.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_ds_Result
#include <hxcppdbg/core/ds/Result.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_stack_NativeFrame
#include <hxcppdbg/core/stack/NativeFrame.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_drivers_dbgeng_NativeFrameReturn
#include <hxcppdbg/core/drivers/dbgeng/NativeFrameReturn.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_locals_NativeVariable
#include <hxcppdbg/core/locals/NativeLocal.h>
#endif

#ifndef INCLUDED_haxe_io_Path
#include <haxe/io/Path.h>
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
	// hx::EnterGCFreeZone();

	if (!SUCCEEDED(result = control->WaitForEvent(0, INFINITE)))
	{
		// hx::ExitGCFreeZone();

		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to wait for event"), result));
	}

	// hx::ExitGCFreeZone();

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

hxcppdbg::core::drivers::dbgeng::NativeFrameReturn hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::nativeFrameFromDebugFrame(const Debugger::DataModel::ClientEx::Object& _frame)
{
	auto attr    = _frame.KeyValue(L"Attributes");
	auto offset  = ULONG64{ attr.KeyValue(L"InstructionOffset") };
	auto address = ULONG64{ attr.KeyValue(L"FrameOffset") };
	auto line    = ULONG{ 0 };

	auto fileBuffer = std::array<WCHAR, 1024>();
	auto fileLength = ULONG{ 0 };
	if (!SUCCEEDED(symbols->GetLineByOffsetWide(offset, &line, fileBuffer.data(), fileBuffer.size(), &fileLength, nullptr)))
	{
		auto str = std::wstring(L"unknown file");

		std::copy(str.begin(), str.end(), fileBuffer.data());

		fileLength = str.length() + 1;
	}

	auto nameBuffer = std::array<WCHAR, 1024>();
	auto nameLength = ULONG{ 0 };
	if (!SUCCEEDED(symbols->GetNameByOffsetWide(offset, nameBuffer.data(), nameBuffer.size(), &nameLength, nullptr)))
	{
		auto str = std::wstring(L"unknown function");

		std::copy(str.begin(), str.end(), fileBuffer.data());

		nameLength = str.length() + 1;
	}

	// -1 as the null terminating character is included as part of the size.
	auto file = haxe::io::Path_obj::normalize(String::create(fileBuffer.data(), fileLength - 1));
	auto name = cleanSymbolName(std::wstring(nameBuffer.data(), nameLength - 1));

	return hxcppdbg::core::drivers::dbgeng::NativeFrameReturn_obj::__new(hxcppdbg::core::stack::NativeFrame_obj::__new(file, name, line), address);
}

String hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::cleanSymbolName(std::wstring _input)
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

int hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::backtickCount(std::wstring _input)
{
	auto count = int{ 0 };
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

bool hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::endsWith(std::wstring const &_input, std::wstring const &_ending)
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

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getCallStack(int _threadIndex)
{
	auto result = HRESULT{ S_OK };
	auto sysID  = ULONG{ 0 };
	if (!SUCCEEDED(result = system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &sysID)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get thread ID from index"), result));
	}

	try
	{
		auto predicate = [sysID](const Debugger::DataModel::ClientEx::Object&, Debugger::DataModel::ClientEx::Object thread) { return int{ thread.KeyValue(L"Id") } == sysID; };
		auto thread    = Debugger::DataModel::ClientEx::Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", predicate);
		auto frames    = thread.KeyValue(L"Stack").KeyValue(L"Frames");
		auto count     = int { frames.CallMethod(L"Count") };
		auto output    = Array<hxcppdbg::core::drivers::dbgeng::NativeFrameReturn>(0, count);

		for (auto&& frame : frames)
		{
			output->Add(nativeFrameFromDebugFrame(frame));
		}

		return hxcppdbg::core::ds::Result_obj::Success(output);
	}
	catch (const std::exception& exn)
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(exn.what()), 0));
	}
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getFrame(int _threadIndex, int _frameIndex)
{
	auto result = HRESULT{ S_OK };
	auto sysID  = ULONG{ 0 };
	if (!SUCCEEDED(result = system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &sysID)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get thread ID from index"), result));
	}

	try
	{
		auto findThread = [sysID](const Debugger::DataModel::ClientEx::Object&, Debugger::DataModel::ClientEx::Object thread) { return int{ thread.KeyValue(L"Id") } == sysID; };
		auto thread     = Debugger::DataModel::ClientEx::Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", findThread);
		auto findFrame  = [_frameIndex](const Debugger::DataModel::ClientEx::Object&, Debugger::DataModel::ClientEx::Object frame) { return ULONG{ frame.KeyValue(L"Attributes").KeyValue(L"FrameNumber") } == _frameIndex; };
		auto frame      = thread.KeyValue(L"Stack").KeyValue(L"Frames").CallMethod(L"First", findFrame);

		return hxcppdbg::core::ds::Result_obj::Success(nativeFrameFromDebugFrame(frame));
	}
	catch (const std::exception& exn)
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(exn.what()), 0));
	}
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getVariables(int _threadIndex, int _frameIndex)
{
	auto result = HRESULT{ S_OK };
	auto sysID  = ULONG{ 0 };
	if (!SUCCEEDED(result = system->GetThreadIdsByIndex(_threadIndex, 1, nullptr, &sysID)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get thread ID from index"), result));
	}

	try
	{
		auto findThread = [sysID](const Debugger::DataModel::ClientEx::Object&, Debugger::DataModel::ClientEx::Object thread) { return int{ thread.KeyValue(L"Id") } == sysID; };
		auto thread     = Debugger::DataModel::ClientEx::Object::CurrentProcess().KeyValue(L"Threads").CallMethod(L"First", findThread);
		auto findFrame  = [_frameIndex](const Debugger::DataModel::ClientEx::Object&, Debugger::DataModel::ClientEx::Object frame) { return ULONG{ frame.KeyValue(L"Attributes").KeyValue(L"FrameNumber") } == _frameIndex; };
		auto locals     = thread.KeyValue(L"Stack").KeyValue(L"Frames").CallMethod(L"First", findFrame).KeyValue(L"LocalVariables");

		auto output = Array<hxcppdbg::core::locals::NativeLocal>(0, 0);
		for (auto&& local : locals.Keys())
		{
			auto name  = std::get<0>(local);
			auto obj   = std::get<1>(local).GetValue();
			auto type  = obj.Type().Name();
			auto value = obj.TryToDisplayString().value_or(L"unknown");

			output->Add(hxcppdbg::core::locals::NativeLocal_obj::__new(String::create(name.c_str()), String::create(type.c_str()), String::create(value.c_str())));
		}

		return hxcppdbg::core::ds::Result_obj::Success(output);
	}
	catch (const std::exception& exn)
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(exn.what()), 0));
	}
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::getArguments(int thread, int frame)
{
	return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Not Implemented"), S_FALSE));
}

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::start(int status)
{
	auto result = HRESULT{ S_OK };

	if (!SUCCEEDED(result = control->SetExecutionStatus(status)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to change execution state"), result));
	}

	// hx::EnterGCFreeZone();

	if (!SUCCEEDED(result = control->WaitForEvent(0, INFINITE)))
	{
		// hx::ExitGCFreeZone();

		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to wait for event"), result));
	}

	// hx::ExitGCFreeZone();

	return haxe::ds::Option_obj::None;
}

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::step(int _thread, int _status)
{
	auto result = HRESULT{ S_OK };

	if (!SUCCEEDED(result = system->SetCurrentThreadId(_thread)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to set current thread"), result));

		hx::Throw(HX_CSTRING("Unable to set current thread"));
	}

	return start(_status);
}