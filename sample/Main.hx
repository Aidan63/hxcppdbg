class Main {
	static function main() {
		new sub.Resources()
			.load('test')
			.subscribe(() -> {
				final f = (i) -> {
					trace(i);
				}

				f(7);

				trace('callback');

				while (true)
				{
					haxe.io.Bytes.alloc(Std.random(1000));

					Sys.sleep(1);
				}
			}, 0);
	}
}