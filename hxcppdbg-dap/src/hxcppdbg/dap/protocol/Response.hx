package hxcppdbg.dap.protocol;

import hxcppdbg.dap.protocol.ProtocolMessage;

typedef Response = {
    > ProtocolMessage,
    final request_seq : Int;
    final success : Bool;
    final command : String;
    final ?message : String;
    final ?body : Any;
}