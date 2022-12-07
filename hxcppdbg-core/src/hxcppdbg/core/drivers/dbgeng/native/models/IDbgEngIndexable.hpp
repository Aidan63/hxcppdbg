#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgEngBaseModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template<class TValue>
    class IDbgEngIndexable : public DbgEngBaseModel
    {
    public:
        IDbgEngIndexable(const Debugger::DataModel::ClientEx::Object& _object)
            : DbgEngBaseModel(_object)
        {
            //
        }

        virtual int count() = 0;
        virtual TValue at(const int) = 0;
    };
}