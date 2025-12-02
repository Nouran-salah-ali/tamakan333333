//
//  RecordingModel.swift
//  تمكّن
//
//  Created by nouransalah on 08/06/1447 AH.
//



struct RecordingModel: Codable {
    var id: Int?
    var recordname: String?
    var duration: String?
    var date: String?
    var transcript: String?
    var audiofile: String?
}

enum StutteringTypes: String , Codable{
       case repetition
       case prolongation
       case block
}

