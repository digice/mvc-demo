//
//  Cell.swift
//  mvc-demo
//
//  Created by Roderic Linguri <linguri@digices.com>
//  Copyright © 2017 Digices LLC. All rights reserved.
//

import UIKit

class Cell: UITableViewCell, UITextFieldDelegate {

  // MARK: - Properties

  let model: Model = Model.shared

  var controller: Controller!

  var indexPath: IndexPath!

  // MARK: - Outlets

  @IBOutlet weak var titleField: UITextField!

  // MARK: - Cell

  func configure(controller: Controller, indexPath: IndexPath) {
    self.controller = controller
    self.indexPath = indexPath
    if let object = model.object(atIndexPath: self.indexPath!) {
      if let field = self.titleField {
        field.text = object
      }
    }
  }

  func shouldEndEditing(sender: String) {
    if let field = self.titleField {
      if let text = field.text {
        if self.indexPath == self.model.cursor {
          if text.characters.count > 0 {
            model.updateObjectAtCursor(withNewTitle: text)
          } else {
            model.updateObjectAtCursor(withNewTitle: "Untitled Item")
          }
        }
      }
      field.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0)
    }
    if sender != "Controller" {
      self.controller.isEditing = false
    }
  }

  func shouldBeginEditing(sender: String) {
    self.titleField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.1)
  }

  // MARK: - UIView

  override func awakeFromNib() {
    super.awakeFromNib()
    self.titleField.delegate = self
  }

  // MARK: - UITableViewCell

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  // MARK: - UITextFieldDelegate

  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.model.setCursor(indexPath: self.indexPath)
    if let text = textField.text {
      if text == "Untitled Item" {
        textField.text = ""
      }
    }
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.shouldEndEditing(sender: "Cell")
    return false
  }

}
