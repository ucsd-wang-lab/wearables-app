//
//  TestQueue.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 10/7/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import Foundation

class TestQueue{
    
    var testList: [Config]
    var currentIndex: Int
    
    init() {
        testList = []
        currentIndex = 0
    }
    
    /**
            Add a new Test to the queue
     */
    func enqueue(newTest: Config){
        testList.append(newTest)
    }
    
    /**
            Removes and returns the next Test in the queue, if any
     */
    func dequeue() -> Config?{
        if testList.count == 0{
            return nil
        }
        return testList.removeFirst()
    }
    
    /**
            Rebase the iterator to the start of the queue
     */
    func rebase(){
        currentIndex = 0
    }
    
    /**
            Get the next item in the queue iterator
     */
    func next() -> Config?{
        if currentIndex < testList.count{
            let test = testList[currentIndex]
            currentIndex += 1
            return test
        }
        return nil
    }
    
    /**
            Returns true if queue iterator has more elements
     */
    func hasNext() -> Bool{
        return currentIndex + 1 < testList.count
    }
    
    /**
            Get the first Test in the queue
     */
    func getFirst() -> Config?{
        if testList.count > 0{
            return testList[0]
        }
        return nil
    }
    
    /**
            Returns the Test at the sepcied index
     */
    func get(index i: Int) -> Config?{
        if i >= testList.count{
            return nil
        }
        return testList[i]
    }
    
    /**
            Remove a Test from the specified index, if index is valid.
            Otherwise nothing happens
     */
    func remove(at index: Int){
        if index >= 0 && index < testList.count{
            testList.remove(at: index)
        }
    }
    
    /**
            Exchange the test at index i with the test as index j. Returns True
            if swap successfull, False otherwise
     */
    func swap(fromIndex i: Int, toIndex j: Int) -> Bool{
        if i < testList.count && j < testList.count && i >= 0 && j >= 0{
            testList.swapAt(i, j)
            return true
        }
        return false
    }
    
    /**
            Returns the number of Test in the queue
     */
    func size() -> Int{
        return testList.count
    }
    
    /**
            Check if the queue is empty
     */
    func isEmpty() -> Bool{
        return testList.count == 0
    }
    
    /**
            Enable indexing into the queue
     */
    subscript(index: Int) -> Config {
        get{
            return testList[index]
        }
        set(newValue){
            testList[index] = newValue
        }
    }

}

extension TestQueue: CustomStringConvertible{
    var description: String {
        return "\(testList)"
    }
    
    
}
