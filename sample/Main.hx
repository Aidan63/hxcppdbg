class Main {
	static function main() {
		new Resources()
			.load('')
			.subscribe(() -> trace('callback'), 0);

		trace("Hello, world!");
	}
}