package hxcppdbg.core;

import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.drivers.Driver;

class DebugSession {
    public final driver : Driver;

    public final sourcemap : Sourcemap;

    public final breakpoints : Breakpoints;

    public function new(_driver, _sourcemap) {
        driver      = _driver;
        sourcemap   = _sourcemap;
        breakpoints = new Breakpoints(sourcemap, driver.breakpoints);
    }
}