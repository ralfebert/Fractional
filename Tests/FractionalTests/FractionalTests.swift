// © 2015-2018 Jaden Geller, Brian Tiger Chow, Ralf Ebert
// License: https://opensource.org/licenses/MIT

import XCTest
import Fractional

class FractionalTests: XCTestCase {
    
    func testReduce() {
        let f68 = Fraction(6, 8)
        XCTAssertEqual(3, f68.numerator)
        XCTAssertEqual(4, f68.denominator)
        XCTAssertEqual(Fraction(3, 4), f68)
    }
    
    func testNegativeDenominator() {
        let f68 = Fraction(-3, -4)
        XCTAssertEqual(3, f68.numerator)
        XCTAssertEqual(4, f68.denominator)
    }
    
    func testLiteral() {
        XCTAssertEqual(Fraction(3, 1), 3 as Fraction)
    }
    
    func testReciprocal() {
        XCTAssertEqual(Fraction(4, 3), Fraction(3, 4).reciprocal)
    }
    
    func testDivision() {
        XCTAssertEqual(
            Fraction(1, 4),
            Fraction(1, 8) / Fraction(1, 2))
    }
    
    func testMultiply() {
        XCTAssertEqual(
            Fraction(1, 16),
            Fraction(1, 8) * Fraction(1, 2))
    }

    func testComparable() {
        XCTAssertEqual(3/4 as Fraction, 3/4 as Fraction)
        XCTAssertTrue((5/4 as Fraction) > (3/4 as Fraction))
        XCTAssertTrue((2/4 as Fraction) < (3/4 as Fraction))
    }
    
    func testRange() {
        let range = (2/4 as Fraction)..<(5/4 as Fraction)
        
        XCTAssertFalse(range.contains(1/4 as Fraction))
        XCTAssertTrue(range.contains(2/4 as Fraction))
        XCTAssertTrue(range.contains(3/4 as Fraction))
        XCTAssertFalse(range.contains(5/4 as Fraction))
    }
    
    func testStride() {
        
        XCTAssertEqual([1/4 as Fraction, 1/2 as Fraction, 3/4 as Fraction, 1 as Fraction], Array(stride(from: 1/4 as Fraction, to: 5/4 as Fraction, by: 1/4 as Fraction)))
        
    }
    
    func testDescription() {
        XCTAssertEqual("4", String(describing: 4 as Fraction))
        XCTAssertEqual("1/2", String(describing: 2/4 as Fraction))
    }
    
    func testMagnitude() {
        
        let f = Fractional<Int>(-3, 4)
        let fu : Fractional<UInt> = f.magnitude
        
        XCTAssertEqual(fu, Fractional<UInt>(3, 4))
        
    }

    func testNaN() {
        XCTAssertEqual(Fraction.NaN, 0/0 as Fraction)
        XCTAssertEqual(Fraction.NaN, -1/0 + 1/0 as Fraction)
        XCTAssertEqual(Fraction.NaN, 1/0 + -1/0 as Fraction)
        XCTAssertEqual(Fraction.NaN, 1/0 + .NaN as Fraction)
        XCTAssertEqual(Fraction.NaN, 1/0 * .NaN as Fraction)
    }
    
    func testInfinity() {
        XCTAssertEqual(Fraction.infinity, 1/0 as Fraction)
        XCTAssertEqual(-Fraction.infinity, -1/0 as Fraction)
        XCTAssertEqual(Fraction.infinity, 1/0 + 1/0 as Fraction)
        XCTAssertEqual(-Fraction.infinity, -1/0 + -1/0 as Fraction)
        XCTAssertEqual(Fraction.infinity, 1/0 * 1/0 as Fraction)
        XCTAssertEqual(-Fraction.infinity, -1/0 * 1/0 as Fraction)
        XCTAssertEqual(Fraction.infinity, -1/0 * -1/0 as Fraction)
    }
    
    func testMath() {
        XCTAssertEqual(3/4 as Fraction, 1/2 + 1/4 as Fraction)
        XCTAssertEqual(1 as Fraction, 3/4 * (3/4 as Fraction).reciprocal)

        XCTAssertEqual(5/2 as Fraction, 1/4 * 10 as Fraction)
        XCTAssertEqual(1/2 as Fraction, (1/4) / (1/2) as Fraction)
    }
    
    func testPow() {
        func pow(_ base: Fraction, _ exponent: Int) -> Fraction {
            var result: Fraction = 1
            for _ in 1...abs(exponent) {
                result *= base
            }
            return exponent >= 0 ? result : result.reciprocal
        }
        
        XCTAssertEqual(1/8 as Fraction, pow(1/2, 3))
        XCTAssertEqual(9 as Fraction, pow(1/3, -2))
    }
    
    func testToFloatingPoint() {
        XCTAssertEqual(0.25, Float(1/4 as Fraction))
        XCTAssertEqual(1/3, Double(1/3 as Fraction))
    }
    
    func testCodeable() throws {
        let str = "{\"numerator\":3,\"denominator\":4}"
        XCTAssertEqual(str, String(data: try JSONEncoder().encode(3/4 as Fraction), encoding: .utf8))
        XCTAssertEqual(3/4 as Fraction, try JSONDecoder().decode(Fraction.self, from: str.data(using: .utf8)!))
    }
    
}
