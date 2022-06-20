package hxcppdbg.dap;

import haxe.io.Bytes;
import sys.io.File;
import haxe.ds.Option;
import buddy.BuddySuite;
import hxcppdbg.dap.InputBuffer;

using buddy.Should;

class InputBufferTests extends BuddySuite
{
    public function new()
    {
        describe('buffer parsing', {
            it('can parse complete dap messages', {
                final buffer = new InputBuffer();
                final str    = 'Content-Length: 89\r\n\r\n{ "seq" : 153, "type" : "request", "command" : "next", "arguments" : { "threadId" : 3 } }';
                final actual = buffer.append(Bytes.ofString(str));

                switch actual
                {
                    case Some(v):
                        (v.seq : Int).should.be(153);
                        (v.type : String).should.be('request');
                        (v.command : String).should.be('next');
                        (v.arguments.threadId : Int).should.be(3);
                    case None:
                        fail('expected Option.Some');
                }
            });

            it('will not parse incomplete dap messages', {
                final buffer = new InputBuffer();
                final str    = 'Content-Length: 89\r\n\r\n{ "seq" : 153, "type" : "request",';
                final actual = buffer.append(Bytes.ofString(str));

                actual.should.equal(Option.None);
            });

            it('will keep partial messages', {
                final buffer = new InputBuffer();
                final str1   = 'Content-Length: 89\r\n\r\n{ "seq" : 153, "type" : "request", "command" : "next", "arguments" : { "threadId" : 3 } }Content-Length: 89\r\n\r\n{ "seq" : 154, "type" : "request",';
                final str2   = ' "command" : "next", "arguments" : { "threadId" : 4 } }';

                switch buffer.append(Bytes.ofString(str1))
                {
                    case Some(v):
                        (v.seq : Int).should.be(153);
                        (v.type : String).should.be('request');
                        (v.command : String).should.be('next');
                        (v.arguments.threadId : Int).should.be(3);
                    case None:
                        fail('expected Option.Some');
                }

                switch buffer.append(Bytes.ofString(str2))
                {
                    case Some(v):
                        (v.seq : Int).should.be(154);
                        (v.type : String).should.be('request');
                        (v.command : String).should.be('next');
                        (v.arguments.threadId : Int).should.be(4);
                    case None:
                        fail('expected Option.Some');
                }
            });
        });
    }
}