class Main {
	static function main() {
		new sub.Resources()
			.load('')
			.subscribe(() -> trace('callback'), 0);

		trace("Hello, world!");
	}
}