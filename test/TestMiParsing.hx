import hxcppdbg.gdb.Parser.MiParser;

function main() {
    testValue();
    testResult();

    testEmptyTuple();
    testTuple();

    testEmptyList();
    testValueList();
    testResultList();
    testMixedList();

    testStreamRecord();

    testResultRecord();

    testOutput();
}

function testValue() {
    trace('value');
    final parser = new MiParser('"myVal"');
    trace(parser.parseValue());
}

function testResult() {
    trace('result');
    final parser = new MiParser('myVal="some val"');
    trace(parser.parseResult());
}

function testEmptyTuple() {
    trace('empty tuple');
    final parser = new MiParser('{}');
    trace(parser.parseValue());
}

function testTuple() {
    trace('tuple');
    final parser = new MiParser('{ myVal1="some val1", myVal2="some val2" }');
    trace(parser.parseValue());
}

function testEmptyList() {
    trace('empty list');
    final parser = new MiParser('[]');
    trace(parser.parseValue());
}

function testValueList() {
    trace('value list');
    final parser = new MiParser('[ "myVal1", "myVal2" ]');
    trace(parser.parseValue());
}

function testResultList() {
    trace('result list');
    final parser = new MiParser('[ myVal1="some val1", myVal2="some val2" ]');
    trace(parser.parseValue());
}

function testMixedList() {
    trace('mixed list');
    final parser = new MiParser('[ "my const", myVal1="some val1", { myVal1="some val1", myVal2="some val2" } ]');
    trace(parser.parseValue());
}

function testStreamRecord() {
    trace('console stream');
    final parser = new MiParser('~"my console stream output"\n');
    trace(parser.parseStreamRecord());

    trace('target stream');
    final parser = new MiParser('@"my target stream output"\n');
    trace(parser.parseStreamRecord());

    trace('log stream');
    final parser = new MiParser('&"my log stream output"\n');
    trace(parser.parseStreamRecord());
}

function testResultRecord() {
    trace('result record');
    final parser = new MiParser('12^running\n');
    trace(parser.parseResultRecord());
}

function testOutput() {
    trace('output');
    final parser = new MiParser('=thread-group-started,id="i1",pid="22901"\n=thread-created,id="1",group-id="i1"\n=breakpoint-modified,bkpt={number="1",type="breakpoint",disp="keep",enabled="y",addr="0x00005555555a63d7",func="Main_obj::main()",file="./src/Main.cpp",fullname="/mnt/d/programming/haxe/hxcppdbg/sample/bin/src/Main.cpp",line="43",thread-groups=["i1"],times="0",original-location="src/Main.cpp:43"}\n=library-loaded,id="/lib64/ld-linux-x86-64.so.2",target-name="/lib64/ld-linux-x86-64.so.2",host-name="/lib64/ld-linux-x86-64.so.2",symbols-loaded="0",thread-group="i1",ranges=[{from="0x00007ffff7fd0100",to="0x00007ffff7ff2674"}]\n^running\n*running,thread-id="all"\n(gdb)');
    trace(parser.parseOutput());
}
