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
    var queueIterator: Int
    var numQueueIteration: Int
    
    init() {
        testList = []
        queueIterator = -1
        numQueueIteration = 1
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
        queueIterator = -1
    }
    
    /**
            Retrieve, but does not remove, the head of
            the queue, or returns nil if queue is empty
     */
    func peek() -> Config? {
        if queueIterator >= 0 && queueIterator < testList.count{
            return testList[queueIterator]
        }
        return nil
    }
    
    /**
            Get the next item in the queue iterator and
            advance the cursor position
     */
    func next() -> Config?{
        if queueIterator < testList.count - 1{
            queueIterator += 1
            return testList[queueIterator]
        }
        return nil
    }
    
    /**
            Returns true if queue iterator has more elements
     */
    func hasNext() -> Bool{
        return queueIterator < testList.count - 1
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

    /**
            Update the data of the test at the top of the queue
     */
    func updateData(newData: [Int: [Double]]){
        if queueIterator >= 0 && queueIterator < testList.count{
            if var test = testList[queueIterator] as? TestConfig{
                test.testData = newData
                testList[queueIterator] = test
            }
        }
    }
    
    /**
            Update the start timestamp  of the test at the top of the queue
     */
    func updateStartTime(value: String, loopCount: Int){
        if queueIterator >= 0 && queueIterator < testList.count{
            if var test = testList[queueIterator] as? TestConfig{
                test.startTimeStamp.updateValue(value, forKey: loopCount)
                testList[queueIterator] = test
            }
        }
    }
    
    /**
            Update the end timestamp  of the test at the top of the queue
     */
    func updateEndTime(value: String, loopCount: Int){
        if queueIterator >= 0 && queueIterator < testList.count{
            if var test = testList[queueIterator] as? TestConfig{
                test.endTimeStamp.updateValue(value, forKey: loopCount)
                testList[queueIterator] = test
            }
        }
    }
    
    /**
            Increment the number of times queue has been thoroughly iterated
     */
    func incrementQueueIterationCounter(){
        self.numQueueIteration += 1
    }
    
    /**
            Get the number of times queue has been thoroughly iterated
     */
    func getQueuetIterationCounter() -> Int{
        return numQueueIteration
    }
    
    /**
            Delete test data from the test
     */
    func deleteData(fromTestAtIndex: Int, measurementNumber: Int){
        if fromTestAtIndex >= 0 && fromTestAtIndex < testList.count{
            let test = testList[fromTestAtIndex]
            if test is TestConfig{
                var testConfig = test as! TestConfig
                testConfig.testData.removeValue(forKey: measurementNumber)
                testList[fromTestAtIndex] = testConfig
            }
        }
    }
}

extension TestQueue: CustomStringConvertible{
    var description: String {
        return "\(testList)"
    }
    
    
}
