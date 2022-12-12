#include <hxcpp.h>
#include <filesystem>

#include <comdef.h>
#include "DbgEngContext.hpp"
#include "DbgEngSession.hpp"
#include "models/extensions/Utils.hpp"
#include "models/ModelObjectPtr.hpp"
#include "models/basic/ModelString.hpp"
#include "models/basic/ModelStringData.hpp"
#include "models/dynamic/ModelDynamic.hpp"
#include "models/dynamic/ModelReferenceDynamic.hpp"
#include "models/array/ModelArrayObj.hpp"
#include "models/array/ModelVirtualArrayObj.hpp"
#include "models/map/ModelMapObj.hpp"
#include "models/map/hashes/ModelIntHash.hpp"
#include "models/map/hashes/ModelStringHash.hpp"
#include "models/map/hashes/ModelDynamicHash.hpp"
#include "models/map/elements/ModelIntElement.hpp"
#include "models/map/elements/ModelStringElement.hpp"
#include "models/map/elements/ModelDynamicElement.hpp"
#include "models/enums/ModelEnumObj.hpp"
#include "models/enums/ModelVariant.hpp"
#include "models/anon/ModelAnonObj.hpp"
#include "models/anon/ModelVariantKey.hpp"
#include "models/classes/ModelClassObj.hpp"
#include "fmt/xchar.h"

IDataModelManager* hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::manager = nullptr;

IDebugHost* hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::host = nullptr;

std::optional<cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::DbgEngContext>> hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::cached = std::nullopt;

cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::DbgEngContext> hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::get()
{
	if (cached.has_value())
	{
		return cached.value();
	}

	auto result = S_OK;

	// Get all the core debugger types.

	auto client = ComPtr<IDebugClient7>();
	if (!SUCCEEDED(result = DebugCreate(__uuidof(IDebugClient7), &client)))
	{
		hx::Throw(HX_CSTRING("Unabled to create debug session"));
	}

	auto control = ComPtr<IDebugControl7>();
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IDebugControl7), &control)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugControl7 interface"));
	}

	auto symbols = ComPtr<IDebugSymbols5>();
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IDebugSymbols5), &symbols)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugSymbols5 interface"));
	}

	auto system = ComPtr<IDebugSystemObjects4>();
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IDebugSystemObjects4), &system)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugSystemObjects4 interface"));
	}

	auto dataModelAccess = ComPtr<IHostDataModelAccess>();
	if (!SUCCEEDED(result = client->QueryInterface(__uuidof(IHostDataModelAccess), &dataModelAccess)))
	{
		hx::Throw(HX_CSTRING("Unable to get IHostDataModelAccess interface"));
	}

	// Get the DbgModel interfaces, these are static and used by DbgEng

	if (!SUCCEEDED(result = dataModelAccess->GetDataModel(&manager, &host)))
	{
		hx::Throw(HX_CSTRING("Unable to get data model"));
	}

	auto events = std::make_unique<DebugEventCallbacks>();
	if (!SUCCEEDED(result = client->SetEventCallbacksWide(events.get())))
	{
		hx::Throw(HX_CSTRING("Unable to set event callback"));
	}

	// Load all of our custom models

	auto models = std::make_unique<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>>();

	// enums
	models->push_back(std::make_unique<models::enums::ModelVariant>());

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
	models->push_back(std::make_unique<models::map::ModelMapObj>(L"Int"));
	models->push_back(std::make_unique<models::map::ModelMapObj>(L"String"));
	models->push_back(std::make_unique<models::map::ModelMapObj>(L"Object"));
	models->push_back(std::make_unique<models::map::hashes::ModelIntHash>());
	models->push_back(std::make_unique<models::map::hashes::ModelStringHash>());
	models->push_back(std::make_unique<models::map::hashes::ModelDynamicHash>());
	models->push_back(std::make_unique<models::map::elements::ModelIntElement>());
	models->push_back(std::make_unique<models::map::elements::ModelStringElement>());
	models->push_back(std::make_unique<models::map::elements::ModelDynamicElement>());

	// anon
	models->push_back(std::make_unique<models::anon::ModelAnonObj>());
	models->push_back(std::make_unique<models::anon::ModelVariantKey>());

	// Create, store, and return the context.

	auto ctx = new DbgEngContext(client, control, symbols, system, dataModelAccess, std::move(models), std::move(events));

	cached.emplace(ctx);

	return ctx;
}

hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::DbgEngContext(
	ComPtr<IDebugClient7> _client,
	ComPtr<IDebugControl7> _control,
	ComPtr<IDebugSymbols5> _symbols,
	ComPtr<IDebugSystemObjects4> _system,
	ComPtr<IHostDataModelAccess> _dataModelAccess,
	std::unique_ptr<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>> _models,
	std::unique_ptr<DebugEventCallbacks> _events)
	: client(_client), control(_control), symbols(_symbols), system(_system), dataModelAccess(_dataModelAccess), models(std::move(_models)), events(std::move(_events))
{
	//
}

hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::~DbgEngContext()
{
	client->EndSession(DEBUG_END_PASSIVE);
}

cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::DbgEngSession> hxcppdbg::core::drivers::dbgeng::native::DbgEngContext::start(
	String _file,
	Array<Dynamic> _enums,
	Array<Dynamic> _classes)
{
	auto sessionModels = std::make_unique<std::vector<std::unique_ptr<Debugger::DataModel::ProviderEx::ExtensionModel>>>();

	for (auto i = 0; i < _enums->length; i++)
	{
		auto typeName = _enums[i]->__Field(HX_CSTRING("name"), hx::PropertyAccess::paccDynamic).asString();
		auto typeData = _enums[i]->__Field(HX_CSTRING("type"), hx::PropertyAccess::paccDynamic).asObject();

		sessionModels->push_back(std::make_unique<models::enums::ModelEnumObj>(typeName, typeData));
	}

	for (auto i = 0; i < _classes->length; i++)
	{
		auto typeName = _classes[i]->__Field(HX_CSTRING("name"), hx::PropertyAccess::paccDynamic).asString();
		auto typeData = _classes[i]->__Field(HX_CSTRING("type"), hx::PropertyAccess::paccDynamic).asObject();

		sessionModels->push_back(std::make_unique<models::classes::ModelClassObj>(typeName, typeData));
	}

	auto result = S_OK;

	if (!SUCCEEDED(result = client->CreateProcessAndAttachWide(0, PWSTR(_file.wchar_str()), DEBUG_ONLY_THIS_PROCESS, 0, DEBUG_ATTACH_DEFAULT)))
	{
		hx::Throw(HX_CSTRING("Unable to start and attach to process"));
	}

	// Even after the above create and attach call the process will not have been started.
	// Our custom callback class will suspend the process as soon as the process starts so we can do whatever we want.
	// Once the process has been suspended this wait for event function will return.
	hx::EnterGCFreeZone();

	if (!SUCCEEDED(result = control->WaitForEvent(DEBUG_WAIT_DEFAULT, INFINITE)))
	{
		hx::ExitGCFreeZone();
		hx::Throw(HX_CSTRING("Unable to wait for process event"));
	}

	hx::ExitGCFreeZone();

	auto status = 0UL;
	if (!SUCCEEDED(result = control->GetExecutionStatus(&status)))
	{
		hx::Throw(HX_CSTRING("Failed to get execution status"));
	}

	if (status != DEBUG_STATUS_BREAK)
	{
		hx::Throw(HX_CSTRING("Process is not suspended"));
	}

	return new DbgEngSession(this, std::move(sessionModels));
}