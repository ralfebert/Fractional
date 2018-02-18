// © 2015-2018 Jaden Geller, Brian Tiger Chow, Ralf Ebert
// License: https://opensource.org/licenses/MIT

public typealias Fraction = Fractional<Int>

private func gcd<Number: BinaryInteger>(_ lhs: Number, _ rhs: Number) -> Number {
	var lhs = lhs, rhs = rhs
	while rhs != 0 { (lhs, rhs) = (rhs, lhs % rhs) }
	return lhs
}
	
private func lcm<Number: BinaryInteger>(_ lhs: Number, _ rhs: Number) -> Number {
	return lhs * rhs / gcd(lhs, rhs)
}

private func reduce<Number: BinaryInteger>(numerator: Number, denominator: Number) -> (numerator: Number, denominator: Number) {
	var divisor = gcd(numerator, denominator)
	if divisor < 0 { divisor *= -1 }
	guard divisor != 0 else { return (numerator: numerator, denominator: 0) }
	return (numerator: numerator / divisor, denominator: denominator / divisor)
}

public struct Fractional<Number: BinaryInteger & Codable> : Codable {
	/// The numerator of the fraction.
	public let numerator: Number
	
	/// The (always non-negative) denominator of the fraction.
	public let denominator: Number
	
	public init(_ numerator: Number, _ denominator: Number) {
		var (numerator, denominator) = reduce(numerator: numerator, denominator: denominator)
		if denominator < 0 { numerator *= -1; denominator *= -1 }
								
		self.numerator = numerator
		self.denominator = denominator
	}
    
    /// Create an instance initialized to `value`.
    public init(_ value: Number) {
        self.init(value, 1)
    }
}	

extension Fractional: Equatable {
    public static func ==(lhs: Fractional, rhs: Fractional) -> Bool {
        return lhs.numerator == rhs.numerator && lhs.denominator == rhs.denominator
    }
}

extension Fractional: Comparable {
    
    public static func <(lhs: Fractional, rhs: Fractional) -> Bool {
        guard !lhs.isNaN && !rhs.isNaN else { return false }
        guard lhs.isFinite && rhs.isFinite else { return lhs.numerator < rhs.numerator }
        let (lhsNumerator, rhsNumerator, _) = Fractional.commonDenominator(lhs, rhs)
        return lhsNumerator < rhsNumerator
    }
    
}

extension Fractional: Hashable {
	public var hashValue: Int {
		return numerator.hashValue ^ denominator.hashValue
	}
}

extension Fractional {
    
    fileprivate static func commonDenominator(_ lhs: Fractional, _ rhs: Fractional) -> (lhsNumerator: Number, rhsNumberator: Number, denominator: Number) {
        let denominator = lcm(lhs.denominator, rhs.denominator)
        let lhsNumerator = lhs.numerator * (denominator / lhs.denominator)
        let rhsNumerator = rhs.numerator * (denominator / rhs.denominator)
        
        return (lhsNumerator, rhsNumerator, denominator)
    }
    
}

extension Fractional: Strideable {

    public typealias Stride = Fractional

	public func advanced(by n: Stride) -> Fractional {
		let (selfNumerator, nNumerator, commonDenominator) = Fractional.commonDenominator(self, n)
        return Fractional(selfNumerator + nNumerator, commonDenominator)
	}
	
	public func distance(to other: Fractional) -> Stride {
		return other.advanced(by: -self)
	}
}

extension Fractional : ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value as! Number)
    }
    
}

extension Fractional: Numeric {
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(source as! Number)
    }
    
    public var magnitude: Fractional<UInt> {
        var n = self.numerator
        let d = self.denominator
        if n < 0 {
            n = -1 * n
        }
        return Fractional<UInt>(UInt(n), UInt(d))
    }
    
    /// Add `lhs` and `rhs`, returning a reduced result.
    public static func +(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
        guard !lhs.isNaN && !rhs.isNaN else { return .NaN }
        guard lhs.isFinite && rhs.isFinite else {
            switch (lhs >= 0, rhs >= 0) {
            case (false, false): return -.infinity
            case (true, true):   return .infinity
            default:             return .NaN
            }
        }
        
        let (lhsNumerator, rhsNumerator, commonDenominator) = Fractional.commonDenominator(lhs, rhs)
        return Fractional(lhsNumerator + rhsNumerator, commonDenominator)
    }
    
    public static func +=(lhs: inout Fractional<Number>, rhs: Fractional<Number>) {
        lhs = lhs + rhs
    }
    
    /// Subtract `lhs` and `rhs`, returning a reduced result.
    public static func -(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
        return lhs + -rhs
    }
    public static func -=(lhs: inout Fractional<Number>, rhs: Fractional<Number>) {
        lhs = lhs - rhs
    }
    
    /// Multiply `lhs` and `rhs`, returning a reduced result.
    public static func *(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
        let swapped = (Fractional(lhs.numerator, rhs.denominator), Fractional(rhs.numerator, lhs.denominator))
        return Fractional(swapped.0.numerator * swapped.1.numerator, swapped.0.denominator * swapped.1.denominator)
    }
    
    public static func *=<Number>(lhs: inout Fractional<Number>, rhs: Fractional<Number>) {
        lhs = lhs * rhs
    }
    
    /// Divide `lhs` and `rhs`, returning a reduced result.
    public static func /(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
        return lhs * rhs.reciprocal
    }

    public static func /=(lhs: inout Fractional<Number>, rhs: Fractional<Number>) {
        lhs = lhs / rhs
    }
}

extension Fractional: SignedNumeric {

    public mutating func negate() {
        self = Fractional(-1 * self.numerator, self.denominator)
    }
    
}


extension Fractional {
	/// The reciprocal of the fraction.
	public var reciprocal: Fractional {
		get {
            return Fractional(denominator, numerator)
		}
	}
	
	/// `true` iff `self` is neither infinite nor NaN
	public var isFinite: Bool {
		return denominator != 0 
	}
	
	/// `true` iff the numerator is zero and the denominator is nonzero 
	public var isInfinite: Bool {
		return denominator == 0 && numerator != 0
	}
	
	/// `true` iff both the numerator and the denominator are zero
	public var isNaN: Bool {
		return denominator == 0 && numerator == 0
	}
	
	/// The positive infinity.
	public static var infinity: Fractional {
        return Fractional(1, 0)
	}
	
	/// Not a number.
	public static var NaN: Fractional {
        return Fractional(0, 0)
	}
}

extension Fractional: CustomStringConvertible {
	public var description: String {
		guard !isNaN else { return "NaN" }
		guard !isInfinite else { return (self >= 0 ? "+" : "-") + "Inf" }
		
		switch denominator {
		case 1: return "\(numerator)"
		default: return "\(numerator)/\(denominator)"
		}
	}
}

extension Fractional where Number == Int {
    
    public func wholeQuotient(dividingBy other: Fraction) -> Int {
        return Int(Float(self / other))
    }
    
    public func remainder(dividingBy other: Fraction) -> Fraction {
        return self - Fraction(self.wholeQuotient(dividingBy: other)) * other
    }

}

extension Double {
	/// Create an instance initialized to `value`.
	public init(_ value: Fraction) {
		self.init(Double(value.numerator) / Double(value.denominator))
	}
}

extension Float {
	/// Create an instance initialized to `value`.
	public init(_ value: Fraction) {
		self.init(Float(value.numerator) / Float(value.denominator))
	}
}

