#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngIndexable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template <class TKey>
    class IDbgEngKeyable : public IDbgEngIndexable 
    {
    public:
        virtual hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const TKey) = 0;
    };
}