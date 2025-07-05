//
//  TimeTableViewModel.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import Foundation
import OSLog
import SwiftData

public enum Stage {
    case loading
    case error
    case data
}

extension TimeTableView {
    @Observable
    class TimeTableViewModel {
        
        var timeTable: TimeTable?
        var stage: Stage = .loading
        var lectures = [Lecture]()
        var dayNo = Date.convertToMondayWeek()
        
        private var hasSyncedThisSession = false
        private var isSyncing = false
        
        // Serial queue for database operations to prevent race conditions
        private let databaseQueue = DispatchQueue(label: "com.vitty.database", qos: .userInitiated)
        
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(
                describing: TimeTableViewModel.self
            )
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
                     self?.forceRefreshCurrentDay()
                 }
             }
        private func forceRefreshCurrentDay() {
                  logger.info("Forcing refresh of current day due to timetable change")
                  changeDay()
              }
        // NEW: Method to refresh the timetable data from the database
        @MainActor
        func refreshFromDatabase(_ updatedTimeTable: TimeTable?) {
            guard let updatedTimeTable = updatedTimeTable else {
                self.timeTable = nil
                self.lectures = []
                self.stage = .error
                return
            }
            
            // Update our cached copy with the fresh data
            self.timeTable = updatedTimeTable
            changeDay() // Refresh the current day's lectures
            
            logger.info("Timetable refreshed from database")
        }
        
        func changeDay() {
            guard let timeTable = timeTable else {
                self.lectures = []
                return
            }
            
            switch dayNo {
            case 0:
                self.lectures = timeTable.monday
            case 1:
                self.lectures = timeTable.tuesday
            case 2:
                self.lectures = timeTable.wednesday
            case 3:
                self.lectures = timeTable.thursday
            case 4:
                self.lectures = timeTable.friday
            case 5:
                self.lectures = timeTable.saturday
            case 6:
                self.lectures = timeTable.sunday
            default:
                self.lectures = []
            }
        }
        
        
        @MainActor
               func loadTimeTable(
                   existingTimeTable: TimeTable?,
                   username: String,
                   authToken: String,
                   context: ModelContext
               ) async {
                   logger.info("Starting timetable loading process")
                   
                   if let existing = existingTimeTable {
                       logger.debug("Using existing local timetable.")
                       self.timeTable = existing
                       changeDay()
                       self.stage = .data
                       
                   
                       if !hasSyncedThisSession && !isSyncing && !username.isEmpty && !authToken.isEmpty {
                       
                           Task { [weak self] in
                               await self?.backgroundSync(
                                   localTimeTable: existing,
                                   username: username,
                                   authToken: authToken,
                                   context: context
                               )
                           }
                       }
                   } else {
                       logger.debug("No local timetable, fetching from API.")
                       await fetchTimeTableFromAPI(
                           username: username,
                           authToken: authToken,
                           context: context
                       )
                   }
               }
        
        private func backgroundSync(
            localTimeTable: TimeTable,
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            guard !isSyncing else {
                logger.info("Sync already in progress. Skipping.")
                return
            }
            
          
            await MainActor.run {
                isSyncing = true
            }
            
            logger.info("Starting background sync.")
            
            defer {
                Task { @MainActor in
                    isSyncing = false
                }
            }
            
            do {
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                logger.info("Background sync: Fetched remote timetable.")
                
              
                let mergedTimeTable = await createMergedTimeTable(
                    remote: remoteTimeTable,
                    local: localTimeTable
                )
                
             
                await updateLocalDatabaseSafely(
                    with: mergedTimeTable,
                    oldTimeTable: localTimeTable,
                    context: context
                )
                
                await MainActor.run {
                    hasSyncedThisSession = true
                }
                
            } catch {
                logger.error("Background sync failed: \(error.localizedDescription)")
              
            }
        }
        
        private func createMergedTimeTable(
            remote: TimeTable,
            local: TimeTable
        ) async -> TimeTable {
            let saturdaySourceDay = local.saturdaySourceDay
            
            let finalTimeTable = TimeTable(
                monday: remote.monday.map { $0.deepCopy() },
                tuesday: remote.tuesday.map { $0.deepCopy() },
                wednesday: remote.wednesday.map { $0.deepCopy() },
                thursday: remote.thursday.map { $0.deepCopy() },
                friday: remote.friday.map { $0.deepCopy() },
                saturday: [],
                sunday: remote.sunday.map { $0.deepCopy() }
            )
            
           
            if let sourceDay = saturdaySourceDay {
                logger.info("Re-applying Saturday rule from source day: \(sourceDay).")
                let lecturesToCopy = finalTimeTable.lectures(forDay: sourceDay)
                finalTimeTable.saturday = lecturesToCopy.map { $0.deepCopy() }
                finalTimeTable.saturdaySourceDay = sourceDay
            }
            
            return finalTimeTable
        }
        
        @MainActor
        private func updateLocalDatabaseSafely(
            with newTimeTable: TimeTable,
            oldTimeTable: TimeTable,
            context: ModelContext
        ) async {
            logger.info("Updating local database with merged timetable.")
            
           
            do {
               
                context.delete(oldTimeTable)
                context.insert(newTimeTable)
                try context.save()
                
              
                self.timeTable = newTimeTable
                changeDay()
                logger.info("Local database successfully updated and persisted.")
                
            } catch {
                logger.error("Failed to save merged timetable: \(error.localizedDescription)")
              
                do {
                    
                    context.rollback()
                    
                
                    context.insert(oldTimeTable)
                    try context.save()
                    
                    
                    self.timeTable = oldTimeTable
                    changeDay()
                    logger.info("Rollback successful.")
                    
                } catch {
                    logger.error("Rollback also failed: \(error.localizedDescription)")
                    // In this case, trigger a fresh fetch
                    await handleDatabaseCorruption(context: context)
                }
            }
        }
        
        @MainActor
        private func handleDatabaseCorruption(context: ModelContext) async {
            logger.warning("Handling potential database corruption.")
            
           
            self.timeTable = nil
            self.lectures = []
            self.stage = .error
            
         
            hasSyncedThisSession = false
            isSyncing = false
            
            logger.info("Database corruption handled. User will need to reload.")
        }
        
        @MainActor
        private func fetchTimeTableFromAPI(
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            logger.info("Fetching TimeTable from API for initial load.")
            stage = .loading
            
            guard !username.isEmpty && !authToken.isEmpty else {
                logger.error("Username or auth token is empty")
                stage = .error
                return
            }
            
            do {
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                logger.info("TimeTable fetched from API.")
                
               
                context.insert(remoteTimeTable)
                try context.save()
                
                self.timeTable = remoteTimeTable
                changeDay()
                stage = .data
                hasSyncedThisSession = true
                
            } catch {
                logger.error("API fetch failed: \(error.localizedDescription)")
                stage = .error
            }
        }
        
        func resetSyncStatus() {
            hasSyncedThisSession = false
            logger.debug("Sync status reset.")
        }
        
        var updatedTimeTable: TimeTable? {
            timeTable
        }
        
        @MainActor
        func forceRefresh(
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            logger.info("Force refreshing timetable data.")
            hasSyncedThisSession = false
            isSyncing = false
            
           
            if let existingTimeTable = timeTable {
                do {
                    context.delete(existingTimeTable)
                    try context.save()
                } catch {
                    logger.error("Failed to delete existing timetable: \(error.localizedDescription)")
                   
                }
            }
            
         
            self.timeTable = nil
            self.lectures = []
            
           
            await fetchTimeTableFromAPI(
                username: username,
                authToken: authToken,
                context: context
            )
        }
    }
}
