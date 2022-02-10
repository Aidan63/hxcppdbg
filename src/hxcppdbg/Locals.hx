package hxcppdbg;

import hxcppdbg.gdb.Gdb;

class Locals {
    final gdb : Gdb;

    public function new(_gdb) {
        gdb = _gdb;
    }

    @:command public function list() {
        final r = gdb.command('-stack-list-variables 1');

        trace(r.token, r.cls, r.results);
    }

    @:defaultCommand public function help() {
        //
    }
}