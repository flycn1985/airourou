//
//  BoardCell.swift
//  爱肉肉
//
//  Created by isno on 16/4/7.
//  Copyright © 2016年 isno. All rights reserved.
//

import Foundation
import Eureka

public class MultiData:NSObject {
    var name:String = ""
    var fatherName:String = ""
    var subs:[MultiData] = [MultiData]()
    
    convenience init(fatherName:String, name:String) {
        self.init()
        self.fatherName = fatherName
        self.name = name
    }
    func addSub(sub:MultiData) {
        self.subs.append(sub)
    }
    
    override public var description:String {
        return self.name
    }
}

public class MultiPickerCell<T where T: Equatable> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate{
    
    lazy public var picker = UIPickerView()
    
    
    private var pickerRow : _MultiPickerRow<T>? { return row as? _MultiPickerRow<T> }
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType = .None
        picker.delegate = self
        picker.backgroundColor  = UIColor.whiteColor()
        picker.dataSource = self
    }
    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }
    
    override public var inputView : UIView? {
   
        return picker
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
           return (pickerRow?.options.count)!
        }
        let num = pickerView.selectedRowInComponent(0)
        let obj  = pickerRow?.options[num] as! MultiData
        return obj.subs.count
        
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if component == 0 {
            return pickerRow?.displayValueFor?(pickerRow?.options[row])
        }
        let num = pickerView.selectedRowInComponent(0)
        let obj  = pickerRow?.options[num] as! MultiData
        return String(obj.subs[row])
        
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            //pickerRow?.value = pickerRow?.options[row]
            detailTextLabel?.text =  pickerRow?.displayValueFor?(pickerRow?.options[row])
            pickerView.reloadComponent(1)
            
        } else {
            
            let num = pickerView.selectedRowInComponent(0)
            let first  = pickerRow?.options[num] as! MultiData
            let second = first.subs[row]

            detailTextLabel?.text = second.fatherName + "," +  second.name
            
           
        }
       
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder()
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return !row.isDisabled;
    }
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

public class _MultiPickerRow<T where T: Equatable> : Row<T, MultiPickerCell<T>>{
    
    public var options = [T]()
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class MultiPickerRow<T where T: Equatable>: _MultiPickerRow<T>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
}