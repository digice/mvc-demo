//
//  Model.swift
//  mvc-demo
//
//  Created by Roderic Linguri
//  Copyright © 2017 Digices LLC. All rights reserved.
//

import UIKit

protocol ModelDelegate {
  func modelDidSetIndex()
  func modelDidSetCursor()
}

class Model {
  
  // MARK: - Properties

  static let shared: Model = Model()

  var delegate: ModelDelegate?

  var index: [[String]]

  var cursor: IndexPath

  // MARK: - Model

  private init() {
    if let storedIndex = Defaults.object(forKey: "index") as? [[String]] {
      self.index = storedIndex
    } else {
      self.index = [[]]
    }
    if let storedCursor = Defaults.object(forKey: "cursor") as? IndexPath {
      self.cursor = storedCursor
    } else {
      self.cursor = IndexPath(row: 0, section: 0)
    }
  }

  func saveIndex() {
    Defaults.set(object: self.index, forKey: "index")
  }

  func saveCursor() {
    Defaults.set(object: self.cursor, forKey: "cursor")
  }

  func setCursor(indexPath: IndexPath) {
    self.cursor = indexPath
    self.saveCursor()
    if let delegate = self.delegate {
      delegate.modelDidSetCursor()
    }
  }

  func move(objectAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let objectToMove = self.index[sourceIndexPath.section].remove(at: sourceIndexPath.row)
    self.index[destinationIndexPath.section].insert(objectToMove, at: destinationIndexPath.row)
    self.saveIndex()
    self.cursor = destinationIndexPath
    self.saveCursor()
    if let delegate = self.delegate {
      delegate.modelDidSetIndex()
    }
  }

  func delete(objectAt indexPath: IndexPath) {
    let section = indexPath.section
    _ = self.index[section].remove(at: indexPath.row)
    if section == self.cursor.section {
      if self.cursor.row != 0 {
        if indexPath.row >= 0 {
          self.cursor = IndexPath(row: (self.cursor.row - 1), section: section)
          self.saveCursor()
        }
      }
    }
    self.saveIndex()
    if let delegate = self.delegate {
      delegate.modelDidSetIndex()
    }
  }

  func create() {
    self.index[self.cursor.section].insert("", at: 0)
    self.saveIndex()
    self.cursor = IndexPath(row: 0, section: self.cursor.section)
    self.saveCursor()
    if let delegate = self.delegate {
      delegate.modelDidSetIndex()
    }
  }

  func object(atIndexPath indexPath: IndexPath) -> String? {
    if indexPath.section < self.index.count {
      if indexPath.row < self.index[indexPath.section].count {
        return self.index[indexPath.section][indexPath.row]
      }
    }
    return nil
  }

  func updateObjectAtCursor(withNewTitle title: String) {
    if let object = self.object(atIndexPath: self.cursor) {
      if object != title {
        self.index[self.cursor.section][self.cursor.row] = title
      }
    }
    self.saveIndex()
    if let delegate = self.delegate {
      delegate.modelDidSetIndex()
    }
  }

}
