import Foundation

public typealias ResultCallback = @convention(c) (UnsafeMutablePointer<ResultNative>?) -> Void

public final class ResultChannel {
    public static var serializer: Serializer = BinarySerializer()
    
    private let resultCallback: ResultCallback
    
    public init(resultCallback: @escaping ResultCallback) {
        self.resultCallback = resultCallback
    }
    
    public func success(_ value: Any?) {
        let serialized = Self.serializer.serialize(value: value)
        let size = serialized.count
        
        let data = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: MemoryLayout<UInt8>.alignment).assumingMemoryBound(to: UInt8.self)
        
        _ = serialized.withUnsafeBytes { buffer in
            memcpy(data, buffer.baseAddress!, size)
        }
        
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<ResultNative>.stride, alignment: MemoryLayout<ResultNative>.alignment)
                
        let result = ptr.initializeMemory(as: ResultNative.self, to: ResultNative(status: ResultChannelStatusOk, data: data, size: Int32(size)))
        
        resultCallback(result)
    }
    
    public func failure(_ value: Any?) {
        let serialized = Self.serializer.serialize(value: value)
        let size = serialized.count
        
        let data = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: MemoryLayout<UInt8>.alignment).assumingMemoryBound(to: UInt8.self)
        
        _ = serialized.withUnsafeBytes { buffer in
            memcpy(data, buffer.baseAddress!, size)
        }
        
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<ResultNative>.stride, alignment: MemoryLayout<ResultNative>.alignment)
                
        let result = ptr.initializeMemory(as: ResultNative.self, to: ResultNative(status: ResultChannelStatusError, data: data, size: Int32(size)))
        
        resultCallback(result)
    }
}

@_cdecl("flutter_result_channel_free_pointer")
public func flutterResultChannelFreePointer(pointer: UnsafeMutableRawPointer?) {
    pointer?.deallocate()
}
