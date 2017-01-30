
//  ResultsController.swift
//  Lingo
//
//  Created by Wesley Byrne on 1/11/17.
//  Copyright © 2017 The Noun Project. All rights reserved.
//

import Foundation
import CoreData

// Test 2

public extension Array where Element:Any {
    public func object(at index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}

public enum ResultsControllerError: Error {
    case unknown
}


public protocol CustomDisplayStringConvertible  {
    var displayDescription : String { get }
}

extension String : CustomDisplayStringConvertible {
    public var displayDescription: String { return self }
}

extension NSNumber : CustomDisplayStringConvertible {
    public var displayDescription: String { return "\(self)" }
}


public protocol ResultsController {
    
    var delegate : ResultsControllerDelegate? { get set }
    
    func numberOfSections() -> Int
    func numberOfObjects(in section: Int) -> Int
    
    // MARK: - Getting Items
    /*-------------------------------------------------------------------------------*/
    func section(for sectionIndexPath: IndexPath) -> ResultsControllerSection?
    func object(for sectionIndexPath: IndexPath) -> Any?
    func object(at indexPath: IndexPath) -> NSManagedObject?
    
    func sectionName(forSectionAt indexPath :IndexPath) -> String
    
    func performFetch() throws
}


public protocol ResultsControllerDelegate {
    func controllerWillChangeContent(controller: ResultsController)
    func controller(_ controller: ResultsController, didChangeObject object: NSManagedObject, at indexPath: IndexPath?, for changeType: ResultsControllerChangeType)
    func controller(_ controller: ResultsController, didChangeSection section: ResultsControllerSection, at indexPath: IndexPath?, for changeType: ResultsControllerChangeType)
    func controllerDidChangeContent(controller: ResultsController)
}

public protocol ResultsControllerSection {
    var object : Any? { get }
    var objects : [NSManagedObject] { get }
    var count : Int { get }
}


public enum ResultsControllerChangeType {
    case delete
    case update
    case insert(IndexPath)
    case move(IndexPath)
}




/// A set of changes for an entity with with mappings to original Indexes
struct ObjectChangeSet<Index: Hashable, Object:NSManagedObject>: CustomStringConvertible {
    
    var inserted = Set<Object>()
    var updated = IndexedSet<Index, Object>()
    var deleted = IndexedSet<Index, Object>()
    
    var description: String {
        var str = "Change Set \(Object.className()):"
        + " \(updated.count) Updated, "
        + " \(inserted.count) Inserted, "
        + " \(deleted.count) Deleted"
        return str
    }
    
    init() { }
    
    mutating func add(inserted object: Object) {
        inserted.insert(object)
    }
    
    mutating func add(updated object: Object, for index: Index) {
        self.updated.insert(object, for: index)
    }
    
    mutating func add(deleted object: Object, for index: Index) {
        self.deleted.insert(object, for: index)
    }
    
    
    mutating func reset() {
        self.inserted.removeAll()
        self.deleted.removeAll()
        self.updated.removeAll()
    }
}



