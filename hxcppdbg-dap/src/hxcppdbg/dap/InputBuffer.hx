package hxcppdbg.dap;

import hxcppdbg.dap.protocol.ProtocolMessage;
import haxe.io.Bytes;
import haxe.Json;
import haxe.ds.Option;
import haxe.io.BytesData;

class InputBuffer
{
    final buffer : BytesData;

    public function new()
    {
        buffer = new BytesData();
    }

    public function append(_bytes : Bytes)
    {
        for (byte in _bytes.getData())
        {
            buffer.push(byte);
        }

        final messages = new Array<ProtocolMessage>();

        while (true)
        {
            switch getMessage()
            {
                case Some(msg):
                    messages.push(msg);
                case None:
                    return messages;
            }
        }
    }

    function getMessage()
    {
        return switch Bytes.ofData(buffer).toString().split('\r\n\r\n')
        {
            case [ _ ]:
                Option.None;
            case array:
                final header = array[0];
                final body   = array[1];
                
                switch header.split(':')
                {
                    case [ _, length ]:
                        switch Std.parseInt(length)
                        {
                            case null:
                                Option.None;
                            case length:
                                if (length > body.length)
                                {
                                    Option.None;
                                }
                                else
                                {
                                    buffer.splice(0, 4 + header.length + length);

                                    return Option.Some((Json.parse(body.substr(0, length)) : ProtocolMessage));
                                }
                        }
                    case _:
                        Option.None;
                }
        }
    }
}