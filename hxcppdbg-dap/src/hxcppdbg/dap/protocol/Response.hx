package hxcppdbg.dap.protocol;

import hxcppdbg.dap.protocol.ProtocolMessage;

typedef Response<T> = {
    > ProtocolMessage,
    final request_seq : Int;
    final success : Bool;
    final command : String;
    final ?message : String;
    final ?body : T;
}