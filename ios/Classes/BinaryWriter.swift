import Foundation

public final class BinaryWriter : Writer {
    private static let initialSize = 1024
    private var buffer: UnsafeMutableRawPointer
    private var capacity: Int
    private var offset: Int = 0
    
    public init() {
        self.capacity = Self.initialSize
        self.buffer = UnsafeMutableRawPointer.allocate(byteCount: self.capacity, alignment: MemoryLayout<Int64>.alignment)
    }
    
    deinit {
        buffer.deallocate()
    }
    
    @inline(__always)
    private func growBufferIfNeeded(size: Int) {
        let offset = offset
        let capacity = capacity
        let requiredSize = offset + size
        
        guard requiredSize > capacity else {
            return
        }
        
        var newCapacity = capacity << 1
        
        while newCapacity < requiredSize {
            newCapacity = newCapacity << 1
        }
        
        let buffer = buffer
        let newBuffer = UnsafeMutableRawPointer.allocate(byteCount: newCapacity, alignment: MemoryLayout<Int64>.alignment)
        
        memcpy(newBuffer, buffer, offset)
        
        buffer.deallocate()
        
        self.buffer = newBuffer
        self.capacity = newCapacity
    }
    
    @inline(__always)
    private func addPaddingIfNeeded(alignment: Int) {
        let align = alignment - 1
        let offset = offset
        let remainder = offset & align
        
        guard remainder > 0 else {
            return
        }
        
        let size = alignment - remainder
        
        growBufferIfNeeded(size: size)
        (buffer + offset).initializeMemory(as: UInt8.self, repeating: 0, count: size)
        
        self.offset += size
    }
    
    @inline(__always)
    public func byte(value: UInt8) {
        growBufferIfNeeded(size: MemoryLayout<Int8>.size)
        (buffer + offset).storeBytes(of: value, as: UInt8.self)
        offset += MemoryLayout<UInt8>.size
    }
    
    @inline(__always)
    public func char(value: UInt16) {
        addPaddingIfNeeded(alignment: MemoryLayout<UInt16>.size)
        growBufferIfNeeded(size: MemoryLayout<UInt16>.size)
        (buffer + offset).storeBytes(of: value, as: UInt16.self)
        offset += MemoryLayout<UInt16>.size
    }
    
    @inline(__always)
    public func int(value: Int32) {
        addPaddingIfNeeded(alignment: MemoryLayout<Int32>.size)
        growBufferIfNeeded(size: MemoryLayout<Int32>.size)
        (buffer + offset).storeBytes(of: value, as: Int32.self)
        offset += MemoryLayout<Int32>.size
    }
    
    @inline(__always)
    public func long(value: Int64) {
        addPaddingIfNeeded(alignment: MemoryLayout<Int64>.size)
        growBufferIfNeeded(size: MemoryLayout<Int64>.size)
        (buffer + offset).storeBytes(of: value, as: Int64.self)
        offset += MemoryLayout<Int64>.size
    }
    
    @inline(__always)
    public func float(value: Float) {
        addPaddingIfNeeded(alignment: MemoryLayout<Float>.size)
        growBufferIfNeeded(size: MemoryLayout<Float>.size)
        (buffer + offset).storeBytes(of: value, as: Float.self)
        offset += MemoryLayout<Float>.size
    }
    
    @inline(__always)
    public func double(value: Double) {
        addPaddingIfNeeded(alignment: MemoryLayout<Double>.size)
        growBufferIfNeeded(size: MemoryLayout<Double>.size)
        (buffer + offset).storeBytes(of: value, as: Double.self)
        offset += MemoryLayout<Double>.size
    }
    
    @inline(__always)
    public func byteArray(value: Data) {
        value.withUnsafeBytes {bytes in
            let size = bytes.count
            growBufferIfNeeded(size: size)
            memcpy(buffer + offset, bytes.baseAddress!, size)
            offset += size
        }
    }
    
    @inline(__always)
    public func intArray(value: [Int32]) {
        addPaddingIfNeeded(alignment: MemoryLayout<Int32>.size)
        value.withUnsafeBytes {bytes in
            let size = bytes.count
            growBufferIfNeeded(size: size)
            memcpy(buffer + offset, bytes.baseAddress!, size)
            offset += size
        }
    }
    
    @inline(__always)
    public func longArray(value: [Int64]) {
        addPaddingIfNeeded(alignment: MemoryLayout<Int64>.size)
        value.withUnsafeBytes {bytes in
            let size = bytes.count
            growBufferIfNeeded(size: size)
            memcpy(buffer + offset, bytes.baseAddress!, size)
            offset += size
        }
    }
    
    @inline(__always)
    public func floatArray(value: [Float]) {
        addPaddingIfNeeded(alignment: MemoryLayout<Float>.size)
        value.withUnsafeBytes {bytes in
            let size = bytes.count
            growBufferIfNeeded(size: size)
            memcpy(buffer + offset, bytes.baseAddress!, size)
            offset += size
        }
    }
    
    @inline(__always)
    public func doubleArray(value: [Double]) {        
        addPaddingIfNeeded(alignment: MemoryLayout<Double>.size)
        value.withUnsafeBytes {bytes in
            let size = bytes.count
            growBufferIfNeeded(size: size)
            memcpy(buffer + offset, bytes.baseAddress!, size)
            offset += size
        }
    }
    
    @inline(__always)
    public func toByteArray() -> Data {
        return Data(bytes: buffer, count: offset)
    }
}
