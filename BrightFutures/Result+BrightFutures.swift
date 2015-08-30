//
//  Result+BrightFutures.swift
//  BrightFutures
//
//  Created by Thomas Visser on 30/08/15.
//  Copyright © 2015 Thomas Visser. All rights reserved.
//

import Result

extension ResultType {
    /// Enables the chaining of two failable operations where the second operation is asynchronous and
    /// represented by a future.
    /// Like map, the given closure (that performs the second operation) is only executed
    /// if the first operation result is a .Success
    /// If a regular `map` was used, the result would be `Result<Future<U>>`.
    /// The implementation of this function uses `map`, but then flattens the result before returning it.
    public func flatMap<U>(@noescape f: Value -> Future<U, Error>) -> Future<U, Error> {
        return analysis(ifSuccess: {
            return f($0)
        }, ifFailure: {
            return Future<U, Error>(error: $0)
        })
    }
}

extension ResultType where Value: ResultType, Error == Value.Error {
    
    /// Returns a .Failure with the error from the outer or inner result if either of the two failed
    /// or a .Success with the success value from the inner Result
    public func flatten() -> Result<Value.Value,Value.Error> {
        return analysis(ifSuccess: { innerRes in
            return innerRes.analysis(ifSuccess: {
                return Result(value: $0)
            }, ifFailure: {
                return Result(error: $0)
            });
        }, ifFailure: {
            return Result(error: $0)
        })
    }
}

extension ResultType where Value: AsyncType {
    /// Returns the inner future if the outer result succeeded or a failed future
    /// with the error from the outer result otherwise
    public func flatten<T, E>(result: Result<Future<T, E>,E>) -> Future<T, E> {
        return result.analysis(ifSuccess: { $0 }, ifFailure: { Future(error: $0) })
    }
}
