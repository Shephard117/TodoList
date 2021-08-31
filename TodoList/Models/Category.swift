//
//  Category.swift
//  TodoList
//
//  Created by Дмитрий Скоробогаты on 30.08.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String?
    var items = List<Item>()
}
