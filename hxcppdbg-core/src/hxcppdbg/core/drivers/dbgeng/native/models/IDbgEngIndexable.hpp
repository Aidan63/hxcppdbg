#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template<class TValue>
    class IDbgEngIndexable
    {
    public:
        virtual int count() = 0;
        virtual TValue at(const int) = 0;
    };
}