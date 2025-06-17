//
//  NotesModel.swift
//  VITTY
//
//  Created by Rujin Devkota on 3/27/25.
//

import Foundation


struct CreateNoteModel:  Codable {
   
    let noteName: String
    let userName: String
    let courseId: String
    let courseName: String
    let noteContent: String
    let createdAt: Date
    
    init( noteName: String, userName: String, courseId: String, courseName: String, noteContent: String, createdAt: Date = Date()) {
        self.noteName = noteName
        self.userName = userName
        self.courseId = courseId
        self.courseName = courseName
        self.noteContent = noteContent
        self.createdAt = createdAt
    }
}
