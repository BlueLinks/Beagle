//
//  SettingsView.swift
//  Beagle
//
//  Created by Scott Brown on 01/05/2022.
//

import SwiftUI

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

extension View {
    
    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
    
}

struct dayModel : Codable, Identifiable {
    var id = UUID()
    var dayInitial : String
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


struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("randomToggle") var randomOn = false
    @AppStorage("setTimeToggle") var setTimeOn = false
    @State var notificationTime = Date.now
    @State var randomStartTime = Date.now
    @State var randomEndTime = Date.now
    @State var randomDayToggles: [dayModel] = [
        dayModel(dayInitial: "M", selected: false),
        dayModel(dayInitial: "T", selected: false),
        dayModel(dayInitial: "W", selected: false),
        dayModel(dayInitial: "T", selected: false),
        dayModel(dayInitial: "F", selected: false),
        dayModel(dayInitial: "S", selected: false),
        dayModel(dayInitial: "S", selected: false)
    ]
    @State var setDayToggles: [dayModel] = [
        dayModel(dayInitial: "M", selected: false),
        dayModel(dayInitial: "T", selected: false),
        dayModel(dayInitial: "W", selected: false),
        dayModel(dayInitial: "T", selected: false),
        dayModel(dayInitial: "F", selected: false),
        dayModel(dayInitial: "S", selected: false),
        dayModel(dayInitial: "S", selected: false)
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
                }
                
                .foregroundColor(.white)
                .listRowBackground(Color(red: 35/255, green: 94/255, blue: 72/255))
            }
            .background(LinearGradient(gradient: Gradient(colors: [
                .green,
                Color(red: 75/255, green: 134/255, blue: 112/255)
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
            .navigationBarColor(backgroundColor: UIColor(Color(red: 55/255, green: 114/255, blue: 92/255)), titleColor: .white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Finished"){
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(randomDayToggles), forKey:"randomDayToggles")
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(setDayToggles), forKey:"setDayToggles")
                        UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
                        UserDefaults.standard.set(randomStartTime, forKey: "randomStartTime")
                        UserDefaults.standard.set(randomEndTime, forKey: "randomEndTime")
                        
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
