public enum Stream<T> {
    case empty
    case cons (T, ()->Stream<T>)
}

public func head<T>(_ aStream: Stream<T>) -> T {
    switch aStream {
    case .empty: 
        fatalError("Exception: Stream.head: empty list")
    case .cons (let value, _):
        return value
    }
}

public func tail<T>(_ aStream: Stream<T>) -> () -> Stream<T> {
    switch aStream {
    case .empty:
        fatalError("Exception: Stream.head: empty list")
    case .cons (_, let list):
        return list
    }
}

public func isEmpty<T>(_ aStream: Stream<T>) -> Bool {
    switch aStream {
    case .empty:
        return true
    case .cons:
        return false
    }
}

public func concat<T>(_ aStream: Stream<T>, _ bStream: Stream<T>) -> Stream<T> {
    switch aStream {
    case .empty:
        return bStream
    case .cons(let value, let list):
        return .cons(value, {concat(list(), bStream)})
    }
}

public func reverse<T>(_ aStream: Stream<T>) -> Stream<T> {

    func helper(_ aStream: Stream<T>, _ accumulator: Stream<T>) -> Stream<T> {
        switch aStream {
        case .empty:
            return accumulator
        case .cons(let head, let tail):
            return helper(tail(), .cons(head, {accumulator}))
        }
    }
    return helper(aStream, .empty)
}

public func reduce<T, R>(_ aStream: Stream<T>) -> (R) -> ((R, T) -> (R)) -> R {
    return { (initialResult: R) in
        return { (transform: ((R, T)->R)) in
            switch aStream {
            case .empty:
                return initialResult
            case .cons(let value, let tail):
            //print("reduce cons", value)
                var accumulator = transform(initialResult, value)
                accumulator = reduce(tail())(accumulator)(transform)
                return accumulator
            }
        }
    }
}

public func map<T, R>(_ aStream: Stream<T>, _ transform: @escaping (T) -> (R)) -> Stream<R> {
    switch aStream {
    case .empty:
        return .empty
    case .cons(let value, let list):
        return .cons(transform(value), { map(list(), transform) })
    }
}

func take<T>(_ aStream: Stream<T>) -> (Int) -> (Stream<T>) {
    func helper(_ accumulator: Stream<T>) -> ((Int) -> Stream<T>) {
        return { (n: Int) in
            switch accumulator {
            case .empty:
                return accumulator
            case .cons(let head, let tail): 
                if n == 0 {
                    return .empty
                } else {
                    return .cons(head, { helper(tail())(n-1) })
                }
            }
        }
    }
    return helper(aStream)
}

public func traverse<T>(_ aStream: Stream<T>, _ body: (Stream<T>) -> ()) {
    switch aStream {
    case .empty:
        body(.empty)
    case .cons(let value, let list):
        body(.cons(value, list))
        traverse(list(), body)
    }
}

