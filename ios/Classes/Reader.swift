import Foundation

public protocol Reader {
    func byte() -> UInt8
    func char() -> UInt16
    func int() -> Int32
    func long() -> Int64
    func float() -> Float
    func double() -> Double
    func string(size: Int) -> String
    func byteArray(size: Int) -> Data
    func intArray(size: Int) -> [Int32]
    func longArray(size: Int) -> [Int64]
    func floatArray(size: Int) -> [Float]
    func doubleArray(size: Int) -> [Double]
}
