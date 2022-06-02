//
//  SettingsView.swift
//  Beagle
//
//  Created by Scott Brown on 01/05/2022.
//

import SwiftUI
import UserNotifications

struct NavigationBarModifier: ViewModifier {
    
    var backgroundColor: UIColor?
    var titleColor: UIColor?
    
    init(backgroundColor: UIColor?, titleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

struct dayModel : Codable, Identifiable {
    var id = UUID()
    var dayInitial : String
    var dayOfWeek : Int
    var selected : Bool
}

struct daySymbol : View {
    @Binding var day : dayModel
    @Binding var sectionOn : Bool
    
    var backgroundColor : Color {
        if self.day.selected{
            if !sectionOn{
                return Color.gray
            }
            return Color.blue
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        Button(){
            self.day.selected.toggle()
            print("button pressed")
            print(day.selected)
            
        } label: {
            Text(day.dayInitial)
                .foregroundColor(.white)
                .frame(width: 35, height: 35, alignment: .center)
                .background(Circle().fill(self.backgroundColor))
        }.buttonStyle(BorderlessButtonStyle())
            .disabled(sectionOn == false)
    }
}

func scheduleRandomNotif(startTime : Date, endTime: Date, quoteList : [quote], dayToggles : [dayModel]) -> Void {
    
    let center = UNUserNotificationCenter.current()
    
    for day in dayToggles{
        
        let notificationID = "randomTimeMotivation\(day.dayOfWeek)"
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                
                
                if request.identifier == notificationID {
                    
                    //Notification already exists.
                    if !day.selected{
                        // User has unselected the day of the week
                        center.removePendingNotificationRequests(withIdentifiers: [notificationID])
                    }
                    break
                    
                } else if request === requests.last && day.selected{
                    // Notification doesn't exist yet.
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Beagle"
                    content.subtitle = "BARK! Come and get your motivation!"
                    //                content.subtitle = quoteList.randomElement()?.text ?? ""
                    
                    content.sound = UNNotificationSound.default
                    
                    // Get Random Time tomorrow
                    var setDate = DateComponents()
                    let randomTime = Date.random(in: startTime..<endTime)
                    setDate.weekday = day.dayOfWeek
                    setDate.hour = Calendar.current.component(.hour, from: randomTime)
                    setDate.minute = Calendar.current.component(.minute, from: randomTime)
                    
                    
                    // show this notification five seconds from now
                    let trigger = UNCalendarNotificationTrigger(dateMatching: setDate, repeats: true)
                    
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                    
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                    
                }
            }
        })
    }
}


func scheduleSetTimeNotif(setTime : Date, quoteList : [quote], dayToggles : [dayModel]) -> Void {
    
    let center = UNUserNotificationCenter.current()
    
    for day in dayToggles{
        
        let notificationID = "setTimeMotivation\(day.dayOfWeek)"
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                
                
                if request.identifier == notificationID {
                    
                    //Notification already exists.
                    if !day.selected{
                        // User has unselected the day of the week
                        center.removePendingNotificationRequests(withIdentifiers: ["notificationID"])
                    }
                    break
                    
                } else if request === requests.last && day.selected{
                    // Notification doesn't exist yet.
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Beagle"
                    content.subtitle = "BARK! Come and get your motivation!"
                    //                content.subtitle = quoteList.randomElement()?.text ?? ""
                    
                    content.sound = UNNotificationSound.default
                    
                    // Get set time
                    var setDate = DateComponents()
                    setDate.weekday = day.dayOfWeek
                    setDate.hour = Calendar.current.component(.hour, from: setTime)
                    setDate.minute = Calendar.current.component(.minute, from: setTime)
                    
                    
                    // show this notification five seconds from now
                    let trigger = UNCalendarNotificationTrigger(dateMatching: setDate, repeats: true)
                    
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                    
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                    
                }
            }
        })
    }
}


struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var quotes: [quote]
    @AppStorage("randomToggle") var randomOn = false
    @AppStorage("setTimeToggle") var setTimeOn = false
    @State var notificationTime = Date.now
    @State var randomStartTime = Date.now
    @State var randomEndTime = Date.now
    @State var randomDayToggles: [dayModel] = [
        dayModel(dayInitial: "M", dayOfWeek: 2, selected: false),
        dayModel(dayInitial: "T", dayOfWeek: 3, selected: false),
        dayModel(dayInitial: "W", dayOfWeek: 4, selected: false),
        dayModel(dayInitial: "T", dayOfWeek: 5, selected: false),
        dayModel(dayInitial: "F", dayOfWeek: 6, selected: false),
        dayModel(dayInitial: "S", dayOfWeek: 7, selected: false),
        dayModel(dayInitial: "S", dayOfWeek: 1, selected: false)
    ]
    @State var setDayToggles: [dayModel] = [
        dayModel(dayInitial: "M", dayOfWeek: 2, selected: false),
        dayModel(dayInitial: "T", dayOfWeek: 3, selected: false),
        dayModel(dayInitial: "W", dayOfWeek: 4, selected: false),
        dayModel(dayInitial: "T", dayOfWeek: 5, selected: false),
        dayModel(dayInitial: "F", dayOfWeek: 6, selected: false),
        dayModel(dayInitial: "S", dayOfWeek: 7, selected: false),
        dayModel(dayInitial: "S", dayOfWeek: 1, selected: false)
    ]
    
    var body: some View {
        NavigationView{
            Form{
                Group{
                    Section(header: Text("Random Motivation")){
                        Toggle("Enabled", isOn: $randomOn).colorScheme(.dark)
                        Group{
                            VStack{
                                Text("Days Active")
                                HStack{
                                    ForEach($randomDayToggles){ $day in
                                        daySymbol(day: $day, sectionOn: $randomOn)
                                    }
                                }
                            }
                            DatePicker("Earliest Time", selection: $randomStartTime, displayedComponents: .hourAndMinute).colorScheme(.dark)
                            DatePicker("Latest Time", selection: $randomEndTime, displayedComponents: .hourAndMinute).colorScheme(.dark)
                        }
                        .disabled(!randomOn)
                        .foregroundColor(randomOn ? .white : .gray)
                    }
                    Section(header: Text("Set Time Motivation")){
                        Toggle("Enabled", isOn: $setTimeOn).tint(.green).colorScheme(.dark)
                        Group{
                            VStack{
                                Text("Days Active")
                                HStack{
                                    ForEach($setDayToggles){ $day in
                                        daySymbol(day: $day, sectionOn: $setTimeOn)
                                    }
                                }
                            }
                            DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute).colorScheme(.dark)
                        }
                        .disabled(!setTimeOn)
                        .foregroundColor(setTimeOn ? .white : .gray)
                    }
                    Button(){
                        
                        //scheduleRandomNotif(startTime: randomStartTime, endTime: randomEndTime, quoteList: quotes)
                        
                    } label: {
                        Text("Test notification")
                    }
                }
                
                .foregroundColor(.white)
                .listRowBackground(Color("Evening Sea"))
            }
            .background(LinearGradient(gradient: Gradient(colors: [
                .green,
                Color("Viridian")
            ]), startPoint: .top, endPoint: .bottom))
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                
                
                if let data = UserDefaults.standard.value(forKey:"randomDayToggles") as? Data {
                    if let dayTogglesData = try? PropertyListDecoder().decode(Array<dayModel>.self, from: data) {
                        // Data has been found
                        randomDayToggles = dayTogglesData
                    }
                }
                
                if let data = UserDefaults.standard.value(forKey:"setDayToggles") as? Data {
                    if let dayTogglesData = try? PropertyListDecoder().decode(Array<dayModel>.self, from: data) {
                        // Data has been found
                        setDayToggles = dayTogglesData
                    }
                }
                
                if let date = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
                    notificationTime = date
                }
                
                if let date = UserDefaults.standard.object(forKey: "randomStartTime") as? Date {
                    randomStartTime = date
                } else {
                    // Set default value to 09:00
                    var components = DateComponents()
                    components.hour = 9
                    components.minute = 0
                    randomStartTime = Calendar.current.date(from: components) ?? Date.now
                }
                
                if let date = UserDefaults.standard.object(forKey: "randomEndTime") as? Date {
                    randomEndTime = date
                } else {
                    // Set default value to 17:00
                    var components = DateComponents()
                    components.hour = 17
                    components.minute = 0
                    randomEndTime = Calendar.current.date(from: components) ?? Date.now
                }
                
            }
            .onDisappear {
                UITableView.appearance().backgroundColor = .systemGroupedBackground
            }
            
            .navigationTitle("Notifications")
            .navigationBarColor(backgroundColor: UIColor(Color("Evening Sea")), titleColor: .white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Finished"){
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(randomDayToggles), forKey:"randomDayToggles")
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(setDayToggles), forKey:"setDayToggles")
                        UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
                        UserDefaults.standard.set(randomStartTime, forKey: "randomStartTime")
                        UserDefaults.standard.set(randomEndTime, forKey: "randomEndTime")
                        
                        // Notifications
                        scheduleSetTimeNotif(setTime: notificationTime, quoteList: quotes, dayToggles: setDayToggles)
                        scheduleRandomNotif(startTime: randomStartTime, endTime: randomEndTime, quoteList: quotes, dayToggles: randomDayToggles)
                        
                        dismiss()
                    }
                }
            }
        }
    }
}
