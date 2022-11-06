#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngIndexable.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    template <class TKey, class TValue>
    class IDbgEngKeyable : public IDbgEngIndexable<TValue>
    {
    public:
        virtual hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const TKey) = 0;
    };
}