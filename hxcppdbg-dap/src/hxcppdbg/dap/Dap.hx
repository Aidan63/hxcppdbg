package hxcppdbg.dap;

import sys.thread.Thread;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import cpp.asio.Code;
import cpp.asio.Result;
import cpp.asio.TcpSocket;

using Lambda;

class Dap
{
    public var mode : String;

    public function new()
    {
        mode = 'stdio';
    }

    @:defaultCommand
    public function run()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            switch mode
            {
                case 'socket':
                    cpp.asio.TcpSocket.bind('127.0.0.1', 7777, onSocketListen.bind(_reject));
                case 'stdio':
                    cpp.asio.TTY.open(Stdout, result -> {
                        switch result
                        {
                            case Success(stdout):
                                cpp.asio.TTY.open(Stdin, result -> {
                                    switch result
                                    {
                                        case Success(stdin):
                                            new DapSession(stdin.read, stdout.write, () -> {
                                                stdout.close();
                                                stdin.close();
                                                
                                                _resolve(null);
                                            });
                                        case Error(error):
                                            _reject(new Error('stdin ${ error.toString() }'));
                                    }
                                });
                            case Error(error):
                                _reject(new Error('stdout ${ error.toString() }'));
                        }
                    });
                case other:
                    _reject(new Error('unknown mode $other'));
            }
        });
    }

    @:command
    public function help()
    {
        //
    }

    static function onSocketListen(_reject : Error->Void, _result : Result<TcpSocket, Code>)
    {
        switch _result
        {
            case Success(socket):
                socket.listen(onConnectionRequest.bind(_reject));
            case Error(code):
                _reject(new Error('failed to bind to address : $code'));
        }
    }

    static function onConnectionRequest(_reject : Error->Void, _result : Result<TcpRequest, Code>)
    {
        switch _result
        {
            case Success(request):
                request.accept(onClientConnected);
            case Error(code):
                _reject(new Error('failed to listen for connection requests : $code'));
        }
    }

    static function onClientConnected(_result : Result<TcpClient, Code>)
    {
        switch _result
        {
            case Success(client):
                new DapSession(client.stream, client.stream, () -> client.close());
            case Error(code):
                Sys.println('failed to connect client : $code');
        }
    }
}