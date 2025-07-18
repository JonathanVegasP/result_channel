import Foundation

public typealias ResultCallback = @convention(c) (UnsafeMutablePointer<ResultNative>?) -> Void

public final class ResultChannel {
    public static var serializer: Serializer = BinarySerializer()
    
    @inline(__always)
    public static func createResultNative(status: ResultChannelStatus, data: Any?) -> UnsafeMutablePointer<ResultNative>? {
        let serialized = serializer.serialize(value: data)
        let size = serialized.count
        
        let data = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: MemoryLayout<UInt8>.alignment).assumingMemoryBound(to: UInt8.self)
        
        _ = serialized.withUnsafeBytes { buffer in
            memcpy(data, buffer.baseAddress!, size)
        }
        
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<ResultNative>.stride, alignment: MemoryLayout<ResultNative>.alignment)
                
        let result = ptr.initializeMemory(as: ResultNative.self, to: ResultNative(status: status, data: data, size: Int32(size)))
        
        return result
    }
    
    private let resultCallback: ResultCallback
    
    public init(resultCallback: @escaping ResultCallback) {
        self.resultCallback = resultCallback
    }
    
    @inline(__always)
    public func success(_ value: Any?) {
        let result = Self.createResultNative(status: ResultChannelStatusOk, data: value)
        
        resultCallback(result)
    }
    
    @inline(__always)
    public func failure(_ value: Any?) {
        let result = Self.createResultNative(status: ResultChannelStatusError, data: value)
        
        resultCallback(result)
    }
}

@_cdecl("flutter_result_channel_free_pointer")
public func flutterResultChannelFreePointer(pointer: UnsafeMutableRawPointer?) {
    pointer?.deallocate()
}
