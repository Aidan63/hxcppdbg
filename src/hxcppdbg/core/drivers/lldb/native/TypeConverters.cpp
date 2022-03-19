#include <hxcpp.h>

#include "TypeConverters.hpp"

bool hxcppdbg::core::drivers::lldb::native::TypeConverters::extractString(::lldb::SBValue value, ::lldb::SBTypeSummaryOptions options, ::lldb::SBStream& stream)
{
    auto lengthValue = value.GetChildMemberWithName("length");
    if (!lengthValue.IsValid())
    {
        return false;
    }

    auto length = lengthValue.GetValueAsSigned();
    if (length == 0L)
    {
        return false;
    }

    // utf8_str() is an inline function so can't be called by lldb.
    // __CStr() is not inlined and simply calls that utf8 function.
    auto cStringExpr = value.EvaluateExpression("__CStr()");
    if (!cStringExpr.IsValid())
    {
        return false;
    }

    auto cString = cStringExpr.GetPointeeData(0, length);
    if (!cString.IsValid())
    {
        return false;
    }

    ::lldb::SBError error;
    char strBuf[length];

    auto read = cString.ReadRawData(error, 0, strBuf, length);

    stream.Printf("%s", strBuf);

    return true;
}