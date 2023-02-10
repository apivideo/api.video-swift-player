import Foundation
class MulticastDelegate<T> {

    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    func add(_ delegate: T) {
        self.delegates.add(delegate as AnyObject)
    }

    func remove(_ delegateToRemove: T) {
        for delegate in self.delegates.allObjects.reversed() where delegate === delegateToRemove as AnyObject {
            self.delegates.remove(delegate)
        }
    }

    func invoke(_ invocation: (T) -> Void) {
        for delegate in self.delegates.allObjects.reversed() {
            invocation(delegate as! T)
        }
    }
}
