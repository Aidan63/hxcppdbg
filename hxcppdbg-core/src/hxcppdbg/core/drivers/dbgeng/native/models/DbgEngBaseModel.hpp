#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class DbgEngBaseModel
    {
    public:
        const Debugger::DataModel::ClientEx::Object object;

        DbgEngBaseModel(const Debugger::DataModel::ClientEx::Object&);
    };
}