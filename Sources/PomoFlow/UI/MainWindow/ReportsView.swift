import SwiftUI
import UniformTypeIdentifiers
import Charts

public struct ReportsView: View {
    @Environment(PomoFlowStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // Summary Dashboard
                let totalTime = store.projects.flatMap { $0.tasks }.reduce(0) { $0 + $1.totalTimeSpent }
                let totalEarnings = store.projects.reduce(0.0) { sum, project in
                    let projectTime = project.tasks.reduce(0) { $0 + $1.totalTimeSpent }
                    let hours = projectTime / 3600.0
                    return sum + (hours * (project.hourlyRate ?? 0.0))
                }
                
                HStack(spacing: 20) {
                    SummaryCard(title: "Total Time", value: formatDuration(totalTime), icon: "clock.fill", color: .blue)
                    SummaryCard(title: "Total Earnings", value: String(format: "$%.2f", totalEarnings), icon: "dollarsign.circle.fill", color: .green)
                }
                .padding(.horizontal, 24)
                
                // Project Breakdown
                VStack(alignment: .leading, spacing: 20) {
                    Text("Project Breakdown")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                    
                    if store.projects.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No data available yet.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 250)
                        .background(.regularMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    } else {
                        VStack {
                            Chart {
                                ForEach(store.projects) { project in
                                    let projectTime = project.tasks.reduce(0) { $0 + $1.totalTimeSpent }
                                    let hours = projectTime / 3600.0
                                    
                                    BarMark(
                                        x: .value("Project", project.name),
                                        y: .value("Hours", hours)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .cornerRadius(6)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .frame(height: 250)
                            .padding(20)
                        }
                        .background(.regularMaterial)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 20)], spacing: 20) {
                            ForEach(store.projects) { project in
                                ProjectReportCard(project: project)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .padding(.vertical, 24)
        }
        .navigationTitle("Reports")
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ProjectReportCard: View {
    let project: Project
    @State private var isHovered = false
    
    var body: some View {
        let totalTimeSpent = project.tasks.reduce(0) { $0 + $1.totalTimeSpent }
        let hours = totalTimeSpent / 3600.0
        let earnings = hours * (project.hourlyRate ?? 0.0)
        
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(project.name)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    exportCSV()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Export to CSV")
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(totalTimeSpent))
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Earnings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if project.hourlyRate != nil {
                        Text(String(format: "$%.2f", earnings))
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    } else {
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(isHovered ? 0.08 : 0.04), radius: isHovered ? 12 : 6, x: 0, y: isHovered ? 6 : 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private func exportCSV() {
        #if os(macOS)
        var csvText = "Task,Duration (Seconds),Duration (Formatted),Description\n"
        
        for task in project.tasks {
            let durationFormatted = formatDuration(task.totalTimeSpent)
            let descriptions = task.timeLogs.compactMap { $0.intent }.joined(separator: "; ")
            
            let safeTitle = task.title.replacingOccurrences(of: "\"", with: "\"\"")
            let safeDesc = descriptions.replacingOccurrences(of: "\"", with: "\"\"")
            
            csvText += "\"\(safeTitle)\",\(Int(task.totalTimeSpent)),\"\(durationFormatted)\",\"\(safeDesc)\"\n"
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "\(project.name)_Report.csv"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try csvText.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Error saving CSV: \(error)")
                }
            }
        }
        #endif
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
