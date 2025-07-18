public final class BinarySerializer : Serializer {
    private static let NULL: UInt8 = 0x00
    private static let TRUE: UInt8 = 0x01
    private static let FALSE: UInt8 = 0x02
    private static let INT: UInt8 = 0x03
    private static let LONG: UInt8 = 0x04
    private static let DOUBLE: UInt8 = 0x05
    private static let STRING: UInt8 = 0x06
    private static let BYTE_ARRAY: UInt8 = 0x07
    private static let INT_ARRAY: UInt8 = 0x08
    private static let LONG_ARRAY: UInt8 = 0x09
    private static let FLOAT_ARRAY: UInt8 = 0x0A
    private static let DOUBLE_ARRAY: UInt8 = 0x0B
    private static let LIST: UInt8 = 0x0C
    private static let SET: UInt8 = 0x0D
    private static let MAP: UInt8 = 0x0E
    
    private static let MAX_BYTES: Int = 0xFE
    private static let MAX_CHAR: Int = 0xFF
    private static let MAX_CHAR_VALUE: Int = 0xFFFF
    
    @inline(__always)
    private static func writeSize(_ writer: Writer, _ value: Int) {
        switch value {
        case 0..<MAX_BYTES:
            writer.byte(value: UInt8(value))
        case MAX_BYTES...MAX_CHAR_VALUE:
            writer.byte(value: UInt8(MAX_BYTES))
            writer.char(value: UInt16(value))
        default:
            writer.byte(value: UInt8(MAX_CHAR))
            writer.int(value: Int32(value))
        }
    }
    
    @inline(__always)
    private static func writeByteArray(_ writer: Writer,_ value: Data) {
        writeSize(writer, value.count)
        writer.byteArray(value: value)
    }
    
    @inline(__always)
    private static func append(_ writer: Writer,_ value: Any?) {
        switch value {
        case nil:
            fallthrough
        case is NSNull:
            writer.byte(value: NULL)
        case let boolValue as Bool:
            writer.byte(value: boolValue ? TRUE : FALSE)
        case let intValue as Int8:
            writer.byte(value: INT)
            writer.int(value: Int32(intValue))
        case let intValue as Int16:
            writer.byte(value: INT)
            writer.int(value: Int32(intValue))
        case let intValue as Int32:
            writer.byte(value: INT)
            writer.int(value: intValue)
        case let intValue as Int:
            #if arch(arm64) || arch(x86_64)
            if intValue >> 31 == intValue >> 63 {
                writer.byte(value: INT)
                writer.int(value: Int32(intValue))
            } else {
                writer.byte(value: LONG)
                writer.long(value: Int64(intValue))
            }
            #else
            writer.byte(value: INT)
            writer.int(value: Int32(intValue))
            #endif
        case let intValue as Int64:
            writer.byte(value: LONG)
            writer.long(value: intValue)
        case let floatValue as Float:
            writer.byte(value: DOUBLE)
            writer.double(value: Double(floatValue))
        case let doubleValue as Double:
            writer.byte(value: DOUBLE)
            writer.double(value: doubleValue)
        case let stringValue as any StringProtocol:
            writer.byte(value: STRING)
            writeByteArray(writer, stringValue.data(using: .utf8) ?? Data(count: 1))
        case let byteArray as [UInt8]:
            writer.byte(value: BYTE_ARRAY)
            writer.byteArray(value: Data(byteArray))
        case let dataValue as Data:
            writer.byte(value: BYTE_ARRAY)
            writer.byteArray(value: dataValue)
        case let intArrayValue as [Int32]:
            writer.byte(value: INT_ARRAY)
            writer.intArray(value: intArrayValue)
        case let longArrayValue as [Int64]:
            writer.byte(value: LONG_ARRAY)
            writer.longArray(value: longArrayValue)
        case let floatArrayValue as [Float]:
            writer.byte(value: FLOAT_ARRAY)
            writer.floatArray(value: floatArrayValue)
        case let doubleArrayValue as [Double]:
            writer.byte(value: DOUBLE_ARRAY)
            writer.doubleArray(value: doubleArrayValue)
        case let arrayValue as [Any?]:
            writer.byte(value: LIST)
            arrayValue.withUnsafeBufferPointer { bufferPointer in
                let size = bufferPointer.count
                
                writeSize(writer, size)
                
                let ptr = bufferPointer.baseAddress!
                
                for i in  0..<size {
                    let value = ptr + i
                    
                    append(writer, value.pointee)
                }
            }
        case let arrayValue as Set<AnyHashable>:
            writer.byte(value: SET)
            
            let size = arrayValue.count
            
            writeSize(writer, size)
            
            for item in arrayValue {
                append(writer, item)
            }
        case let mapValue as [AnyHashable: Any?]:
            writer.byte(value: MAP)
            writeSize(writer, mapValue.count)
            
            for (key, value) in mapValue {
                append(writer, key)
                append(writer, value)
            }
            
        case let mapValue as NSDictionary:
            writer.byte(value:  MAP)
            
            let cfMap = mapValue as CFDictionary
            let count = CFDictionaryGetCount(cfMap)
            
            writeSize(writer, count)
            
            let key = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: count)
            let value = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: count)
            
            defer {
                key.deallocate()
                value.deallocate()
            }
            
            CFDictionaryGetKeysAndValues(cfMap, key, value)
            
            for i in 0..<count {
                let k: AnyObject? = Unmanaged<AnyObject>.fromOpaque(key[i]!).takeUnretainedValue()
                let v: AnyObject? = Unmanaged<AnyObject>.fromOpaque(value[i]!).takeUnretainedValue()
                
                append(writer, k)
                append(writer, v)
            }
            
        default:
            fatalError("Unsupported type for serialization: \(String(describing: type(of: value)))")
        }
    }
    
    @inline(__always)
    private static func readSize(_ reader: BinaryReader) -> Int {
        let value = Int(reader.byte())
        switch value {
        case 0..<MAX_BYTES:
            return value
        case MAX_BYTES:
            return Int(reader.char())
        default:
            return Int(reader.int())
        }
    }
    
    @inline(__always)
    private static func read(_ reader: BinaryReader) -> Any?  {
        let type = reader.byte()
        
        switch type {
        case NULL:
            return nil
        case TRUE:
            return true
        case FALSE:
            return false;
        case INT:
            return Int(reader.int())
        case LONG:
            #if arch(arm64) || arch(x86_64)
            return Int(reader.long())
            #else
            return reader.long()
            #endif
        case DOUBLE:
            return reader.double()
        case STRING:
            return reader.string(size: readSize(reader))
        case BYTE_ARRAY:
            return reader.byteArray(size: readSize(reader))
        case INT_ARRAY:
            return reader.intArray(size: readSize(reader))
        case LONG_ARRAY:
            return reader.longArray(size: readSize(reader))
        case FLOAT_ARRAY:
            return reader.floatArray(size: readSize(reader))
        case DOUBLE_ARRAY:
            return reader.doubleArray(size: readSize(reader))
        case LIST:
            let size = readSize(reader)
            var array: [Any?] = []
            
            array.reserveCapacity(size)
            
            for _ in 0..<size {
                array.append(read(reader))
            }
            
            return array
        case SET:
            let size = readSize(reader)
            var array = Set<AnyHashable>()
            
            array.reserveCapacity(size)
            
            for _ in 0..<size {
                array.insert(read(reader) as! AnyHashable)
            }
            
            return array
        case MAP:
            let size = readSize(reader)
            var map: [AnyHashable: Any?] = [:]
            
            map.reserveCapacity(size)
            
            for _ in 0..<size {
                let key = read(reader) as! AnyHashable
                map[key] = read(reader)
            }
            
            return map
        default:
            fatalError("Message corrupted")
        }
    }
    
    @inline(__always)
    public func serialize(value: Any?) -> Data {
        let writer = BinaryWriter()
        
        Self.append(writer, value)
        
        return writer.toByteArray()
    }
    
    @inline(__always)
    public func deserialize(value: Data) -> Any? {
        let reader = BinaryReader(data: value)
        
        return Self.read(reader)
    }
}
