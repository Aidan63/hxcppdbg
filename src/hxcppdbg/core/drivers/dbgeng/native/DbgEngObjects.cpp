#include <hxcpp.h>

#include "DbgEngObjects.hpp"

hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects> hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::createFromFile(String file)
{
	auto client = PDEBUG_CLIENT{ nullptr };
	if (!SUCCEEDED(DebugCreate(__uuidof(PDEBUG_CLIENT), (void**)&client)))
	{
		hx::Throw(HX_CSTRING("Unable to create IDebugClient object"));
	}

	auto control = PDEBUG_CONTROL{ nullptr };
	if (!SUCCEEDED(client->QueryInterface(__uuidof(PDEBUG_CONTROL), (void**)&control)))
	{
		hx::Throw(HX_CSTRING("Unable to get IDebugControl object from client"));
	}

	if (!SUCCEEDED(client->CreateProcessAndAttach(NULL, PSTR(file.utf8_str()), DEBUG_PROCESS, 0, DEBUG_ATTACH_DEFAULT)))
	{
		hx::Throw(HX_CSTRING("Unable to create and attach to process"));
	}

	return hx::ObjectPtr<DbgEngObjects>(new DbgEngObjects(client, control));
}

hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::DbgEngObjects(PDEBUG_CLIENT _client, PDEBUG_CONTROL _control)
	: client(_client), control(_control)
{
	//
}