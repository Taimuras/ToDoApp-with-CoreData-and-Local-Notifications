//
//  Item.swift
//  ToDoApp
//
//  Created by tami on 10/21/20.
//

import UIKit
// Going to Model
// Item struct
struct Item: Equatable{
    var title: String = ""
    var description: String = ""
    var done: Bool = false
    var itemIndex: Int = 0
    
    
    mutating func checked() {
        done = !done
    }
}
