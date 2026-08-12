import Foundation

public actor StorageManager {
    public static let shared = StorageManager()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init() {
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private var applicationSupportDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appDir = urls[0].appendingPathComponent("PomoFlow", isDirectory: true)
        
        if !fileManager.fileExists(atPath: appDir.path) {
            try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return appDir
    }
    
    private var activeProjectsFileURL: URL {
        return applicationSupportDirectory.appendingPathComponent("active_projects.json")
    }
    
    public func archiveFileURL(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM"
        let dateString = formatter.string(from: date)
        return applicationSupportDirectory.appendingPathComponent("archive_\(dateString).json")
    }
    
    public func loadActiveProjects() throws -> [Project] {
        let url = activeProjectsFileURL
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        
        let data = try Data(contentsOf: url)
        return try decoder.decode([Project].self, from: data)
    }
    
    public func saveActiveProjects(_ projects: [Project]) throws {
        let data = try encoder.encode(projects)
        try data.write(to: activeProjectsFileURL, options: [.atomic, .completeFileProtectionUnlessOpen])
    }
    
    public func loadArchivedProjects(for date: Date) throws -> [Project] {
        let url = archiveFileURL(for: date)
        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }
        
        let data = try Data(contentsOf: url)
        return try decoder.decode([Project].self, from: data)
    }
    
    private func saveArchivedProjects(_ projects: [Project], for date: Date) throws {
        let data = try encoder.encode(projects)
        try data.write(to: archiveFileURL(for: date), options: [.atomic, .completeFileProtectionUnlessOpen])
    }
    
    public func archiveCompletedTasks() throws {
        var activeProjects = try loadActiveProjects()
        let currentDate = Date()
        
        var archivedProjectsThisMonth = try loadArchivedProjects(for: currentDate)
        var hasChanges = false
        
        for i in 0..<activeProjects.count {
            let project = activeProjects[i]
            let completedTasks = project.tasks.filter { $0.isCompleted }
            
            if !completedTasks.isEmpty {
                hasChanges = true
                
                // Remove from active
                activeProjects[i].tasks.removeAll { $0.isCompleted }
                
                // Add to archive
                if let index = archivedProjectsThisMonth.firstIndex(where: { $0.id == project.id }) {
                    archivedProjectsThisMonth[index].tasks.append(contentsOf: completedTasks)
                } else {
                    var archivedProject = project
                    archivedProject.tasks = completedTasks
                    archivedProjectsThisMonth.append(archivedProject)
                }
            }
        }
        
        if hasChanges {
            try saveActiveProjects(activeProjects)
            try saveArchivedProjects(archivedProjectsThisMonth, for: currentDate)
        }
    }
}
