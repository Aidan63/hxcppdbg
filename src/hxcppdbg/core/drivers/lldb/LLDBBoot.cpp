#include "LLDBBoot.hpp"

void hxcppdbg::core::drivers::lldb::boot()
{
    ::lldb::SBDebugger::Initialize();
}