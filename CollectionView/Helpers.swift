//
//  CollectionViewConstants.swift
//  Lingo
//
//  Created by Wesley Byrne on 1/27/16.
//  Copyright © 2016 The Noun Project. All rights reserved.
//

import Foundation



func delay(_ delay: TimeInterval, block: @escaping (()->Void)) {
    let mDelay = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: mDelay, execute: {
        block()
    })
}

struct Logger {

    static let logFiles = Set<String>([
//        "CollectionView",
//        "CollectionViewDocumentView",
//        "CollectionReusableView"
        ])
    
    static func verbose(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: "Verbose", file: file, funtion: function, line: line)
    }
    static func debug(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: "Debug", file: file, funtion: function, line: line)
    }
    static func error(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: "Error", file: file, funtion: function, line: line)
    }
    
    private static func log(_ message: Any, type: String, file: String, funtion: String, line: Int) {
        let fileName = file.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        guard logFiles.count == 0 || logFiles.contains(fileName) else {
            return;
        }
        print("\(fileName) @ \(line) \(type): \(message)")
    }
}

typealias log = Logger





/**
 Provides support for OSX < 10.11 and provides some helpful additions
*/
public extension IndexPath {

    
    /**
     Create an index path with a given item and section
     
     - Parameter item: An item
     - Parameter section: A section

     - Returns: An initialized index path with the item and section
     
     - Note: item and section must be >= 0

    */
    public static func `for`(item: Int = 0, section: Int) -> IndexPath {
        precondition(item >= 0, "Attempt to create an indexPath with negative item")
        precondition(section >= 0, "Attempt to create an indexPath with negative section")
        return IndexPath(indexes: [section, item])
    }

    
    public static var zero : IndexPath { return IndexPath.for(item: 0, section: 0) }
    
    
    /**
     Returns the item of the index path
    */
    public var _item: Int { return self[1] }
    
    /**
     Returns the section of the index path
     */
    public var _section: Int { return self[0] }
    public static func inRange(_ range: CountableRange<Int>, section: Int) -> [IndexPath] {
        var ips = [IndexPath]()
        for idx in range {
            ips.append(IndexPath.for(item: idx, section: section))
        }
        return ips
    }
    
    public var previous : IndexPath? {
        guard self._item >= 1 else { return nil }
        return IndexPath.for(item: self._item - 1, section: self._section)
    }
    public var next : IndexPath {
        return IndexPath.for(item: self._item + 1, section: self._section)
    }
    public var nextSection : IndexPath {
        return IndexPath.for(item: 0, section: self._section + 1)
    }
    
    var sectionCopy : IndexPath {
        return IndexPath.for(item: 0, section: self._section)
    }
    
    func with(item: Int) -> IndexPath {
        return IndexPath.for(item: item, section: self._section)
    }
    func with(section: Int) -> IndexPath {
        return IndexPath.for(item: self._item, section: section)
    }
    
    func adjustingItem(by: Int) -> IndexPath {
        return IndexPath.for(item: self._item + by, section: section)
    }
    func adjustingSection(by: Int) -> IndexPath {
        return IndexPath.for(item: self._item, section: section + by)
    }
}



/// :nodoc:
extension Comparable {
    func compare(_ other: Self) -> ComparisonResult {
        if self == other { return .orderedSame }
        if self < other { return .orderedAscending }
        return .orderedDescending
    }
}



extension Dictionary {
    
    
    func union(_ other: Dictionary<Key, Value>, overwrite: Bool = true) -> Dictionary<Key, Value> {
        var new = self
        for element in other {
            if overwrite || new[element.key] == nil {
                new[element.key] = element.value
            }
        }
        return new
    }
    
}


extension Set {
    
    
    mutating func removeOne() -> Element? {
        guard self.count > 0 else { return nil }
        return self.removeFirst()
    }
    
    
    /**
     Remove elements shared by both sets, returning the removed items
     
     - parameter set: The set of elements to remove from the receiver
     - returns: A new set of removed elements
     */
     @discardableResult mutating func remove<C : Collection>(_ set: C) -> Set<Element> where C.Iterator.Element == Element {
        var removed = Set(minimumCapacity: self.count)
        for item in set {
            if let r = self.remove(item) {
                removed.insert(r)
            }
        }
        return removed
    }
    
    func removing<C : Collection>(_ set: C) -> Set<Element> where C.Iterator.Element == Element {
        var copy = self
        copy.remove(set)
        return copy
    }
    
    /**
     Remove elements shared by both sets, returning the removed items
     
     - parameter set: The set of elements to remove from the receiver
     - returns: A new set of removed elements
     */
//    mutating func removeSet(_ set: Set) -> Set {
//        var removed = Set(minimumCapacity: self.count)
//        for item in set {
//            if let r = self.remove(item) {
//                removed.insert(r)
//            }
//        }
//        return removed
//    }
//    
//    func removingSet(_ set: Set) -> Set {
//        var newSet = Set(minimumCapacity: self.count)
//        for item in self {
//            if !set.contains(item) {
//                newSet.insert(item)
//            }
//        }
//        return newSet
//    }
}

extension CGPoint {
    
    var integral : CGPoint {
        return CGPoint(x: round(self.x), y: round(self.y))
    }
    
    public var maxAbsVelocity : CGFloat {
        return max(abs(self.x), abs(self.y))
    }
    
    func maxVelocity(_ other: CGPoint) -> CGPoint {
        let _x = abs(self.x) > abs(other.x) ? self.x : other.x
        let _y = abs(self.y) > abs(other.y) ? self.y : other.y
        return CGPoint(x: _x, y: _y)
    }
    
    func maxXY(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: max(self.x, other.x), y: max(self.y, other.y))
    }
    func maxX(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: max(self.x, other.x), y: self.y)
    }
    func maxY(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: self.x, y: max(self.y, other.y))
    }
    
        func distance(to other: CGPoint) -> CGFloat {
            let xDist = self.x - other.x
            let yDist = self.y - other.y
            return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        }
}

extension CGRect {
    var center : CGPoint {
        get { return CGPoint(x: self.midX, y: self.midY) }
        set {
            self.origin.x = newValue.x - (self.size.width/2)
            self.origin.y = newValue.y - (self.size.height/2)
        }
    }
    
    func scaled(by scale: CGFloat) -> CGRect {
        var rect = CGRect()
        rect.origin.x = self.origin.x * scale
        rect.origin.y = self.origin.y * scale
        rect.size.width = self.size.width * scale
        rect.size.height = self.size.height * scale
        return rect
    }
}




/*
    Subtract r2 from r1 along
    -------------
   |\\\\ r1 \\\\\|
   |\\\\\\\\\\\\\|
   |=============|
   !    overlap  !
   !_____________!
   I             I
   I     r2      I
   I=============I
*/

func CGRectSubtract(_ rect1: CGRect, rect2: CGRect, edge: CGRectEdge) -> CGRect {
    
    if rect2.contains(rect1) { return CGRect.zero }
    if rect2.isEmpty { return rect1 }
    if !rect1.intersects(rect2) { return rect1 }
    
    switch edge {
    case .minXEdge:
        let origin = CGPoint(x: rect2.maxX, y: rect1.origin.y)
        let size = CGSize(width: rect1.maxX - origin.x , height: rect1.size.height)
        return CGRect(origin: origin, size: size)
        
    case .maxXEdge:
        return CGRect(origin: rect1.origin, size: CGSize(width: rect2.origin.x - rect1.origin.x, height: rect1.size.height))
        
    case .minYEdge:
        let origin = CGPoint(x: rect1.origin.x, y: rect2.maxY)
        let size = CGSize(width: rect1.size.width, height: rect1.maxY - origin.y)
        return CGRect(origin: origin, size: size)
        
    case .maxYEdge:
        return CGRect(origin: rect1.origin, size: CGSize(width: rect1.size.width, height: rect2.origin.y - rect1.origin.y))
    }
}



public extension NSView {
    
    /**
     Add NSLayoutContraints to the reciever to match it'parent optionally provided insets for each side. If the view does not have a superview, no constraints are added.
     
     - parameter insets: Insets to apply to the constraints for Top, Right, Bottom, and Left.
     - returns: The Top, Right, Bottom, and Top constraint added to the view.
     */
    @discardableResult func addConstraintsToMatchParent(_ insets: EdgeInsets? = nil) -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        if let sv = self.superview {
            let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: sv, attribute: NSLayoutAttribute.top, multiplier: 1, constant: insets == nil ? 0 : insets!.top)
            let right = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: insets?.right ?? 0)
            let bottom = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: insets?.bottom ?? 0)
            let left = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: sv, attribute: NSLayoutAttribute.left, multiplier: 1, constant: insets == nil ? 0 : insets!.left)
            sv.addConstraints([top, bottom, right, left])
            self.translatesAutoresizingMaskIntoConstraints = false
            return (top, right, bottom, left)
        }
        else {
            debugPrint("Toolkit Warning: Attempt to add contraints to match parent but the view had not superview.")
        }
        return nil
    }
}



