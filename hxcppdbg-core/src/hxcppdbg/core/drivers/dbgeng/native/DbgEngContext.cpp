#include <hxcpp.h>
#include <filesystem>

#include <comdef.h>
#include "DbgEngContext.hpp"
#include "models/extensions/Utils.hpp"
#include "models/ModelObjectPtr.hpp"
#include "models/basic/ModelString.hpp"
#include "models/basic/ModelStringData.hpp"
#include "models/dynamic/ModelDynamic.hpp"
#include "models/dynamic/ModelReferenceDynamic.hpp"
#include "models/array/ModelArrayObj.hpp"
#include "models/array/ModelVirtualArrayObj.hpp"
#include "models/map/ModelIntHash.hpp"
#include "models/map/ModelStringHash.hpp"
#include "models/map/ModelMapObj.hpp"
#include "models/enums/ModelEnumObj.hpp"
#include "models/enums/ModelVariant.hpp"
#include "models/anon/ModelAnonObj.hpp"
#include "models/anon/ModelVariantKey.hpp"
#include "models/classes/ModelClassObj.hpp"
#include "fmt/xchar.h"

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

#ifndef INCLUDED_hxcppdbg_core_drivers_dbgeng_NativeThreadReturn
#include <hxcppdbg/core/drivers/dbgeng/NativeThreadReturn.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_locals_NativeVariable
#include <hxcppdbg/core/locals/NativeLocal.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_sourcemap_GeneratedType
#include <hxcppdbg/core/sourcemap/GeneratedType.h>
#endif

#ifndef INCLUDED_haxe_io_Path
#include <haxe/io/Path.h>
#endif

IDataModelManager* hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::manager = nullptr;

IDebugHost* hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::host = nullptr;

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::createFromFile(String file, Array<hxcppdbg::core::sourcemap::GeneratedType> enums, Array<hxcppdbg::core::sourcemap::GeneratedType> classes)
{
	auto result = HRESULT{ S_OK };

	// Should we request the highest version or not?
	// Don't know what the required windows version is for the different versions.
	if (!SUCCEEDED(result = DebugCreate(__uuidof(IDebugClient7), &client)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to create IDebugClient object"), result));
	}

	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IDebugControl7), &control)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get IDebugControl object from client"), result));
	}

	if (!SUCCEEDED(result = control->AddEngineOptions(DEBUG_ENGOPT_INITIAL_BREAK)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to set IDebugControl options"), result));
	}

	if (!SUCCEEDED(result = control->AddEngineOptions(DEBUG_ENGOPT_FINAL_BREAK)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to set IDebugControl options"), result));
	}

	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IDebugSymbols5), &symbols)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get IDebugSymbol object from client"), result));
	}

	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IDebugSystemObjects4), &system)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get IDebugSystemObjects object from client"), result));
	}

	auto hostDataModelAccess = ComPtr<IHostDataModelAccess>();
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IHostDataModelAccess), &hostDataModelAccess)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get data model access"), result));
	}

	if (!SUCCEEDED(result = hostDataModelAccess->GetDataModel(&manager, &host)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get data model manager and debug host"), result));
	}

	events = std::make_unique<DebugEventCallbacks>();
	if (!SUCCEEDED(result = client->SetEventCallbacksWide(events.get())))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to set events callback"), result));
	}

	if (!SUCCEEDED(result = client->CreateProcessAndAttach(NULL, PSTR(file.utf8_str()), DEBUG_PROCESS, 0, DEBUG_ATTACH_DEFAULT)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to create and attach to process"), result));
	}

	// Even after the above create and attach call the process will not have been started.
	// Our custom callback class will suspend the process as soon as the process starts so we can do whatever we want.
	// Once the process has been suspended this wait for event function will return.
	hx::EnterGCFreeZone();

	if (!SUCCEEDED(result = control->WaitForEvent(DEBUG_WAIT_DEFAULT, INFINITE)))
	{
		auto err = _com_error(result);
		auto msg = err.ErrorMessage();

		hx::ExitGCFreeZone();

		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(msg), result));
	}

	hx::ExitGCFreeZone();

	auto status = ULONG{ 0 };
	if (!SUCCEEDED(result = control->GetExecutionStatus(&status)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get execution status"), result));
	}

	if (status != DEBUG_STATUS_BREAK)
	{
		hx::Throw(HX_CSTRING("Process is not suspended"));

		return haxe::ds::Option_obj::Some(haxe::Exception_obj::__new(HX_CSTRING(""), nullptr, nullptr));
	}

	models = std::make_unique<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>>();

	// enums
	models->push_back(std::make_unique<models::enums::ModelVariant>());

	for (auto i = 0; i < enums->length; i++)
	{
		models->push_back(std::make_unique<models::enums::ModelEnumObj>(enums[i]));
	}

	// classes
	for (auto i = 0; i < classes->length; i++)
	{
		models->push_back(std::make_unique<models::classes::ModelClassObj>(classes[i]));
	}

	// Core hxcpp type models
	models->push_back(std::make_unique<models::ModelObjectPtr>(std::wstring(L"hx::ObjectPtr<*>")));
	models->push_back(std::make_unique<models::basic::ModelString>());
	models->push_back(std::make_unique<models::basic::ModelStringData>());
	models->push_back(std::make_unique<models::dynamic::ModelDynamic>());

	// Visualisers for "primitive" data types boxed in a hx::Object
	models->push_back(std::make_unique<models::dynamic::ModelReferenceDynamic>(std::wstring(L"hx::IntData")));
	models->push_back(std::make_unique<models::dynamic::ModelReferenceDynamic>(std::wstring(L"hx::BoolData")));
	models->push_back(std::make_unique<models::dynamic::ModelReferenceDynamic>(std::wstring(L"hx::DoubleData")));
	models->push_back(std::make_unique<models::dynamic::ModelReferenceDynamic>(std::wstring(L"hx::Int64Data")));
	models->push_back(std::make_unique<models::dynamic::ModelReferenceDynamic>(std::wstring(L"hx::PointerData")));

	// Array visualisers
	models->push_back(std::make_unique<models::ModelObjectPtr>(std::wstring(L"Array<*>")));
	models->push_back(std::make_unique<models::array::ModelArrayObj>());

	models->push_back(std::make_unique<models::ModelObjectPtr>(std::wstring(L"cpp::VirtualArray")));
	models->push_back(std::make_unique<models::array::ModelVirtualArrayObj>());

	// map visualisers
	models->push_back(std::make_unique<models::map::ModelIntHash>());
	models->push_back(std::make_unique<models::map::ModelStringHash>());
	models->push_back(std::make_unique<models::map::ModelMapObj>(std::wstring(L"Int")));
	models->push_back(std::make_unique<models::map::ModelMapObj>(std::wstring(L"String")));
	models->push_back(std::make_unique<models::map::ModelMapObj>(std::wstring(L"Object")));

	// anon
	models->push_back(std::make_unique<models::anon::ModelAnonObj>());
	models->push_back(std::make_unique<models::anon::ModelVariantKey>());

	return haxe::ds::Option_obj::None;
}

hxcppdbg::core::drivers::dbgeng::NativeFrameReturn hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::nativeFrameFromDebugFrame(const Debugger::DataModel::ClientEx::Object& _frame)
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
	auto file = String::create(fileBuffer.data(), fileLength - 1);
	auto name = cleanSymbolName(std::wstring(nameBuffer.data(), nameLength - 1));

	return hxcppdbg::core::drivers::dbgeng::NativeFrameReturn_obj::__new(hxcppdbg::core::stack::NativeFrame_obj::__new(haxe::io::Path_obj::__new(haxe::io::Path_obj::normalize(file)), name, line), address);
}

String hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::cleanSymbolName(std::wstring _input)
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

int hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::backtickCount(std::wstring _input)
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

bool hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::endsWith(std::wstring const &_input, std::wstring const &_ending)
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

int64_t hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::createBreakpoint(String _file, int _line)
{
	auto result = S_OK;

	auto entry = DEBUG_SYMBOL_SOURCE_ENTRY();
    auto count = ULONG{ 0 };
	if (!SUCCEEDED(result = symbols->GetSourceEntriesByLine(_line, _file.utf8_str(), DEBUG_GSEL_NEAREST_ONLY, &entry, 1, &count)))
	{
		hx::Throw(HX_CSTRING("Failed to get source entries by line"));
	}

	auto breakpoint = PDEBUG_BREAKPOINT{ nullptr };
	if (!SUCCEEDED(result = control->AddBreakpoint(DEBUG_BREAKPOINT_CODE, DEBUG_ANY_ID, &breakpoint)))
	{
		hx::Throw(HX_CSTRING("Failed to add breakpoint"));
	}

	if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ENABLED)))
	{
		hx::Throw(HX_CSTRING("Failed to enable breakpoint"));
	}

	if (!SUCCEEDED(result = breakpoint->SetOffset(entry.Offset)))
	{
		hx::Throw(HX_CSTRING("Failed to set breakpoint offset"));
	}

	auto id = 0UL;
	if (!SUCCEEDED(result = breakpoint->GetId(&id)))
	{
		hx::Throw(HX_CSTRING("Failed to get breakpoint ID"));
	}

	return id;
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::removeBreakpoint(int64_t id)
{
	auto result = S_OK;

	auto breakpoint = PDEBUG_BREAKPOINT();
	if (!SUCCEEDED(result = control->GetBreakpointById(id, &breakpoint)))
	{
		hx::Throw(HX_CSTRING("Failed to get breakpoint by id"));
	}

	if (!SUCCEEDED(result = control->RemoveBreakpoint(breakpoint)))
	{
		hx::Throw(HX_CSTRING("Failed to remove breakpoint"));
	}
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::getThreads()
{
	auto result = S_OK;

	try
	{
		auto threads = Debugger::DataModel::ClientEx::Object::CurrentProcess().KeyValue(L"Threads");
		auto count   = int { threads.CallMethod(L"Count") };
		auto output  = Array<hxcppdbg::core::drivers::dbgeng::NativeThreadReturn>(0, count);

		for (auto&& thread : threads)
		{
			auto id = thread.KeyValue(L"Id").As<int>();

			output->Add(hxcppdbg::core::drivers::dbgeng::NativeThreadReturn_obj::__new(id, HX_CSTRING("")));
		}

		return hxcppdbg::core::ds::Result_obj::Success(output);
	}
	catch (const std::exception& exn)
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(exn.what()), 0));
	}
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::getCallStack(int _threadIndex)
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

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::getFrame(int _threadIndex, int _frameIndex)
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

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::getVariables(int _threadIndex, int _frameIndex)
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

		try
		{
			auto locals = frame.KeyValue(L"LocalVariables");
			auto output = Array<hx::Anon>(0, 0);

			for (auto&& local : locals.Keys())
			{
				auto object = std::get<1>(local).GetValue();
				auto anon = hx::Anon_obj::Create(2);
				auto type   = object.Type();

				anon->setFixed(0, HX_CSTRING("name"), String::create(std::get<0>(local).c_str()));

				try
				{
					// We can't seem to create custom model extensions for these intrinsic types, so we just have to check them manually.
					if (type.IsIntrinsic())
					{
						anon->setFixed(1, HX_CSTRING("data"), hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(object));
					}
					else
					{
						anon->setFixed(1, HX_CSTRING("data"), object.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>());
					}
				}
				catch (const std::exception& exn)
				{
					// If its not a supported intrinsic and it doesn't have the HxcppdbgModelData property then its not something we really know about, so report it as unknown.

					anon->setFixed(1, HX_CSTRING("data"), hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull());
				}

				output->Add(anon);
			}

			return hxcppdbg::core::ds::Result_obj::Success(output);
		}
		catch (const std::exception& exn)
		{
			// If getting the local variables throws then there are no locals in this frame.

			return hxcppdbg::core::ds::Result_obj::Success(Array<hx::Anon>(0, 0));
		}
	}
	catch (const std::exception& exn)
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(exn.what()), 0));
	}
}

hxcppdbg::core::ds::Result hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::getArguments(int thread, int frame)
{
	return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Not Implemented"), S_FALSE));
}

bool hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::interrupt()
{
	// It seems like we can use GetExecutionStatus from other threads, but I'm not entirely sure...

	auto status = 0UL;
	if (!SUCCEEDED(control->GetExecutionStatus(&status)))
	{
		hx::Throw(HX_CSTRING("Unable to get execution status"));
	}

	if (status == DEBUG_STATUS_BREAK)
	{
		return false;
	}

	if (!SUCCEEDED(control->SetInterrupt(DEBUG_INTERRUPT_EXIT)))
	{
		hx::Throw(HX_CSTRING("Unable to set interrupt"));
	}

	return true;
}

void hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::wait(
	Dynamic _onBreakpont,
	Dynamic _onException,
	Dynamic _onPaused,
	Dynamic _onExited
)
{
	hx::EnterGCFreeZone();

	auto result = S_OK;

	switch (result = control->WaitForEvent(DEBUG_WAIT_DEFAULT, INFINITE))
	{
		case S_OK:
			{
				hx::ExitGCFreeZone();

				auto type       = 0UL;
				auto processIdx = 0UL;
				auto threadIdx  = 0UL;

				if (!SUCCEEDED(control->GetLastEventInformation(&type, &processIdx, &threadIdx, nullptr, 0, nullptr, nullptr, 0, nullptr)))
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

						case DEBUG_EVENT_BREAKPOINT:
							{
								auto event = DEBUG_LAST_EVENT_INFO_BREAKPOINT();
								if (!SUCCEEDED(control->GetLastEventInformation(&type, &processIdx, &threadIdx, &event, sizeof(DEBUG_LAST_EVENT_INFO_BREAKPOINT), nullptr, nullptr, 0, nullptr)))
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
										_onBreakpont(threadIdx, event.Id);
									}
								}
							}
							break;

						case DEBUG_EVENT_EXCEPTION:
							{
								auto event = DEBUG_LAST_EVENT_INFO_EXCEPTION();
								if (!SUCCEEDED(control->GetLastEventInformation(&type, &processIdx, &threadIdx, &event, sizeof(DEBUG_LAST_EVENT_INFO_EXCEPTION), nullptr, nullptr, 0, nullptr)))
								{
									hx::Throw(HX_CSTRING("Unable to get last event exception information"));
								}
								else
								{
									_onException(threadIdx, event.ExceptionRecord.ExceptionCode);
								}

							}
							break;

						case DEBUG_EVENT_EXIT_PROCESS:
							{
								auto code = 0UL;
								if (S_OK == client->GetExitCode(&code))
								{
									_onExited(code);
								}
								else
								{
									hx::Throw(HX_CSTRING("Process exited but unable to get exit code"));
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

				if (!SUCCEEDED(control->SetExecutionStatus(DEBUG_STATUS_GO)))
				{
					hx::Throw(HX_CSTRING("Unable to set execution status"));
				}

				if (!SUCCEEDED(control->SetInterrupt(DEBUG_INTERRUPT_ACTIVE)))
				{
					hx::Throw(HX_CSTRING("Unable to set active interrupt"));
				}

				hx::EnterGCFreeZone();

				if (!SUCCEEDED(control->WaitForEvent(DEBUG_WAIT_DEFAULT, INFINITE)))
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
				if (S_OK == client->GetExitCode(&exitCode))
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

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::step(int _threadIndex, int _step)
{
	auto result = S_OK;

	auto status = 0UL;
	if (!SUCCEEDED(result = control->GetExecutionStatus(&status)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get the current execution status"), result));
	}

	if (status != DEBUG_STATUS_BREAK)
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Cannot step unless the target is suspended"), status));
	}

	auto threadID = ULONG{ 0 };
	if (!SUCCEEDED(result = system->GetThreadIdsByIndex(_threadIndex, 1, &threadID, nullptr)))
	{
		return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get thread ID from index"), result));
	}

	if (!SUCCEEDED(result = system->SetCurrentThreadId(threadID)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to set current thread"), result));
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
			auto offset = ULONG64{ 0 };
			if (!SUCCEEDED(control->GetReturnOffset(&offset)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to add breakpoint"), result));
			}

			auto breakpoint = PDEBUG_BREAKPOINT();
			if (!SUCCEEDED(result = control->AddBreakpoint(DEBUG_BREAKPOINT_CODE, DEBUG_ANY_ID, &breakpoint)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to add breakpoint"), result));
			}

			if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ENABLED)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to enable breakpoint"), result));
			}

			if (!SUCCEEDED(result = breakpoint->AddFlags(DEBUG_BREAKPOINT_ONE_SHOT)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to set the breakpoint to one shot"), result));
			}

			if (!SUCCEEDED(result = breakpoint->SetMatchThreadId(threadID)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to set the breakpoint to one shot"), result));
			}

			if (!SUCCEEDED(result = breakpoint->SetOffset(offset)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to set breakpoint offset"), result));
			}

			if (!SUCCEEDED(result = breakpoint->GetId(&stepOutBreakpointId)))
			{
				return hxcppdbg::core::ds::Result_obj::Error(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Failed to get breakpoint ID"), result));
			}

			mode = DEBUG_STATUS_GO;

			break;
		}
	default:
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unsupported step mode"), _step));
	}

	if (!SUCCEEDED(result = control->SetExecutionStatus(mode)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to change execution state"), result));
	}

	return haxe::ds::Option_obj::None;
}

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::go()
{
	auto result  = S_OK;
	auto current = 0UL;

	if (!SUCCEEDED(result = control->GetExecutionStatus(&current)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to get the target status"), result));
	}

	if (current != DEBUG_STATUS_BREAK)
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Target is not suspended"), result));
	}

	if (!SUCCEEDED(result = control->SetExecutionStatus(DEBUG_STATUS_GO)))
	{
		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(HX_CSTRING("Unable to change execution state"), result));
	}

	return haxe::ds::Option_obj::None;
}

haxe::ds::Option hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::end()
{
	auto result = 0;
	
	if (!SUCCEEDED(result = client->TerminateProcesses()))
	{
		auto err = _com_error(result);
		auto msg = err.ErrorMessage();

		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(msg), result));
	}

	if (!SUCCEEDED(result = client->EndSession(DEBUG_END_ACTIVE_TERMINATE)))
	{
		auto err = _com_error(result);
		auto msg = err.ErrorMessage();

		return haxe::ds::Option_obj::Some(hxcppdbg::core::drivers::dbgeng::utils::HResultException_obj::__new(String::create(msg), result));
	}
	
	return haxe::ds::Option_obj::None;
}