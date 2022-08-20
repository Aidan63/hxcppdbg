package sub;

import haxe.ds.Option;
import haxe.ds.Either;

class Resources {
	public function new() {}

	public function load(_name : String) {
		final id      = Math.random() * 1000;
		final resname = _name + id;
		final opts    = [
			for (i in 0...Std.random(10))
				if (Std.random(2) == 0) Either.Left(new Holder(i)) else Either.Right({ anon : i })
		];

		return this;
	}

	public function subscribe(_onCompleted : Void->Void, v : Int) {
		_onCompleted();
	}
}

private class Holder
{
	public final v : Dynamic;

	public function new (_v)
	{
		v = _v;
	}
}