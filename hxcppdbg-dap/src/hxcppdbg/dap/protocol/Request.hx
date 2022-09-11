package hxcppdbg.dap.protocol;

typedef Request = {
    > ProtocolMessage,
    final command : String;
}