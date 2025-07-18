import Foundation

public protocol Writer {
    func byte(value: UInt8)
    func char(value: UInt16)
    func int(value: Int32)
    func long(value: Int64)
    func float(value: Float)
    func double(value: Double)
    func byteArray(value: Data)
    func intArray(value: [Int32])
    func longArray(value: [Int64])
    func floatArray(value: [Float])
    func doubleArray(value: [Double])
    func toByteArray() -> Data
}
