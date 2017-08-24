//
//  Defaults.swift
//  mvc-demo
//
//  Created by Roderic Linguri <linguri@digices.com>
//  Copyright © 2017 Digices LLC. All rights reserved.
//

import UIKit

class Defaults {
  
  class func object(forKey key: String) -> Any? {
    if let storedData = UserDefaults.standard.data(forKey: key) {
      if let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: storedData) {
        return unarchivedData
      }
    }
    return nil
  }
  
  class func set(object: Any, forKey key: String) {
    let dataToSave = NSKeyedArchiver.archivedData(withRootObject: object)
    UserDefaults.standard.set(dataToSave, forKey: key)
    UserDefaults.standard.synchronize()
  }
  
}
