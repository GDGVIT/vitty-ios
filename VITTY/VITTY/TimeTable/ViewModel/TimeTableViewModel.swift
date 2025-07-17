//
//  TimeTableViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation
import OSLog
import SwiftData
import Network
import SwiftUI

public enum Stage {
    case loading
    case error
    case data
    case empty
}

extension TimeTableView {
    @Observable
    class TimeTableViewModel {
        
        var timeTable: TimeTable?
        var stage: Stage = .loading
        var lectures = [Lecture]()
        var dayNo = Date.convertToMondayWeek()
        var isEmpty: Bool = false
        
        private var networkMonitor = NetworkMonitor()
        
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: TimeTableViewModel.self)
        )
        
        private var notificationObserver: NSObjectProtocol?
        
        init() {
            setupNotificationObserver()
        }
        
        deinit {
            if let observer = notificationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        private func setupNotificationObserver() {
            notificationObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TimetableDidChange"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.forceRefreshCurrentDay()
                }
            }
        }

        private func forceRefreshCurrentDay() {
            logger.info("Forcing refresh of current day due to timetable change")
            
            changeDay()
            
            let currentStage = stage
            stage = .loading
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.stage = currentStage
            }
        }
      
        @MainActor
        func refreshFromDatabase(_ updatedTimeTable: TimeTable?) {
            logger.info("Refreshing from database")
            
            guard let updatedTimeTable = updatedTimeTable else {
                self.timeTable = nil
                self.lectures = []
                self.stage = .empty
                logger.error("No updated timetable provided")
                return
            }
            
            
            if isTimeTableEmpty(updatedTimeTable) {
                self.timeTable = updatedTimeTable
                self.lectures = []
                self.stage = .empty
                logger.info("Timetable is empty")
                return
            }
            
            self.timeTable = updatedTimeTable
            changeDay()
            self.stage = .data
            
            logger.info("Timetable refreshed from database successfully")
        }
        
       
        private func isTimeTableEmpty(_ timeTable: TimeTable) -> Bool {
            return timeTable.monday.isEmpty &&
                   timeTable.tuesday.isEmpty &&
                   timeTable.wednesday.isEmpty &&
                   timeTable.thursday.isEmpty &&
                   timeTable.friday.isEmpty &&
                   timeTable.saturday.isEmpty &&
                   timeTable.sunday.isEmpty
        }
        
        func changeDay() {
            guard let timeTable = timeTable else {
                self.lectures = []
                return
            }
            
            switch dayNo {
            case 0: self.lectures = timeTable.monday
            case 1: self.lectures = timeTable.tuesday
            case 2: self.lectures = timeTable.wednesday
            case 3: self.lectures = timeTable.thursday
            case 4: self.lectures = timeTable.friday
            case 5: self.lectures = timeTable.saturday
            case 6: self.lectures = timeTable.sunday
            default: self.lectures = []
            }
        }
        
        // MARK: - Local First Load Implementation
        @MainActor
        func loadTimeTable(
            existingTimeTable: TimeTable?,
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            logger.info("Starting local-first timetable loading process")
            
            if let existingTimeTable = existingTimeTable {
                logger.info("Found local timetable data - checking if empty")
                
               
                if isTimeTableEmpty(existingTimeTable) {
                    self.timeTable = existingTimeTable
                    self.lectures = []
                    self.stage = .empty
                    logger.info("Local timetable is empty")
                    return
                }
                
                useLocalData(existingTimeTable: existingTimeTable)
                return
            }
            
            logger.info("No local timetable found - fetching from API")
            stage = .loading
            
            if !username.isEmpty && !authToken.isEmpty {
                await fetchAndSaveFromAPI(
                    username: username,
                    authToken: authToken,
                    context: context
                )
            } else {
                logger.error("No credentials available for API fetch")
                stage = .error
            }
        }
        
        // MARK: - Use Local Data
        @MainActor
        private func useLocalData(existingTimeTable: TimeTable) {
            logger.info("Using local timetable data")
            self.timeTable = existingTimeTable
            changeDay()
            stage = .data
        }
        
        // MARK: - Fetch from API and Save to Local Storage
        @MainActor
        private func fetchAndSaveFromAPI(
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            do {
                logger.info("Fetching timetable from API")
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                
               
                if isTimeTableEmpty(remoteTimeTable) {
                    logger.info("API returned empty timetable")
                    self.timeTable = remoteTimeTable
                    self.lectures = []
                    self.stage = .empty
                    
                  
                    await saveToLocalStorage(
                        newTimeTable: remoteTimeTable,
                        context: context
                    )
                    return
                }
                
               
                await saveToLocalStorage(
                    newTimeTable: remoteTimeTable,
                    context: context
                )
              
                self.timeTable = remoteTimeTable
                changeDay()
                stage = .data
                
                logger.info("Successfully fetched and saved timetable from API")
                
            } catch {
                logger.error("Failed to fetch from API: \(error.localizedDescription)")
                stage = .error
            }
        }
        
        // MARK: - Save to Local Storage
        @MainActor
        private func saveToLocalStorage(
            newTimeTable: TimeTable,
            context: ModelContext
        ) async {
            do {
                
                context.insert(newTimeTable)
                try context.save()
                
                logger.info("Successfully saved timetable to local storage")
                
               
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
                
            } catch {
                logger.error("Failed to save timetable to local storage: \(error.localizedDescription)")
                context.rollback()
            }
        }
        
        // MARK: - Force Sync
        @MainActor
        func forceSync(
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            logger.info("Force syncing timetable from server")
            
          
            stage = .loading
            
           
            let existingTimeTable = timeTable
            
           
            if !username.isEmpty && !authToken.isEmpty {
                await fetchAndUpdateFromAPI(
                    existingTimeTable: existingTimeTable,
                    username: username,
                    authToken: authToken,
                    context: context
                )
            } else {
                logger.error("Cannot force sync without credentials")
                stage = .error
            }
        }
        
        // MARK: - Fetch and Update from API
        @MainActor
        private func fetchAndUpdateFromAPI(
            existingTimeTable: TimeTable?,
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            do {
                logger.info("Fetching updated timetable from API")
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                
               
                if isTimeTableEmpty(remoteTimeTable) {
                    logger.info("API returned empty timetable during sync")
                    self.timeTable = remoteTimeTable
                    self.lectures = []
                    self.stage = .empty
                    
                   
                    await updateLocalStorage(
                        newTimeTable: remoteTimeTable,
                        oldTimeTable: existingTimeTable,
                        context: context
                    )
                    return
                }
                
                
                let finalTimeTable = preserveSaturdayCustomization(
                    remote: remoteTimeTable,
                    local: existingTimeTable
                )
                
                
                await updateLocalStorage(
                    newTimeTable: finalTimeTable,
                    oldTimeTable: existingTimeTable,
                    context: context
                )
                
                
                self.timeTable = finalTimeTable
                changeDay()
                stage = .data
                
                logger.info("Successfully synced timetable from API")
                
            } catch {
                logger.error("Failed to sync from API: \(error.localizedDescription)")
                stage = .error
            }
        }
        
        // MARK: - Update Local Storage (for sync)
        @MainActor
        private func updateLocalStorage(
            newTimeTable: TimeTable,
            oldTimeTable: TimeTable?,
            context: ModelContext
        ) async {
            do {
             
                if let oldTimeTable = oldTimeTable {
                    context.delete(oldTimeTable)
                }
                
                
                context.insert(newTimeTable)
                try context.save()
                
                logger.info("Successfully updated local storage")
                
            
                NotificationCenter.default.post(
                    name: NSNotification.Name("TimetableDidChange"),
                    object: nil
                )
                
            } catch {
                logger.error("Failed to update local storage: \(error.localizedDescription)")
                context.rollback()
                
                
                if let oldTimeTable = oldTimeTable {
                    context.insert(oldTimeTable)
                    try? context.save()
                }
            }
        }
        
     
        private func preserveSaturdayCustomization(
            remote: TimeTable,
            local: TimeTable?
        ) -> TimeTable {
           
            let newTimeTable = TimeTable(
                monday: remote.monday.map { $0.deepCopy() },
                tuesday: remote.tuesday.map { $0.deepCopy() },
                wednesday: remote.wednesday.map { $0.deepCopy() },
                thursday: remote.thursday.map { $0.deepCopy() },
                friday: remote.friday.map { $0.deepCopy() },
                saturday: remote.saturday.map { $0.deepCopy() },
                sunday: remote.sunday.map { $0.deepCopy() }
            )
            
            
            if let local = local,
               let saturdaySourceDay = local.saturdaySourceDay {
                logger.info("Preserving Saturday customization from: \(saturdaySourceDay)")
                
                let lecturesToCopy = newTimeTable.lectures(forDay: saturdaySourceDay)
                newTimeTable.saturday = lecturesToCopy.map { $0.deepCopy() }
                newTimeTable.saturdaySourceDay = saturdaySourceDay
            }
            
            return newTimeTable
        }
        
        
        // MARK: - Saturday Management
        @MainActor
        func copyLecturesToSaturday(
            from day: String,
            context: ModelContext
        ) async {
            guard let currentTimeTable = timeTable else {
                logger.error("No timetable available to copy from")
                return
            }
            
            logger.info("Copying lectures from \(day) to Saturday")
            
            let lecturesToCopy = currentTimeTable.lectures(forDay: day)
            let newSaturdayLectures = lecturesToCopy.map { originalLecture in
                Lecture(
                    name: originalLecture.name,
                    code: originalLecture.code,
                    venue: originalLecture.venue,
                    slot: originalLecture.slot,
                    type: originalLecture.type,
                    startTime: originalLecture.startTime,
                    endTime: originalLecture.endTime
                )
            }
            
            // Create new timetable with Saturday lectures
            let newTimeTable = TimeTable(
                monday: currentTimeTable.monday.map { $0.deepCopy() },
                tuesday: currentTimeTable.tuesday.map { $0.deepCopy() },
                wednesday: currentTimeTable.wednesday.map { $0.deepCopy() },
                thursday: currentTimeTable.thursday.map { $0.deepCopy() },
                friday: currentTimeTable.friday.map { $0.deepCopy() },
                saturday: newSaturdayLectures,
                sunday: currentTimeTable.sunday.map { $0.deepCopy() },
                saturdaySourceDay: day
            )
            
            await updateLocalStorage(
                newTimeTable: newTimeTable,
                oldTimeTable: currentTimeTable,
                context: context
            )
            
            // Update UI
            self.timeTable = newTimeTable
            changeDay()
            
            logger.info("Successfully copied \(day) lectures to Saturday")
        }
        
        // MARK: - Utility Methods
        func resetSyncStatus() {
            // Simple reset - just refresh current day
            changeDay()
        }
        
        var updatedTimeTable: TimeTable? {
            timeTable
        }
        
        // MARK: - Deprecated Methods (kept for compatibility)
        @MainActor
        func forceRefresh(
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            // Redirect to forceSync for consistency
            await forceSync(
                username: username,
                authToken: authToken,
                context: context
            )
        }
    }
}
