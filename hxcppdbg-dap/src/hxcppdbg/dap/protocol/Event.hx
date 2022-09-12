package hxcppdbg.dap.protocol;

import hxcppdbg.dap.protocol.ProtocolMessage;

typedef Event<T> = {
    > ProtocolMessage,
    final event : String;
    final ?body : T;
}