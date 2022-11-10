#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template<class TValue>
    class IDbgEngIndexable
    {
    public:
        const Debugger::DataModel::ClientEx::Object object;

        IDbgEngIndexable(const Debugger::DataModel::ClientEx::Object& _object)
            : object(Debugger::DataModel::ClientEx::Object(_object))
        {
            //
        }

        virtual int count() = 0;
        virtual TValue at(const int) = 0;
    };
}