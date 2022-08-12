package hxcppdbg.dap.protocol;

import hxcppdbg.dap.protocol.ProtocolMessage;

typedef Event = {
    > ProtocolMessage,
    final event : String;
    final ?body : Any;
}