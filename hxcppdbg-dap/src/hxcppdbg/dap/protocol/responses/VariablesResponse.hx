package hxcppdbg.dap.protocol.responses;

import hxcppdbg.dap.protocol.data.Variable;

typedef VariablesResponse = {
    final variables : Array<Variable>;
}