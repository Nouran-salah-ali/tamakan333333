//
//  RecordingModel.swift
//  تمكّن
//
//  Created by nouransalah on 08/06/1447 AH.
//
import SwiftUI
import SwiftData
//need init
@Model
class RecordingModel: Identifiable {
    //var id:UUID
    @Attribute(.unique) var id: UUID
    var recordname: String
    var duration: Double
    var date: Date
    var transcript: String
    var audiofile: URL
    //i have to intilise all data i can not init some of data
    init(recordname: String, duration: Double, date: Date, transcript: String, audiofile: URL) {
        self.id = UUID()
        self.recordname = recordname
        self.duration = duration
        self.date = date
        self.transcript = transcript
        self.audiofile = audiofile
    }
    
    
}//class

enum StutteringTypes: String , Codable{
       case repetition
       case prolongation
       case block
}

