package hxcppdbg.dap.protocol.responses;

import hxcppdbg.dap.protocol.data.Scope;

typedef ScopesResponse = {
    final scopes : Array<Scope>;
}