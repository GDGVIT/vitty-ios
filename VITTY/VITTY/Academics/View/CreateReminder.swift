import SwiftUI
import SwiftData

struct ReminderView: View {
    var courseName: String
    var slot: String
    var courseCode: String

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showDatePicker = false
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Add") {
                        let newReminder = Remainder(
                            title: title,
                            subject: courseName,
                            slot: slot,
                            courseCode: courseCode,
                            date: selectedDate,
                            isCompleted: false,
                            subjectDescription: description,
                            startTime: startTime,
                            endTime: endTime
                        )

                        do {
                            modelContext.insert(newReminder)
                            try modelContext.save()
                            print("Saved successfully")
                        } catch {
                            print("Failed to save: \(error.localizedDescription)")
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!isFormValid)
                    .foregroundColor(isFormValid ? .red : .gray)
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Set New Reminder")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom)

                        TextField("Title", text: $title)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)

                        TextField("Description (Optional)", text: $description)
                            .padding()
                            .background(Color("Secondary"))
                            .cornerRadius(10)

                        HStack {
                            Text("Subject")
                                .foregroundColor(.white)
                            Spacer()
                            Text(courseName)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("Secondary"))
                                .cornerRadius(20)
                        }

                        // Alert Date Picker
                        HStack {
                            Text("Alert Date")
                                .foregroundColor(.white)
                            Spacer()
                            Text(selectedDate, style: .date)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color("Secondary"))
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        }

                        if showDatePicker {
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .colorScheme(.dark)
                            .labelsHidden()

                            Button("Done") {
                                withAnimation {
                                    showDatePicker = false
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 5)
                        }

                        // Start Time
                        HStack {
                            Text("Start Time")
                                .foregroundColor(.white)
                            Spacer()
                            Text(startTime, style: .time)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color("Secondary"))
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                showStartTimePicker.toggle()
                            }
                        }

                        if showStartTimePicker {
                            DatePicker(
                                "Start Time",
                                selection: $startTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)

                            Button("Done") {
                                withAnimation {
                                    showStartTimePicker = false
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        // End Time
                        HStack {
                            Text("End Time")
                                .foregroundColor(.white)
                            Spacer()
                            Text(endTime, style: .time)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color("Secondary"))
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                showEndTimePicker.toggle()
                            }
                        }

                        if showEndTimePicker {
                            DatePicker(
                                "End Time",
                                selection: $endTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)

                            Button("Done") {
                                withAnimation {
                                    showEndTimePicker = false
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

