class Resources {
	public function new() {}

	public function load(_name : String) {
		trace('loading $_name');

		return this;
	}

	public function subscribe(_onCompleted : Void->Void, v : Int) {
		trace('invoking callback $v');

		_onCompleted();
	}
}