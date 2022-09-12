package hxcppdbg.dap.protocol;

typedef Request<T> = {
    > ProtocolMessage,
    final command : String;
    final arguments : T;
}