package hxcppdbg.core.model;

import hxcppdbg.core.drivers.IKeyable;
import mockatoo.Mockatoo;
import buddy.BuddySuite;

class KeyableTests extends BuddySuite
{
    public function new()
    {
        describe('Keyable', {
            final driver = Mockatoo.mock(IKeyable, [ String, String ]);
        });
    }
}