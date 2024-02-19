package hxcppdbg.core.model;

import haxe.Exception;
import buddy.BuddySuite;
import mockatoo.Mockatoo;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.IIndexable;

using buddy.Should;

class IndexableTests extends BuddySuite
{
    public function new()
    {
        describe('Indexable', {
            final driver = Mockatoo.mock(IIndexable, [ String ]);
            final count  = 7;
            final sut    = new Indexable<String>(driver);

            Mockatoo
                .when(driver.count())
                .thenReturn(Result.Success(count))
                .thenReturn(Result.Error(new Exception("unexpected")));

            Mockatoo
                .when(driver.at(0))
                .thenReturn(Result.Success('Hello'))
                .thenReturn(Result.Success('World'))
                .thenReturn(Result.Error(new Exception("unexpected")));

            it('can return the count', {
                switch sut.count()
                {
                    case Success(v):
                        v.should.be(count);
                    case Error(e):
                        fail(e.message);
                }
            });

            it('will cache the count result', {
                switch sut.count()
                {
                    case Success(v):
                        v.should.be(count);

                        Mockatoo.verify(driver.count(), times(1));
                    case Error(e):
                        fail(e.message);
                }
            });

            it('will return the value at the index', {
                switch sut.at(0)
                {
                    case Success(v):
                        v.should.be('Hello');
                    case Error(e):
                        fail(e.message);
                }
            });

            it('will cache the value at the index', {
                switch sut.at(0)
                {
                    case Success(v):
                        v.should.be('Hello');

                        Mockatoo.verify(driver.at(0), times(1));
                    case Error(e):
                        fail(e.message);
                }
            });

            it('allows forcing a refresh of the cached value', {
                switch sut.at(0, true)
                {
                    case Success(v):
                        v.should.be('World');

                        Mockatoo.verify(driver.at(0), times(2));
                    case Error(e):
                        fail(e.message);
                }
            });

            it('will cache the refreshed value', {
                switch sut.at(0)
                {
                    case Success(v):
                        v.should.be('World');

                        Mockatoo.verify(driver.at(0), times(2));
                    case Error(e):
                        fail(e.message);
                }
            });
        });
    }
}