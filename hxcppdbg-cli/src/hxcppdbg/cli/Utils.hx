package hxcppdbg.cli;

import tink.CoreApi.Future;
import haxe.io.Eof;
import haxe.ds.Option;
import hxcppdbg.core.Session;
import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.drivers.Interrupt;

using Lambda;

function printStopReason(_session : Session, _interrupt : Interrupt)
{
    return switch _interrupt
    {
        case ExceptionThrown(threadIndex):
            printExceptionLocation(_session, threadIndex);
        case BreakpointHit(threadIndex, id):
            printBreakpointHitLocation(_session, threadIndex, id);
        case Other:
            Future.sync('');
    }
}

private function printBreakpointHitLocation(_session : Session, _threadIndex : Option<Int>, _id : Option<Int>)
{
    final message = switch _threadIndex
    {
        case Some(idx):
            switch _id
            {
                case Some(id):
                    switch _session.breakpoints.get(id)
                    {
                        case Some(bp):
                            final output  = [ 'Thread ${ idx } hit breakpoint ${ bp.id } at ${ bp.file } Line ${ bp.line }' ];
                            final minLine = Std.int(Math.max(1, bp.line - 3)) - 1;
                            final maxLine = bp.line + 3;
                            final input   = sys.io.File.read(bp.file.toString(), false);

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
            
                                    if (bp.line == absLine)
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

                            output.join('\n');
                        case None:
                            'Unable to get breakpoint for ID $id';
                    }
                case None:
                    'Breakpoint hit with an unknown ID';
            }
        case None:
            'Breakpoint hit on an unknown thread';
    }

    return Future.sync(message);
}

private function printExceptionLocation(_session : Session, _threadIndex : Option<Int>)
{
    return Future.irreversible(_resolve -> {
        switch _threadIndex
        {
            case Some(idx):
                _session.stack.getCallStack(idx, result -> {
                    final message = switch result
                    {
                        case Success(stack):
                            switch stack.find(isHaxeFrame)
                            {
                                case Haxe(haxe, _):
                                    final exnFile = haxe.file.haxe;
                                    final exnLine = haxe.expr.haxe.start.line;

                                    final output  = [ 'Thread $idx has thrown an exception at $exnFile Line $exnLine' ];
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
                                    'exception thrown which contained no haxe frames in thread $idx';
                            }
                        case Error(_):
                            'unable to get the stack for an exception thrown in thread $idx';
                    }

                    _resolve(message);
                });
            case None:
                _resolve('exception thrown on unknown thread');
        }
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