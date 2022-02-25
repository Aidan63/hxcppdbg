#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <Windows.h>
#include <DbgEng.h>

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class DbgEngObjects : public hx::Object
    {
    private:
        PDEBUG_CLIENT client;
        PDEBUG_CONTROL control;

        DbgEngObjects(PDEBUG_CLIENT _client, PDEBUG_CONTROL _control);
    public:
        static hx::ObjectPtr<DbgEngObjects> createFromFile(String file);
    };
}