#include "LLDBBoot.hpp"

void hxcppdbg::core::drivers::lldb::native::boot()
{
    ::lldb::SBDebugger::Initialize();
}