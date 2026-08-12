import SwiftUI

public struct ProjectManagerView: View {
    @Environment(TimeTrackerStore.self) private var store
    
    @State private var selectedProjectID: UUID?
    
    @State private var isShowingAddProject = false
    @State private var newProjectName = ""
    @State private var newProjectHourlyRate = ""
    
    @State private var isShowingAddTask = false
    @State private var newTaskTitle = ""
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            if store.projects.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.blue.opacity(0.8))
                        .padding(.bottom, 8)
                    Text("No projects yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Get started by adding your first project.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        isShowingAddProject = true
                    } label: {
                        Text("Add Project")
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.top, 12)
                }
                .padding()
                .navigationTitle("Projects")
            } else {
                List(selection: $selectedProjectID) {
                    ForEach(store.projects) { project in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 28, height: 28)
                                Image(systemName: "briefcase.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            Text(project.name)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 4)
                        .tag(project.id)
                        .contextMenu {
                            Button(role: .destructive) {
                                store.deleteProject(id: project.id)
                                if selectedProjectID == project.id {
                                    selectedProjectID = nil
                                }
                            } label: {
                                Label("Delete Project", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Projects")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isShowingAddProject = true
                        } label: {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                }
            }
        } detail: {
            if let selectedProjectID = selectedProjectID,
               let projectIndex = store.projects.firstIndex(where: { $0.id == selectedProjectID }) {
                
                let project = store.projects[projectIndex]
                
                if project.tasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checklist")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.green.opacity(0.8))
                            .padding(.bottom, 8)
                        Text("No tasks found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Create tasks to start tracking time for \(project.name).")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button {
                            isShowingAddTask = true
                        } label: {
                            Text("Add Task")
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .padding(.top, 12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .navigationTitle(project.name)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(project.tasks) { task in
                                TaskCardView(
                                    task: task,
                                    onDelete: {
                                        store.deleteTask(projectID: project.id, taskID: task.id)
                                    },
                                    onToggle: {
                                        if store.activeTaskID == task.id {
                                            if store.isTaskRunning {
                                                store.pauseActiveTask()
                                            } else {
                                                store.resumeActiveTask()
                                            }
                                        } else {
                                            store.startTask(projectID: project.id, taskID: task.id)
                                        }
                                    },
                                    isActive: store.activeTaskID == task.id,
                                    isRunning: store.activeTaskID == task.id && store.isTaskRunning,
                                    formattedDuration: formatDuration(task.totalTimeSpent)
                                )
                            }
                        }
                        .padding(20)
                    }
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                    .navigationTitle(project.name)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                isShowingAddTask = true
                            } label: {
                                Label("Add Task", systemImage: "plus")
                            }
                        }
                    }
                }
                
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.bottom, 8)
                    Text("Select a project")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Choose a project from the sidebar to view its tasks.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            }
        }
        .sheet(isPresented: $isShowingAddProject) {
            VStack(spacing: 0) {
                HStack {
                    Text("New Project")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(.regularMaterial)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("e.g. Design Redesign", text: $newProjectName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hourly Rate (Optional)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("e.g. 50.0", text: $newProjectHourlyRate)
                            .textFieldStyle(.roundedBorder)
                        Text("Setting an hourly rate allows you to see estimated earnings in the Reports tab.")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        isShowingAddProject = false
                        newProjectName = ""
                        newProjectHourlyRate = ""
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Spacer()
                    
                    Button("Save Project") {
                        let rate = Double(newProjectHourlyRate)
                        let project = Project(name: newProjectName, hourlyRate: rate)
                        store.projects.append(project)
                        store.saveData()
                        
                        isShowingAddProject = false
                        newProjectName = ""
                        newProjectHourlyRate = ""
                        
                        selectedProjectID = project.id
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newProjectName.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
                .background(.regularMaterial)
            }
            .frame(width: 400, height: 320)
        }
        .sheet(isPresented: $isShowingAddTask) {
            VStack(spacing: 0) {
                HStack {
                    Text("New Task")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(.regularMaterial)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("e.g. Wireframing", text: $newTaskTitle)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        isShowingAddTask = false
                        newTaskTitle = ""
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Spacer()
                    
                    Button("Save Task") {
                        if let selectedProjectID = selectedProjectID,
                           let projectIndex = store.projects.firstIndex(where: { $0.id == selectedProjectID }) {
                            let task = Task(title: newTaskTitle)
                            store.projects[projectIndex].tasks.append(task)
                            store.saveData()
                        }
                        isShowingAddTask = false
                        newTaskTitle = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTaskTitle.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
                .background(.regularMaterial)
            }
            .frame(width: 400, height: 220)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct TaskCardView: View {
    let task: Task
    let onDelete: () -> Void
    let onToggle: () -> Void
    let isActive: Bool
    let isRunning: Bool
    let formattedDuration: String
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isRunning ? .orange : .blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                Text(isActive ? "Tracking..." : "Task")
                    .font(.caption)
                    .foregroundColor(isActive ? .orange : .secondary)
            }
            
            Spacer()
            
            Text(formattedDuration)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(isRunning ? .orange : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isRunning ? Color.orange.opacity(0.1) : Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(isHovered ? 0.08 : 0.03), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.orange.opacity(0.5) : Color.secondary.opacity(0.15), lineWidth: isActive ? 2 : 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Task", systemImage: "trash")
            }
        }
    }
}
