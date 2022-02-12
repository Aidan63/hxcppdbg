class Main {
	static function main() {
		new sub.Resources()
			.load('test')
			.subscribe(() -> trace('callback'), 0);

		trace("Hello, world!");
	}
}