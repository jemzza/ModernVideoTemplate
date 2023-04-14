//
//  SafeDictionary.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 3.4.2023.
//

import Foundation

final class SafeDictionary<Key, Value> where Key: Hashable {
    
    private var dictionary: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "SafeDictionaryQueue", attributes: .concurrent)
    
    var count: Int {
        var result = 0
        
        queue.sync {
            result = dictionary.count
        }
        
        return result
    }
    
    func get(forKey key: Key) -> Value? {
        var result: Value?
        
        queue.sync {
            result = dictionary[key]
        }
        
        return result
    }
    
    func set(forKey key: Key, value: Value) {
        queue.async(flags: .barrier) {
            self.dictionary[key] = value
        }
    }
    
    func removeAll(completion: (([Key: Value]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let values = self.dictionary
            self.dictionary.removeAll()
            
            DispatchQueue.main.async {
                completion?(values)
            }
        }
    }
}

extension SafeDictionary {
    
    subscript(index: Key) -> Value? {
        get {
            var result: Value?
            
            queue.sync {
                result = dictionary[index]
            }
            
            return result
        }
        
        set {
            guard let newValue = newValue else {
                return
            }
            
            queue.async(flags: .barrier) {
                self.dictionary[index] = newValue
            }
        }
    }
}
