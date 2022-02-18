#include "TypeConverters.hpp"

String hxcppdbg::core::drivers::lldb::extractString(::lldb::SBValue value)
{
    auto lengthValue = value.GetChildMemberWithName("length");
    if (!lengthValue.IsValid())
    {
        return HX_CSTRING("Invalid String (failed to read length)");
    }

    auto length = lengthValue.GetValueAsSigned(-1L);
    if (length == 0L)
    {
        return HX_CSTRING("Invalid String (invalid length)");
    }

    // utf8_str() is an inline function so can't be called by lldb.
    // __CStr() is not inlined and simply calls that utf8 function.
    auto cStringExpr = value.EvaluateExpression("__CStr()");
    if (!cStringExpr.IsValid())
    {
        return HX_CSTRING("Failed to call __CStr() to get a utf8 c-string");
    }

    auto cString = cStringExpr.GetPointeeData(0, length);
    if (!cString.IsValid())
    {
        return HX_CSTRING("Failed to get data pointed to by the c-string");
    }

    ::lldb::SBError error;
    char strBuf[length];

    auto read = cString.ReadRawData(error, 0, strBuf, length);

    return String::create(strBuf, read);
}