class Main {
	static function main() {
		new sub.Resources()
			.load('test')
			.subscribe(() -> {
				final f = (i) -> {
					sys.io.File.read('does_not_exist.txt');
				}

				f(7);

				while (true)
				{
					haxe.io.Bytes.alloc(Std.random(1000));

					Sys.sleep(1);
				}
			}, 0);
	}
}