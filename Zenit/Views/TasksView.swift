import SwiftUI

struct TasksView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddTask = false
    @State private var newTaskTitle = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var listAppear = false

    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case done = "Done"
    }

    var filteredTasks: [ZenitTask] {
        switch selectedFilter {
        case .all: return store.tasks
        case .today: return store.tasks.filter { !$0.isCompleted }
        case .done: return store.tasks.filter { $0.isCompleted }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "0D0D0F").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tasks")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(store.tasks.filter { !$0.isCompleted }.count) remaining")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showAddTask = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex:"7C6AF7"), Color(hex:"A78BFA")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                                .shadow(color: Color(hex:"7C6AF7").opacity(0.45), radius: 12, x: 0, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Filter pills
                HStack(spacing: 8) {
                    ForEach(TaskFilter.allCases, id: \.self) { f in
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedFilter = f }
                        } label: {
                            Text(f.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedFilter == f ? .white : .white.opacity(0.4))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 9)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == f ? Color(hex:"7C6AF7").opacity(0.25) : Color.white.opacity(0.05))
                                        .overlay(Capsule().strokeBorder(selectedFilter == f ? Color(hex:"7C6AF7").opacity(0.5) : Color.clear, lineWidth: 1))
                                )
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Task list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(filteredTasks.enumerated()), id: \.element.id) { idx, task in
                            TaskRow(task: task)
                                .offset(y: listAppear ? 0 : 20)
                                .opacity(listAppear ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(idx) * 0.05), value: listAppear)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }

            // Add task sheet overlay
            if showAddTask {
                AddTaskOverlay(isShown: $showAddTask, taskTitle: $newTaskTitle) {
                    if !newTaskTitle.isEmpty {
                        store.addTask(title: newTaskTitle)
                        newTaskTitle = ""
                    }
                    showAddTask = false
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { listAppear = true }
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: ZenitTask
    @EnvironmentObject var store: AppStore
    @State private var offset: CGFloat = 0
    @State private var checked: Bool

    init(task: ZenitTask) {
        self.task = task
        _checked = State(initialValue: task.isCompleted)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    checked.toggle()
                    store.toggleTask(id: task.id)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(checked ? Color(hex:"7C6AF7") : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if checked {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex:"7C6AF7"))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(checked ? .white.opacity(0.3) : .white)
                    .strikethrough(checked, color: .white.opacity(0.3))

                if let subtitle = task.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            Spacer()

            // Priority tag
            Text(task.priority.rawValue)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(task.priorityColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(task.priorityColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(checked ? 0.02 : 0.05))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
        )
        .offset(x: offset)
    }
}

// MARK: - Add Task Overlay
struct AddTaskOverlay: View {
    @Binding var isShown: Bool
    @Binding var taskTitle: String
    var onAdd: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { isShown = false }

            VStack(spacing: 20) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)

                Text("New Task")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Input
                HStack(spacing: 12) {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(hex:"7C6AF7"))
                        .font(.system(size: 16, weight: .semibold))

                    TextField("", text: $taskTitle, prompt: Text("What needs to be done?").foregroundColor(.white.opacity(0.3)))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .focused($focused)
                        .onSubmit { onAdd() }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.07)).overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex:"7C6AF7").opacity(0.3), lineWidth: 1)))

                Button(action: onAdd) {
                    Text("Add Task")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color(hex:"7C6AF7"), Color(hex:"A78BFA")], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex:"7C6AF7").opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(hex:"1A1A24"))
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .onAppear { focused = true }
    }
}
