package hxcppdbg.core.stack;

import hxcppdbg.core.drivers.IStack;

class Stack {
    final driver : IStack;

    public function new(_driver : IStack) {
        driver = _driver;
    }
}