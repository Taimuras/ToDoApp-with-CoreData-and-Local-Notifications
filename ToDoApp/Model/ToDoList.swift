//
//  ToDoList.swift
//  ToDoApp
//
//  Created by tami on 10/23/20.
//

import UIKit


class ToDoList{
    var todos: [Item] = []
    var savingArray: [String] = []
   
    var filteredItems: [Item]!
    
    
    let defaults = UserDefaults.standard
    init() {
        
    }
    
    func castingTo(array: [Item]) -> [String] {
        for item in todos{
            savingArray.append(item.title)
            savingArray.append(item.description)
            if item.done == true {
                savingArray.append("True")
            } else if item.done == false {
                savingArray.append("False")
            }
            savingArray.append(String(item.itemIndex))
        }
        
        return savingArray
    }
    
    func gettingData(array: [String]) -> [Item] {
        
        for i in stride(from: 0, to: array.count - 1, by: 4) {
            var item = Item()
            item.title = array[i]
            item.description = array[i + 1]
            if array[i + 2] == "True" {
                item.done = true
            }else if array[i + 2] == "False"{
                item.done = false
            }
            item.itemIndex = Int(array[i + 3])!
            todos.append(item)
        }
        
        
        return todos
    }
    
    func update(){
            savingArray.removeAll()
            defaults.removeObject(forKey: "ToDoList")
            savingArray = castingTo(array: todos)
            defaults.setValue(savingArray, forKey: "ToDoList")
    }

  
}
