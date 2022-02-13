#include "LLDBBoot.hpp"

void hxcppdbg::core::drivers::lldb::boot()
{
    ::lldb::SBDebugger::Initialize();
}

// void hxcppdbg::core::drivers::lldb::test() {
//     ::lldb::SBDebugger::Initialize();

//     auto debugger = ::lldb::SBDebugger::Create();
//     debugger.SetAsync(false);

//     if (!debugger.IsValid()) {
//         std::cerr << "Unable to create debugger" << std::endl;

//         return;
//     }

//     auto target = debugger.CreateTarget("/mnt/d/programming/haxe/hxcppdbg/sample/bin/Main-debug");
//     if (!target.IsValid()) {
//         std::cerr << "Unable to create target" << std::endl;

//         return;
//     }

//     auto bp = target.BreakpointCreateByLocation("Resources.cpp", 43);
//     if (!bp.IsValid()) {
//         std::cerr << "Unable to create breakpoint" << std::endl;

//         return;
//     }

//     ::lldb::SBError error;

//     auto info    = target.GetLaunchInfo();
//     auto process = target.Launch(info, error);
//     if (!process.IsValid()) {
//         std::cerr << "Unable to launch target" << std::endl;

//         return;
//     }

//     if (error.Fail()) {
//         std::cerr << error.GetCString() << std::endl;

//         return;
//     }

//     auto state = process.GetState();

//     if (state == ::lldb::StateType::eStateStopped) {
//         std::cout << "stopped" << std::endl;

//         auto thread = process.GetSelectedThread();
//         auto frames = std::vector<::lldb::SBFrame>(thread.GetNumFrames());

//         for (int i = 0; i < frames.size(); i++) {
//             auto f = (frames[i] = thread.GetFrameAtIndex(i));

//             // file and line
//             auto lineEntry = f.GetLineEntry();
//             auto fileName  = lineEntry.GetFileSpec().GetFilename();
//             auto lineNum   = lineEntry.GetLine();

//             // symbol
//             auto symbol  = f.GetSymbol();
//             auto symName = symbol.GetName();

//             // func
//             auto func     = f.GetFunction();
//             auto funcName = f.GetFunctionName();
//             // auto funcType = func.GetType();
//             // auto typeName = funcType.GetDisplayTypeName();

//             // auto func = f.GetFunction();
//             // auto type = func.GetType();
//             // auto tName = type.GetName();
//             // auto funcN = f.GetFunctionName();
//             // auto funcDisp = f.GetDisplayFunctionName();
//             // auto linee = f.GetLineEntry();
//             // auto line = linee.GetLine();

//             std::cout << fileName << std::endl;
//         }
//     }

//     std::cout << "done" << std::endl;
// }