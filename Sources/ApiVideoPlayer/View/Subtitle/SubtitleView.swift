//
//  File.swift
//  
//
//  Created by Romain Petit on 08/06/2022.
//

import Foundation
import UIKit
import AVFoundation

@available(iOS 14.0, *)
class SubtitleView: UIView, UITableViewDelegate, UITableViewDataSource {
    private var selectedRow = 0
    private var subtitles : [Subtitle] = [Subtitle(language: "Off", code: nil, isSelected: false)]
    private var vodControls: VodControls
    private var tableview = UITableView()
    private let cellReuseIdentifier = "cell"
    
    public init(frame: CGRect,_ controls: VodControls) {
        self.vodControls = controls
        super.init(frame: frame)
        self.layer.cornerRadius = 15
        tableview.layer.cornerRadius = 15
        tableview.frame = CGRectMake(0, 0, frame.width, frame.height)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.addSubview(tableview)
        getSubtitlesFromVideo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func dismissView(){
        if let viewWithTag = self.viewWithTag(101){
            viewWithTag.removeFromSuperview()
        }else{
            print("something went wrong when removing the view")
            return
        }
    }
    
    private func selectSubtitle(_ language: String? = nil){
        if let group = vodControls.playerController.avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            if(language == nil){
                turnOffSubtitle()
            }else{
                let locale = Locale(identifier: language!)
                let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                if let option = options.first {
                    vodControls.playerController.avPlayer.currentItem!.select(option, in: group)
                }
            }
        }
    }
    
    private func turnOffSubtitle(){
        if let group = vodControls.playerController.avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            vodControls.playerController.avPlayer.currentItem!.select(nil, in: group)
        }
    }
    
    private func getSubtitlesFromVideo(){
        let current = getCurrentLocaleSubtitle()
        if let group = vodControls.playerController.avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            for option in group.options {
                var sub = Subtitle(language: option.displayName, code: option.extendedLanguageTag!)
                if(current?.languageCode == sub.code){
                    sub.isSelected = true
                }
                subtitles.append(sub)
            }
        }
    }
    
    private func getCurrentLocaleSubtitle() -> Locale?{
        var locale: Locale?
        if let playerItem = vodControls.playerController.avPlayer.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
            let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
            locale = selectedOption?.locale
        }
        if(locale == nil){
            subtitles[0].isSelected = true
        }
        return locale
    }
    
    
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subtitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell
        var content = cell.defaultContentConfiguration()
        content.text = subtitles[indexPath.item].language
        if(subtitles[indexPath.row].isSelected){
            cell.accessoryType = .checkmark
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedSubtitleRow = subtitles[indexPath.row]
        
        if selectedSubtitleRow.isSelected{
            return
        }
        if let previousCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: indexPath.section)){
            subtitles[selectedRow].isSelected.toggle()
            previousCell.accessoryType = .none
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            subtitles[indexPath.row].isSelected.toggle()
            cell.accessoryType = .checkmark
        }

        selectedRow = indexPath.row
        selectSubtitle(subtitles[indexPath.row].code)
        dismissView()
    }
    
}



