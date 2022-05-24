#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(hxcppdbg, dap, native, DapSession)

namespace hxcppdbg::dap::native
{
    class DapSession_obj : public hx::Object
    {
    public:
        static DapSession create();
    };
}