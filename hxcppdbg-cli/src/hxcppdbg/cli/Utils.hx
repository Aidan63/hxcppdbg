package hxcppdbg.cli;

import tink.CoreApi.Future;
import haxe.Int64;
import haxe.io.Eof;
import haxe.ds.Option;
import hxcppdbg.core.Session;
import hxcppdbg.core.StopReason;
import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.breakpoints.Breakpoint;

using Lambda;

function printStopReason(_session : Session, _stop : StopReason)
{
    return switch _stop
    {
        case BreakpointHit(threadIndex, breakpoint):
            printBreakpointHitLocation(_session, threadIndex, breakpoint);
        case ExceptionThrown(threadIndex):
            printExceptionLocation(_session, threadIndex);
        case Paused:
            Future.sync('');
        case Exited(exitCode):
            Future.sync('Target exited with code $exitCode');
    }
}

private function printBreakpointHitLocation(_session : Session, _threadIndex : Int, _breakpoint : Breakpoint)
{
    final output  = [ 'Thread ${ _threadIndex } hit breakpoint ${ _breakpoint.id } at ${ _breakpoint.file } Line ${ _breakpoint.line }' ];
    final minLine = Std.int(Math.max(1, _breakpoint.line - 3)) - 1;
    final maxLine = _breakpoint.line + 3;
    final input   = sys.io.File.read(_breakpoint.file.toString(), false);

    // Read all lines up until the ones we're actually interested in.
    var i = 0;
    while (i < minLine)
    {
        input.readLine();
        i++;
    }

    for (i in 0...(maxLine - minLine))
    {
        try
        {
            final buffer  = new StringBuf();
            final line    = input.readLine();
            final absLine = minLine + i + 1;

            if (_breakpoint.line == absLine)
            {
                buffer.add('=>\t');
            }
            else
            {
                buffer.add('\t');
            }

            buffer.add('$absLine: $line');

            output.push(buffer.toString());
        }
        catch (_ : Eof)
        {
            break;
        }
    }

    input.close();

    return Future.sync(output.join('\n'));
}

private function printExceptionLocation(_session : Session, _threadIndex : Int)
{
    return Future.irreversible(_resolve -> {
        _session.stack.getCallStack(_threadIndex, result -> {
            final message = switch result
            {
                case Success(stack):
                    switch stack.find(isHaxeFrame)
                    {
                        case Haxe(haxe, _):
                            final exnFile = haxe.file.haxe;
                            final exnLine = haxe.expr.haxe.start.line;

                            final output  = [ 'Thread $_threadIndex has thrown an exception at $exnFile Line $exnLine' ];
                            final minLine = Std.int(Math.max(1, exnLine - 3)) - 1;
                            final maxLine = exnLine + 3;
                            final input   = sys.io.File.read(exnFile.toString(), false);
    
                            // Read all lines up until the ones we're actually interested in.
                            var i = 0;
                            while (i < minLine)
                            {
                                input.readLine();
                                i++;
                            }
    
                            for (i in 0...(maxLine - minLine))
                            {
                                try
                                {
                                    final buffer  = new StringBuf();
                                    final line    = input.readLine();
                                    final absLine = minLine + i + 1;
    
                                    if (exnLine == absLine)
                                    {
                                        buffer.add('=>\t');
                                    }
                                    else
                                    {
                                        buffer.add('\t');
                                    }
    
                                    buffer.add('$absLine: $line');
                                    output.push(buffer.toString());
                                }
                                catch (_ : haxe.io.Eof)
                                {
                                    break;
                                }
                            }
    
                            input.close();

                            output.join('\n');
                        case _:
                            'exception thrown which contained no haxe frames in thread $_threadIndex';
                    }
                case Error(_):
                    'unable to get the stack for an exception thrown in thread $_threadIndex';
            }

            _resolve(message);
        });
    });
}

private function isHaxeFrame(_frame : StackFrame)
{
    return switch _frame
    {
        case Haxe(_, _):
            true;
        case Native(_):
            false;
    }
}