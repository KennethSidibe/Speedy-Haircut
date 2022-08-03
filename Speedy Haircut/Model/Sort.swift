//
//  Sort.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-05.
//

import Foundation

class QuickSort {
    
    func sortQuick<Element:Comparable> (array: inout Array<Element>) {
        
        let size = array.count - 1
        
        quickSortThree(arraySort: &array, low: 0, high: size)
        
    }
    
    private func quickSortThree<Element:Comparable> (arraySort: inout Array<Element>, low:Int, high: Int){
        
        if(high == low + 1){
            
            if (arraySort[low] > arraySort[high]) {
                arraySort.swapAt(low, high)
            }
            
        }
        
        if (low >= high){
            //
        }
        
        if (low < high) {
            
            var (smaller, larger) = partitionThree(array: &arraySort, low: low, high: high)
            
            larger = larger + 1
            smaller = smaller - 1
            
            quickSortThree(arraySort: &arraySort, low: low, high: smaller)
            
            quickSortThree(arraySort: &arraySort, low: larger, high: high)
            
        }
        
        
    }
    
    private func partitionThree<Element:Comparable> (array: inout Array<Element>, low:Int, high: Int) -> (Int, Int){
        
        let pivot = array[low]
        
        var smaller = low
        var equal = low
        var larger = high
        
        while (equal <= larger) {
            
            if(array[equal] < pivot){
                
                array.swapAt(equal, smaller)
                
                equal += 1
                smaller += 1
            }
            
            else if(array[equal] > pivot){
                array.swapAt(equal, larger)
                larger -= 1
            }
            
            else {
                equal += 1
            }
            
        }
        
        return (smaller, larger)
        
    }
    
}
