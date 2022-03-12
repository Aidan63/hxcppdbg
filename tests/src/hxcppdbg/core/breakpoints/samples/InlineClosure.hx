class InlineClosure {
    static function main() {
        final f = () -> trace('hello world!');

        f();
    }
}