package hxcppdbg.core.utils;

import haxe.Exception;
import hxcppdbg.core.ds.Result;

using Lambda;

function asExceptionResult<T, E : Exception>(_result : Result<T, E>) : Result<T, Exception>
{
    return switch _result
    {
        case Success(v):
            Result.Success(v);
        case Error(e):
            Result.Error(e);
    }
}

function resultOrThrow<T, E : Exception>(_result : Result<T, E>)
{
    return switch _result
    {
        case Success(v):
            v;
        case Error(e):
            throw e;
    }
}

function map<A, B, E : Exception>(_result : Result<Array<A>, E>, f : (item : A) -> B) : Result<Array<B>, E>
{
    return switch _result
    {
        case Success(v):
            Result.Success(v.map(f));
        case Error(e):
            Result.Error(e);
    }
}

function apply<A, B, E : Exception>(_result : Result<A, E>, f : (item : A) -> B) : Result<B, E>
{
    return switch _result
    {
        case Success(v):
            Result.Success(f(v));
        case Error(e):
            Result.Error(e);
    }
}