package hxcppdbg.core.breakpoints;

import sys.io.File;
import haxe.ds.Option;
import buddy.BuddySuite;
import json2object.JsonParser;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.IBreakpoints;
import hxcppdbg.core.sourcemap.Sourcemap;

using buddy.Should;

class BreakpointsTests extends BuddySuite
{
    final parser = new JsonParser<Sourcemap>();

    public function new()
    {
        describe('placing a breakpoint in a function', {
            final driver = new StubBreakpoints();
            final sut    = new Breakpoints(
                parser.fromJson(File.getContent('D:/programming/haxe/hxcppdbg/tests/src/hxcppdbg/core/breakpoints/samples/hello_sourcemap.json')),
                driver);

            switch sut.create('Hello.hx', 3, 0)
            {
                case Success(v):
                    describe('source file location', {
                        it('will return the absolute path of the haxe source file the breakpoint was set in', {
                            v.file.should.be('D:/programming/haxe/hxcppdbg/tests/src/hxcppdbg/core/breakpoints/samples/Hello.hx');
                        });
                        it('will return the line in the haxe file the breakpoint was set at', {
                            v.line.should.be(3);
                        });
                        it('will return 0 as the character offset as no offset was initially provided', {
                            v.char.should.be(0);
                        });
                    });
                case Error(e):
                    fail(e.message);
            }
        });

        describe('placing a breakpoint on the line defining a closure', {
            final driver = new StubBreakpoints();
            final sut    = new Breakpoints(
                parser.fromJson(File.getContent('D:/programming/haxe/hxcppdbg/tests/src/hxcppdbg/core/breakpoints/samples/inlineClosure_sourcemap.json')),
                driver);

            switch sut.create('InlineClosure.hx', 3, 0)
            {
                case Success(v):
                    it('will return the absolute path of the haxe source file the breakpoint was set in', {
                        v.file.should.be('D:/programming/haxe/hxcppdbg/tests/src/hxcppdbg/core/breakpoints/samples/InlineClosure.hx');
                    });
                    it('will return the line in the haxe file the breakpoint was set at', {
                        v.line.should.be(3);
                    });
                    it('will return 0 as the character offset as no offset was initially provided', {
                        v.char.should.be(0);
                    });
                    it('will return the expression of the closure definition', {
                        v.expr.haxe.start.line.should.be(3);
                        v.expr.haxe.start.col.should.be(9);

                        v.expr.haxe.end.line.should.be(3);
                        v.expr.haxe.end.col.should.be(47);
                    });
                case Error(e):
                    fail(e.message);
            }

        });

        describe('placing a breakpoint in a one line closure', {
            final driver = new StubBreakpoints();
            final sut    = new Breakpoints(
                parser.fromJson(File.getContent('D:/programming/haxe/hxcppdbg/tests/src/hxcppdbg/core/breakpoints/samples/inlineClosure_sourcemap.json')),
                driver);

            switch sut.create('InlineClosure.hx', 3, 27)
            {
                case Success(v):
                    it('will return the absolute path of the haxe source file the breakpoint was set in', {
                        v.file.should.be('D:/programming/haxe/hxcppdbg/tests/src/hxcppdbg/core/breakpoints/samples/InlineClosure.hx');
                    });
                    it('will return the line in the haxe file the breakpoint was set at', {
                        v.line.should.be(3);
                    });
                    it('will return 27 as that is the char offset requested', {
                        v.char.should.be(27);
                    });
                    it('will return the closures first expression', {
                        v.expr.haxe.start.line.should.be(3);
                        v.expr.haxe.start.col.should.be(25);

                        v.expr.haxe.end.line.should.be(3);
                        v.expr.haxe.end.col.should.be(30);
                    });
                case Error(e):
                    fail(e.message);
            }
        });
    }
}

class StubBreakpoints implements IBreakpoints
{
    public function new() {}

	public function create(_file : String, _line : Int)
    {
		return Result.Success(0);
	}

	public function remove(_id : Int)
    {
		return Option.None;
	}
}