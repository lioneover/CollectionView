//
//  IndexedSet.swift
//  CollectionView
//
//  Created by Wes Byrne on 1/20/17.
//  Copyright © 2017 Noun Project. All rights reserved.
//

import Foundation




struct IndexedSet<Index: Hashable, Object: Hashable> : Sequence {
    
    private var byObject = [Object:Index]()
    private var byIndex = [Index:Object]()
    
    
    func object(for indexPath: Index) -> Object? {
        return byIndex[indexPath]
    }
    func indexPath(for object: Object) -> Index? {
        return byObject[object]
    }
    
    var count : Int {
        return byObject.count
    }
    
    
    func contains(_ object: Object) -> Bool {
        return byObject[object] != nil
    }
    func contains(_ index: Index) -> Bool {
        return byIndex[index] != nil
    }
    
    
    mutating func insert(_ object: Object, for index: Index) {
        
        if let ip = byObject.removeValue(forKey: object) {
            byIndex.removeValue(forKey: ip)
        }
        
        byObject[object] = index
        byIndex[index] = object
    }
    
    mutating func remove(_ index: Index) -> Object? {
        guard let object = byIndex.removeValue(forKey: index) else {
            return nil
        }
        byObject.removeValue(forKey: object)
        return object
    }
    mutating func remove(_ object: Object) -> Index? {
        guard let index = byObject.removeValue(forKey: object) else {
            return nil
        }
        byIndex.removeValue(forKey: index)
        return index
    }
    
    mutating func removeAll() {
        byObject.removeAll()
        byIndex.removeAll()
    }
    
    typealias Iterator = AnyIterator<(index: Index, object: Object)>
    func makeIterator() -> Iterator {
        var iterator = byIndex.makeIterator()
        return AnyIterator {
            return iterator.next()
        }
    }
}












struct OrderedSet<Element: Hashable> : ExpressibleByArrayLiteral, Collection {
    
    fileprivate var _map = [Element:Int]()
    fileprivate var _data = [Element]()
    
    
    init() { }
    
    init<C : Collection where C.Iterator.Element == Element>(elements: C) {
        for (idx, e) in elements.enumerated() {
            guard _map[e] == nil else {
                continue
            }
            _data.append(e)
            _map[e] = idx
        }
    }
    
    init(arrayLiteral elements: Element...) {
        for (idx, e) in elements.enumerated() {
            guard _map[e] == nil else {
                continue
            }
            _data.append(e)
            _map[e] = idx
        }
    }
    
    
    
    
    
    var startIndex: Int { return _data.startIndex }
    var endIndex: Int { return _data.endIndex }
    
    func index(after i: Int) -> Int {
        return _data.index(after: i)
    }
    
    subscript(index: Int) -> Element {
        return _data[index]
    }
    
    var count : Int { return _data.count }
    func contains(_ object: Element) -> Bool{
        return _map[object] != nil
    }
    
    func index(for object: Element) -> Int? {
        return _map[object]
    }
    
    func object(at index: Int) -> Element {
        return _data[index]
    }
    
    fileprivate mutating func _remap(startingAt index: Int) {
        guard index < _data.count else { return }
        for idx in index..<_data.count {
            self._map[_data[idx]] = idx
        }
    }
    
    
    // MARK: - Inserting & Removing
    /*-------------------------------------------------------------------------------*/
    
    
    
    mutating func remove(at index: Int) -> Element {
        let e = self._data.remove(at: index)
        _map.removeValue(forKey: e)
        _remap(startingAt: index)
        return e
    }
    
    mutating func remove(_ object: Element) -> Int? {
        guard let index = self.index(for: object) else { return nil }
        remove(at: index)
        return index
    }
    
    mutating func append(_ object: Element) -> Bool {
        guard !self.contains(object) else { return false }
        _data.append(object)
        _map[object] = _data.count - 1
        return true
    }
    
    public mutating func append<C : Collection where C.Iterator.Element == Element>(contentsOf newElements: C) {
        for e in newElements {
            self.append(e)
        }
    }
    
    mutating func insert(_ object: Element, at index: Int) -> Bool {
        guard !self.contains(object) else { return false }
        self._data.insert(object, at: index)
        _remap(startingAt: index)
        return true
    }
    
    public mutating func insert<C : Collection where C.Iterator.Element == Element>(contentsOf newElements: C, at index: Int) -> Set<Element> {
        var inserted = Set<Element>()
        for (idx, e) in newElements.enumerated() {
            if !self.contains(e) {
                self._data.insert(e, at: index + idx)
                inserted.insert(e)
            }
        }
        if inserted.count > 0 {
            self._remap(startingAt: index)
        }
        return inserted
    }
    
    
    
    mutating func removeAll(keepingCapacity keep: Bool = false) {
        _data.removeAll(keepingCapacity: keep)
        _map.removeAll(keepingCapacity: keep)
    }
    
}

extension OrderedSet where Element:AnyObject {
    
    mutating func insert(_ object: Element, using sortDescriptors: [NSSortDescriptor]) -> Int {
        
        _ = self.remove(object)
        
        if sortDescriptors.count > 0 {
            for (idx, element) in self.enumerated() {
                if sortDescriptors.compare(object, to: element) == .orderedAscending {
                    self.insert(object, at: idx)
                    return idx
                }
            }
        }
        self.append(object)
        return self.count - 1
    }
    
    mutating func insert<C : Collection where C.Iterator.Element == Element>(contentsOf newElements: C, using sortDescriptors: [NSSortDescriptor]) {
        
        var _fInsert = -1
        for e in newElements {
            _ = self.remove(e)
            let idx = self._data.insert(e, using: sortDescriptors)
            if idx < _fInsert || _fInsert == -1 {
                _fInsert = idx
            }
        }
        
        if _fInsert > -1 {
            self._remap(startingAt: _fInsert)
        }
    }
    
    
    
    mutating func sort(using sortDescriptors: [NSSortDescriptor]) {
        guard sortDescriptors.count > 0 else { return }
        
        self._data.sort(using: sortDescriptors)
        self._map.removeAll(keepingCapacity: true)
        for (idx, obj) in self._data.enumerated() {
            self._map[obj] = idx
        }
    }
    
    func sorting(by sortDescriptors: [NSSortDescriptor]) -> OrderedSet<Element> {
        var new = self
        guard sortDescriptors.count > 0 else { return new }
        new.sort(using: sortDescriptors)
        return new
    }
    
}






