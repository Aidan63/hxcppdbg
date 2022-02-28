class Main {
	static function main() {
		new sub.Resources()
			.load('test')
			.subscribe(() -> {
				final f = (i) -> trace(i);

				f(7);

				trace('callback');
			}, 0);

		trace("Hello, world!");
	}
}