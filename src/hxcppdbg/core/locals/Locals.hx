package hxcppdbg.core.locals;

import hxcppdbg.core.drivers.ILocals;

class Locals {
    final driver : ILocals;

    public function new(_driver) {
        driver = _driver;
    }
}