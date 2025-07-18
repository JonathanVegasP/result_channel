import Foundation

public protocol Serializer {
    func serialize(value: Any?) -> Data
    
    func deserialize(value: Data) -> Any?
}
