package hxcppdbg.dap.protocol.responses;

import hxcppdbg.dap.protocol.Response;
import hxcppdbg.dap.protocol.data.Thread;

typedef ThreadsResponse = {
    final threads : Array<Thread>;
}