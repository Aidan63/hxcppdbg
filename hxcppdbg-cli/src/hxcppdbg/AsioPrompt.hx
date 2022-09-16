package hxcppdbg;

import haxe.io.Bytes;
import tink.core.Error;
import tink.Stringly;
import tink.CoreApi.Noise;
import tink.CoreApi.Promise;
import cpp.asio.streams.IWriteStream;
import cpp.asio.streams.IReadStream;
import tink.cli.Prompt;

class AsioPrompt implements Prompt
{
    final stdin : IReadStream;

    final stdout : IWriteStream;

    public function new(_stdin, _stdout)
    {
        stdin  = _stdin;
        stdout = _stdout;
    }

    public function print(_v : String) : Promise<Noise>
    {
        return Promise.irreversible((_success : Noise->Void, _failure : Error->Void) -> {
            stdout.write(Bytes.ofString(_v), result -> {
                switch result
                {
                    case Some(code):
                        _failure(new Error(code.toString()));
                    case None:
                        _success(null);
                }
            });
        });
    }

    public function println(_v : String) : Promise<Noise>
    {
        return print('$_v\n');
    }

    public function prompt(_type : PromptType) : Promise<Stringly>
    {
        return Promise.irreversible((_success : Stringly->Void, _failure : Error->Void) -> {
            switch _type
            {
                case Simple(prompt):
                    stdout.write(Bytes.ofString('$prompt : '), result -> {
                        switch result
                        {
                            case Some(error):
                                _failure(Error.withData(error.toString(), error));
                            case None:
                                stdin.read(result -> {
                                    switch result
                                    {
                                        case Success(data):
                                            stdin.stop();
                    
                                            _success(data.toString());
                                        case Error(error):
                                            _failure(Error.withData(error.toString(), error));
                                    }
                                });
                        }
                    });
                case MultipleChoices(prompt, choices):
                    //
                case Secure(prompt):
                    //
            }
        });
    }
}