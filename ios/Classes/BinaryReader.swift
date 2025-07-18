import Foundation

public final class BinaryReader : Reader {
    private let baseAddress: UnsafeRawPointer
    private var position: Int = 0
    private let size: Int
    private let data: Data
    
    public init(data: Data) {
        self.data = data
        self.size = data.count
        self.baseAddress = data.withUnsafeBytes { $0.baseAddress! }
    }
    
    @inline(__always)
    private func readPadding(alignment: Int) {
        let align = alignment - 1
        position = (position + align) & ~align
    }
    
    @inline(__always)
    public func byte() -> UInt8 {
        let value = (baseAddress + position).load(as: UInt8.self)
        position += MemoryLayout<UInt8>.size
        return value
    }
    
    @inline(__always)
    public func char() -> UInt16 {
        readPadding(alignment: MemoryLayout<UInt16>.size)
        let value = (baseAddress + position).load(as: UInt16.self)
        position += MemoryLayout<UInt16>.size
        return value
    }
    
    @inline(__always)
    public func int() -> Int32 {
        readPadding(alignment: MemoryLayout<Int32>.size)
        let value = (baseAddress + position).load(as: Int32.self)
        position += MemoryLayout<Int32>.size
        return value
    }
    
    @inline(__always)
    public func long() -> Int64 {
        readPadding(alignment: MemoryLayout<Int64>.size)
        let value = (baseAddress + position).load(as: Int64.self)
        position += MemoryLayout<Int64>.size
        return value
    }
    
    @inline(__always)
    public func float() -> Float {
        readPadding(alignment: MemoryLayout<Float>.size)
        let value = (baseAddress + position).load(as: Float.self)
        position += MemoryLayout<Float>.size
        return value
    }
    
    @inline(__always)
    public func double() -> Double {
        readPadding(alignment: MemoryLayout<Double>.size)
        let value = (baseAddress + position).load(as: Double.self)
        position += MemoryLayout<Double>.size
        return value
    }
    
    @inline(__always)
    public func string(size: Int) -> String {
        let bytes = byteArray(size: size)
        return String(data: bytes, encoding: .utf8) ?? ""
    }
    
    @inline(__always)
    public func byteArray(size: Int) -> Data {
        let ptr = baseAddress + position
        let value = Data(bytes: ptr, count: size)
        position += size
        return value
    }
    
    @inline(__always)
    public func intArray(size: Int) -> [Int32] {
        readPadding(alignment: MemoryLayout<Int32>.size)
        let ptr = baseAddress + position
        let byteSize = size << 2
        let value = Array<Int32>(unsafeUninitializedCapacity: size) {buffer, initialSize in
            memcpy(buffer.baseAddress!, ptr, byteSize)
            initialSize = size
        }
        position += byteSize
        return value
    }
    
    @inline(__always)
    public func longArray(size: Int) -> [Int64] {
        readPadding(alignment: MemoryLayout<Int64>.size)
        let ptr = baseAddress + position
        let byteSize = size << 3
        let value = Array<Int64>(unsafeUninitializedCapacity: size) {buffer, initialSize in
            memcpy(buffer.baseAddress!, ptr, byteSize)
            initialSize = size
        }
        position += byteSize
        return value
    }
    
    @inline(__always)
    public func floatArray(size: Int) -> [Float] {
        readPadding(alignment: MemoryLayout<Float>.size)
        let ptr = baseAddress + position
        let byteSize = size << 2
        let value = Array<Float>(unsafeUninitializedCapacity: size) {buffer, initialSize in
            memcpy(buffer.baseAddress!, ptr, byteSize)
            initialSize = size
        }
        position += byteSize
        return value
    }
    
    @inline(__always)
    public func doubleArray(size: Int) -> [Double] {
        readPadding(alignment: MemoryLayout<Double>.size)
        let ptr = baseAddress + position
        let byteSize = size << 3
        let value = Array<Double>(unsafeUninitializedCapacity: size) {buffer, initialSize in
            memcpy(buffer.baseAddress!, ptr, byteSize)
            initialSize = size
        }
        position += byteSize
        return value
    }
}
