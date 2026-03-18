import SwiftUI

struct TasksView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAdd = false
    @State private var filterTag: String? = nil
    @State private var searchText = ""

    var filtered: [ZTask] {
        store.tasks.filter { task in
            let matchTag = filterTag == nil || task.tag == filterTag
            let matchSearch = searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)
            return matchTag && matchSearch
        }
    }

    var allTags: [String] { Array(Set(store.tasks.map { $0.tag }.filter { !$0.isEmpty })).sorted() }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            OrbBackground()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tasks")
                            .font(ZFont.title1).foregroundColor(.zenitText)
                        Text("\(store.tasks.filter { !$0.isDone }.count) active")
                            .font(ZFont.caption).foregroundColor(.zenitSubtext)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 16)

                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.zenitSubtext)
                        .font(.system(size: 15))
                    TextField("Search tasks...", text: $searchText)
                        .font(ZFont.body).foregroundColor(.zenitText)
                        .tint(.zenitAccent)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.zenitSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.zenitBorder.opacity(0.6), lineWidth: 0.5))
                .padding(.horizontal, 20).padding(.bottom, 12)

                // Tag Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        TagChip(label: "All", isActive: filterTag == nil) { filterTag = nil }
                        ForEach(allTags, id: \.self) { tag in
                            TagChip(label: tag, isActive: filterTag == tag) { filterTag = filterTag == tag ? nil : tag }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)

                // Task List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(filtered) { task in
                            TaskCard(task: task)
                                .transition(.asymmetric(
                                    insertion: .push(from: .leading),
                                    removal: .opacity.combined(with: .move(edge: .trailing))
                                ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filtered.map { $0.id })
                    Spacer(minLength: 120)
                }
            }

            // FAB
            Button { showAdd = true } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.zenitAccent, .zenitAccent2], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                        .shadow(color: .zenitAccent.opacity(0.6), radius: 16, y: 8)
                    Image(systemName: "plus").font(.system(size: 22, weight: .semibold)).foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 24).padding(.bottom, 100)
        }
        .sheet(isPresented: $showAdd) { AddTaskSheet() }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let label: String; let isActive: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label).font(ZFont.caption)
                .foregroundColor(isActive ? .white : .zenitSubtext)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isActive ? Color.zenitAccent : Color.zenitSurface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isActive ? Color.clear : Color.zenitBorder.opacity(0.5), lineWidth: 0.5))
        }.buttonStyle(.plain)
    }
}

// MARK: - Task Card
struct TaskCard: View {
    @EnvironmentObject var store: AppStore
    let task: ZTask
    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete bg
            if showDelete {
                HStack {
                    Spacer()
                    Button { withAnimation { store.deleteTask(task) } } label: {
                        Image(systemName: "trash.fill").font(.system(size: 18)).foregroundColor(.white)
                            .frame(width: 72).frame(maxHeight: .infinity)
                    }.background(Color.zenitRose)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }

            HStack(spacing: 14) {
                // Checkbox
                Button { store.toggleTask(task) } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(task.isDone ? task.priority.color : Color.zenitBorder, lineWidth: 2)
                            .frame(width: 28, height: 28)
                        if task.isDone {
                            Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(task.priority.color)
                        }
                    }
                }.buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title).font(ZFont.bodyMed).foregroundColor(task.isDone ? .zenitSubtext : .zenitText)
                        .strikethrough(task.isDone, color: .zenitSubtext)
                    if !task.note.isEmpty {
                        Text(task.note).font(ZFont.caption).foregroundColor(.zenitSubtext).lineLimit(1)
                    }
                    HStack(spacing: 6) {
                        if !task.tag.isEmpty {
                            Text(task.tag).font(ZFont.micro).foregroundColor(task.priority.color)
                                .padding(.horizontal, 8).padding(.vertical, 2).background(task.priority.color.opacity(0.15)).clipShape(Capsule())
                        }
                        if let due = task.dueDate {
                            Label(due.formatted(.dateTime.month(.abbreviated).day()), systemImage: "calendar")
                                .font(ZFont.micro).foregroundColor(.zenitSubtext)
                        }
                    }
                }
                Spacer()

                // Priority indicator
                VStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i < priorityLevel(task.priority) ? task.priority.color : Color.zenitBorder)
                            .frame(width: 4, height: 8)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.zenitSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.zenitBorder.opacity(0.5), lineWidth: 0.5))
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { v in
                        if v.translation.width < 0 { offset = v.translation.width }
                    }
                    .onEnded { v in
                        withAnimation(.spring()) {
                            if v.translation.width < -60 { showDelete = true; offset = -72 }
                            else { showDelete = false; offset = 0 }
                        }
                    }
            )
        }
    }

    func priorityLevel(_ p: ZTask.Priority) -> Int {
        switch p { case .low: return 1; case .medium: return 2; case .high: return 3 }
    }
}

// MARK: - Add Task Sheet
struct AddTaskSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var note = ""
    @State private var tag = ""
    @State private var priority: ZTask.Priority = .medium

    var body: some View {
        NavigationView {
            ZStack {
                Color.zenitBlack.ignoresSafeArea()
                Form {
                    Section {
                        TextField("Task title", text: $title)
                            .font(ZFont.bodySemi).foregroundColor(.zenitText)
                        TextField("Note (optional)", text: $note)
                            .font(ZFont.body).foregroundColor(.zenitSubtext)
                    } header: { Text("Details").font(ZFont.micro).foregroundColor(.zenitSubtext) }

                    Section {
                        Picker("Priority", selection: $priority) {
                            ForEach(ZTask.Priority.allCases, id: \.self) { p in
                                Text(p.rawValue.capitalized).tag(p)
                            }
                        }.pickerStyle(.segmented)
                    } header: { Text("Priority").font(ZFont.micro).foregroundColor(.zenitSubtext) }

                    Section {
                        TextField("Tag (e.g. Work, Personal)", text: $tag)
                            .font(ZFont.body).foregroundColor(.zenitText)
                    } header: { Text("Tag").font(ZFont.micro).foregroundColor(.zenitSubtext) }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.zenitSubtext)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !title.isEmpty else { return }
                        store.addTask(ZTask(title: title, note: note, priority: priority, tag: tag))
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(.zenitAccent)
                }
            }
        }
    }
}
