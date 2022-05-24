#include <hxcpp.h>

#include "DapSession.hpp"
#include "dap/io.h"
#include "dap/protocol.h"
#include "dap/session.h"
#include "dap/network.h"

hxcppdbg::dap::native::DapSession hxcppdbg::dap::native::DapSession_obj::create()
{
    auto session = ::dap::Session::create();

    session->onError([](const char* message) {
        printf("%s", message);
    });

    session->registerHandler([](const ::dap::InitializeRequest&) {
        auto response = ::dap::InitializeResponse();
        response.supportsConfigurationDoneRequest = true;
        response.supportsBreakpointLocationsRequest = true;
        response.supportsEvaluateForHovers = true;
        response.supportsDelayedStackTraceLoading = true;
        response.supportsTerminateRequest = true;

        return response;
    });

    session->registerSentHandler([&](const ::dap::ResponseOrError<::dap::InitializeResponse>&) {
        session->send(::dap::InitializedEvent());
    });

    //

    session->registerHandler([](const ::dap::LaunchRequest& request) {
        return ::dap::LaunchResponse();
    });

    auto in  = ::dap::file(stdin, false);
    auto out = ::dap::file(stdout, false);
    session->bind(in, out);

    return new DapSession_obj();
}