//
//  Controller.swift
//  mvc-demo
//
//  Created by Roderic Linguri <linguri@digices.com>
//  Copyright © 2017 Digices LLC. All rights reserved.
//

import UIKit

class Controller: UIViewController, UITableViewDataSource, UITableViewDelegate, ModelDelegate {

  // MARK: - Properties

  let model: Model = Model.shared

  var cells: [IndexPath:Cell] = [:]

  var addButtonItem: UIBarButtonItem!

  var isAdding: Bool = false

  // MARK: - Outlets

  @IBOutlet weak var tableView: UITableView!

  // MARK: - Controller

  @objc func add() {
    self.isAdding = true
    self.model.create()
  }

  @objc func setSelected() {
    for (path,cell) in self.cells {
      if path == self.model.cursor {
        cell.setSelected(true, animated: false)
      } else {
        cell.setSelected(false, animated: false)
      }
    }
  }

  @objc func setEditable(_ editable: Bool) {
    for (_,cell) in self.cells {
      cell.titleField.isEnabled = editable
    }
  }

  // MARK: - UIViewController

  override func awakeFromNib() {
    super.awakeFromNib()
    self.model.delegate = self
    self.addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = editButtonItem
    self.navigationItem.rightBarButtonItem = addButtonItem
    self.tableView.allowsSelectionDuringEditing = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.setSelected()
    self.setEditable(false)
  }

  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    self.tableView.setEditing(editing, animated: animated)
    self.perform(#selector(self.setSelected), with: nil, afterDelay: 0.1)
    if let selectedCell = self.tableView.cellForRow(at: self.model.cursor) as? Cell {
      if editing == true {
        self.addButtonItem.isEnabled = false
        self.setEditable(true)
        selectedCell.shouldBeginEditing(sender: "Controller")
      } else {
        self.addButtonItem.isEnabled = true
        selectedCell.shouldEndEditing(sender: "Controller")
        self.setEditable(false)
      }
    }
  }

  // MARK: - UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.model.index[section].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
    cell.configure(controller: self, indexPath: indexPath)
    self.cells[indexPath] = cell
    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.model.setCursor(indexPath: indexPath)
  }

  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    self.model.move(objectAt: sourceIndexPath, to: destinationIndexPath)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      self.model.delete(objectAt: indexPath)
    }
    self.perform(#selector(self.setSelected), with: nil, afterDelay: 0.1)
  }

  // MARK: - ModelDelegate

  func modelDidSetIndex() {
    self.tableView.reloadData()
    self.perform(#selector(self.setSelected), with: nil, afterDelay: 0.1)
    if self.isAdding == true {
      self.isEditing = true
      self.isAdding = false
    }
  }

  func modelDidSetCursor() {
    self.perform(#selector(self.setSelected), with: nil, afterDelay: 0.1)
  }

}
