package hxcppdbg.core.drivers.gdb;

import haxe.Exception;
import haxe.ds.Option;
import haxe.ds.Either;
import hxparse.Parser.parse as parse;

enum ResultClass {
    RDone;
    RRunning;
    RConnected;
    RError;
    RExit;
}

enum AsyncClass {
    AStopped;
}

enum StreamOutput {
    Console;
    Target;
    Log;
}

enum AsyncOutput {
    Exec;
    Status;
    Notify;
}

enum Token {
    TResultClass(v:ResultClass);
    TAsyncClass(v:AsyncClass);
    TString(v:String);
    TTupleOpen;
    TTupleClose;
    TListOpen;
    TListClose;
    TStreamRecord(v:StreamOutput);
    TAsyncRecord(v:AsyncOutput);
    TResult;
    TToken(v:String);
    TCString(v:String);
    TComma;
    TNewLine;
    TGdb;
	TEof;
}

enum Value {
    Const(v : String);
    Tuple(v : Map<String, Value>);
    List(v : Either<Array<Value>, Array<Result>>);
}

class MiLexer extends hxparse.Lexer implements hxparse.RuleBuilder {
    static var buf : StringBuf;

    public static var tok = @:rule [
        "{" => TTupleOpen,
        "}" => TTupleClose,
        "[" => TListOpen,
        "]" => TListClose,
        "*" => TAsyncRecord(Exec),
        "+" => TAsyncRecord(Status),
        "=" => TAsyncRecord(Notify),
        "~" => TStreamRecord(Console),
        "@" => TStreamRecord(Target),
        "&" => TStreamRecord(Log),
        "^" => TResult,
        "," => TComma,
        "\\(gdb\\)" => TGdb,
        "-?(([1-9][0-9]*)|0)(.[0-9]+)?([eE][\\+\\-]?[0-9]+)?" => TToken(lexer.current),
        "-?([a-zA-Z1-9_\\-]*)" => TString(lexer.current),
        '"' => {
			buf = new StringBuf();
			lexer.token(string);
			TCString(buf.toString());
		},
        "\n" => TNewLine,
        "\r\n" => TNewLine,
        "[\t ]" => lexer.token(tok),
        "" => TEof
    ];

    public static var string = @:rule [
		"\\\\t" => {
			buf.addChar("\t".code);
			lexer.token(string);
		},
		"\\\\n" => {
			buf.addChar("\n".code);
			lexer.token(string);
		},
		"\\\\r" => {
			buf.addChar("\r".code);
			lexer.token(string);
		},
		'\\\\"' => {
			buf.addChar('"'.code);
			lexer.token(string);
		},
		"\\\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]" => {
			buf.add(String.fromCharCode(Std.parseInt("0x" +lexer.current.substr(2))));
			lexer.token(string);
		},
		'"' => {
			lexer.curPos().pmax;
		},
		'[^"]' => {
			buf.add(lexer.current);
			lexer.token(string);
		},
	];
}

class AsyncRecord {
    public final token : Option<Int>;

    public final output : AsyncOutput;

    public final cls : String;

    public final results : Map<String, Value>;

    public function new(_token, _output, _cls, _results) {
        token   = _token;
        output  = _output;
        cls     = _cls;
        results = _results;
    }
}

class StreamRecord {
    public final output : StreamOutput;

    public final value : String;

    public function new(_output, _value) {
        output = _output;
        value  = _value;
    }
}

class Result {
    public final variable : String;

    public final value : Value;

    public function new(_variable, _value) {
        variable = _variable;
        value    = _value;
    }
}

enum OOBRecord {
    Async(v : AsyncRecord);
    Stream(v : StreamRecord);
}

class ResultRecord {
    public final token : Option<Int>;

    public final cls : ResultClass;

    public final results : Map<String, Value>;

    public function new(_token, _cls, _results) {
        token   = _token;
        cls     = _cls;
        results = _results;
    }
}

class MiParser extends hxparse.Parser<hxparse.LexerTokenSource<Token>, Token> {
    public function new(_input) {
        final lexer  = new MiLexer(byte.ByteData.ofString(_input));
        final source = new hxparse.LexerTokenSource(lexer, MiLexer.tok);

        super(source);
    }

    public function parseLine() {
        return if (hasOOB()) {
            Left(parseOutOfBandRecord());
        } else {
            Right(parseResultRecord());
        }
    }

    private function hasOOB() {
        return switch peek(0) {
            case TAsyncRecord(_), TStreamRecord(_):
                true;
            case TToken(_):
                peek(1).match(TAsyncRecord(_));
            case _:
                false;
        }
    }

    public function parseResultRecord() {
        final token = switch peek(0) {
            case TToken(v):
                junk();
                Some(Std.parseInt(v));
            case _:
                None;
        }

        return parse(switch stream {
            case [ TResult, rc = parseResultClass() ]:
                final acc = new Map<String, Value>();

                while (peek(0) == TComma) {
                    junk();

                    final result = parseResult();

                    acc[result.variable] = result.value;
                }

                switch stream {
                    case [ TNewLine ]:
                        return new ResultRecord(token, rc, acc);
                }
        });
    }

    public function parseResultClass() {
        return parse(switch stream {
            case [ TString('done') ]:
                ResultClass.RDone;
            case [ TString('running') ]:
                ResultClass.RRunning;
            case [ TString('connected') ]:
                ResultClass.RConnected;
            case [ TString('error') ]:
                ResultClass.RError;
            case [ TString('exit') ]:
                ResultClass.RExit;
        });
    }

    public function parseAsyncOutput() {
        return parse(switch stream {
            case [ TString(cls) ]:
                final acc = new Map<String, Value>();

                while (peek(0) == TComma) {
                    junk();

                    final result = parseResult();

                    acc[result.variable] = result.value;
                }

                { cls : cls, results : acc };
        });
    }

    public function parseResult() : Result {
        return parse(switch stream {
            case [ TString(v1), TAsyncRecord(Notify), v2 = parseValue() ]:
                new Result(v1, v2);
        });
    }

    public function parseValue() : Value {
        return parse(switch stream {
            case [ TCString(v) ]:
                Value.Const(v);
            case [ TTupleOpen, tuple = parseTuple([]) ]:
                Value.Tuple(tuple);
            case [ TListOpen, list = parseList(null) ]:
                Value.List(list);
        });
    }

    public function parseTuple(acc : Map<String, Value>) {
        return parse(switch stream {
            case [ TTupleClose ]:
                acc;
            case [ v = parseResult() ]:
                acc[v.variable] = v.value;

                switch stream {
                    case [ TTupleClose ]:
                        acc;
                    case [ TComma ]:
                        parseTuple(acc);
                }
        });
    }

    public function parseList(acc : Null<Either<Array<Value>, Array<Result>>>) {
        return parse(switch stream {
            case [ TListClose ]:
                acc;
            case _:
                final elt = switch [ peek(0), peek(1) ] {
                    case [ TString(_), TAsyncRecord(Notify) ]:
                        Left(parseResult());
                    case _:
                        Right(parseValue());
                }

                // if the acc structure is null create it based on the element we just parsed.
                if (acc == null) {
                    acc = switch elt {
                        case Left(v): Right(new Array<Result>());
                        case Right(v): Left(new Array<Value>());
                    }
                }

                // If the element parsed is not fit on the acc structure just throw an exception.
                switch acc {
                    case Left(values):
                        switch elt {
                            case Right(value):
                                values.push(value);
                            case _:
                                throw new Exception('result will not fit in a list of values');                                
                        }
                    case Right(results):
                        switch elt {
                            case Left(result):
                                results.push(result);
                            case _:
                                throw new Exception('value will not fit in a results map');
                        }
                }

                switch stream {
                    case [ TListClose ]:
                        acc;
                    case [ TComma ]:
                        parseList(acc);
                }
        });
    }

    public function parseOutOfBandRecord() {
        return switch peek(0)
        {
            case TToken(_), TAsyncRecord(_):
                Async(parseAsyncRecord());
            case _:
                Stream(parseStreamRecord());
        }
    }

    public function parseStreamRecord() {
        return parse(switch stream {
            case [ TStreamRecord(output), TCString(v), TNewLine ]:
                new StreamRecord(output, v);
        });
    }

    public function parseAsyncRecord() {
        final token = switch peek(0) {
            case TToken(v):
                junk();
                Some(Std.parseInt(v));
            case _:
                None;
        }

        return parse(switch stream {
            case [ TAsyncRecord(t), o = parseAsyncOutput(), TNewLine ]:
                new AsyncRecord(token, t, o.cls, o.results);
        });
    }
}