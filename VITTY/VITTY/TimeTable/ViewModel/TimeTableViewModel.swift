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
        private var currentContext: ModelContext?
        
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(
                describing: TimeTableViewModel.self
            )
        )
        
        func changeDay() {
            switch dayNo {
            case 0:
                self.lectures = timeTable?.monday ?? []
            case 1:
                self.lectures = timeTable?.tuesday ?? []
            case 2:
                self.lectures = timeTable?.wednesday ?? []
            case 3:
                self.lectures = timeTable?.thursday ?? []
            case 4:
                self.lectures = timeTable?.friday ?? []
            case 5:
                self.lectures = timeTable?.saturday ?? []
            case 6:
                self.lectures = timeTable?.sunday ?? []
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
            
            // Store context for later use
            currentContext = context
            
            if let existing = existingTimeTable {
                logger.debug("Using existing local timetable")
                timeTable = existing
                changeDay()
                stage = .data
                print("\(existing)")
               
                // Start background sync if not already done
                if !hasSyncedThisSession && !isSyncing {
                    Task {
                        await backgroundSync(
                            localTimeTable: existing,
                            username: username,
                            authToken: authToken,
                            context: context
                        )
                    }
                }
            } else {
                logger.debug("No local timetable, fetching from API")
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
            guard !isSyncing else { return }
            
            isSyncing = true
            hasSyncedThisSession = true
            
            logger.info("Starting background sync")
            
            do {
                let remoteTimeTable = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                
                logger.info("Background sync: Fetched remote timetable")
                
                if shouldUpdateLocalTimeTable(local: localTimeTable, remote: remoteTimeTable) {
                    logger.info("Background sync: Timetables differ, updating local data")
                    await updateLocalTimeTableWithPersistence(
                        oldTimeTable: localTimeTable,
                        newTimeTable: remoteTimeTable,
                        context: context
                    )
                } else {
                    logger.info("Background sync: Timetables are identical, no update needed")
                }
                
            } catch {
                logger.error("Background sync failed: \(error)")
            }
            
            isSyncing = false
        }
        
        private func shouldUpdateLocalTimeTable(local: TimeTable, remote: TimeTable) -> Bool {
            let daysToCompare = [
                (local.monday, remote.monday),
                (local.tuesday, remote.tuesday),
                (local.wednesday, remote.wednesday),
                (local.thursday, remote.thursday),
                (local.friday, remote.friday),
                (local.saturday, remote.saturday),
                (local.sunday, remote.sunday)
            ]
            
            for (localDay, remoteDay) in daysToCompare {
                if !areLectureArraysEqual(localDay, remoteDay) {
                    return true
                }
            }
            
            return false
        }
        
        private func areLectureArraysEqual(_ local: [Lecture], _ remote: [Lecture]) -> Bool {
            guard local.count == remote.count else { return false }
            
            let sortedLocal = local.sorted { $0.startTime < $1.startTime }
            let sortedRemote = remote.sorted { $0.startTime < $1.startTime }
            
            for (localLecture, remoteLecture) in zip(sortedLocal, sortedRemote) {
                if !areLecturesEqual(localLecture, remoteLecture) {
                    return false
                }
            }
            
            return true
        }
        
        private func areLecturesEqual(_ local: Lecture, _ remote: Lecture) -> Bool {
            return local.name == remote.name &&
                   local.code == remote.code &&
                   local.venue == remote.venue &&
                   local.slot == remote.slot &&
                   local.type == remote.type &&
                   local.startTime == remote.startTime &&
                   local.endTime == remote.endTime
        }
        
        @MainActor
        private func updateLocalTimeTableWithPersistence(
            oldTimeTable: TimeTable,
            newTimeTable: TimeTable,
            context: ModelContext
        ) async {
            logger.info("Updating local timetable with persistence")
            
            do {
                // Delete the old timetable from persistent storage
                context.delete(oldTimeTable)
                
                // Insert the new timetable
                context.insert(newTimeTable)
                
                // Save the context to persist changes
                try context.save()
                
                // Update the in-memory reference
                timeTable = newTimeTable
                changeDay()
                
                logger.info("Local timetable successfully updated and persisted")
                
            } catch {
                logger.error("Failed to update local timetable: \(error)")
                // Rollback: if save fails, re-insert the old timetable
                context.insert(oldTimeTable)
                try? context.save()
            }
        }
        
        @MainActor
        private func fetchTimeTableFromAPI(
            username: String,
            authToken: String,
            context: ModelContext
        ) async {
            logger.info("Fetching TimeTable from API")
            
            do {
                stage = .loading
                let data = try await TimeTableAPIService.shared.getTimeTable(
                    with: username,
                    authToken: authToken
                )
                
                logger.info("TimeTable fetched from API")
                
                timeTable = data
                changeDay()
                stage = .data
                
                context.insert(data)
                try context.save()
                hasSyncedThisSession = true
                
            } catch {
                logger.error("API fetch failed: \(error)")
                stage = .error
            }
        }
        
        var updatedTimeTable: TimeTable? {
            timeTable
        }
        
        func resetSyncStatus() {
            hasSyncedThisSession = false
            logger.debug("Sync status reset")
        }
    }
}
