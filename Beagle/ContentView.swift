//
//  ContentView.swift
//  Beagle
//
//  Created by Scott Brown on 16/04/2022.
//

import SwiftUI

struct quote: Identifiable {
    let id = UUID()
    var text: String
}

// Credit to https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-shake-gestures
// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

struct quoteList: View {
    @Environment(\.dismiss) var dismiss
    @Binding var quotes: [quote]
    
    var body: some View {
        NavigationView{
            VStack{
                List {
                    ForEach($quotes) {$quote in
                        TextField("",text: $quote.text)
                    }
                    .onDelete{ indexSet in
                        quotes.remove(atOffsets: indexSet)
                    }
                    Button("Add quote"){
                        quotes.append(quote(text: ""))
                    }
                }
            }
            .navigationTitle("Add some motivation!")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Finished"){
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    EditButton()
                }
            }
        }
    }
}


struct ContentView: View {
    
    @State private var showingSheet = false
    @State var quotes: [quote] = [
        quote(text: "It never gets better."),
        quote(text: "You could've tried harder."),
        quote(text: "You will never be the same."),
        quote(text: "Avoid disappointment by giving up hope."),
        quote(text: "This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one, This is a long one"),
    ]
    @State var displayedQuote: String = "Press the button!"
    
    var body: some View {
        NavigationView{
            VStack(spacing: 150){
                
                HStack{
                    Image(systemName: "pawprint.circle")
                    Divider()
                    Text(displayedQuote)
                    .transition(.opacity)
                    .id("Quote" + displayedQuote)
                    
                }
                .padding()
                .background(Color(red: 242/255, green: 242/255, blue: 247/255))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .foregroundColor(.black)
                .frame(minWidth: 250, maxWidth: 500, minHeight: 0, maxHeight: 250)
                Text("Shake for some motivation!").onShake {
                    withAnimation{
                        displayedQuote = quotes.randomElement()?.text ?? "Enter some quotes!"
                    }
                }
                .padding()
                .background(Color.blue)
                .clipShape(Capsule())
                .foregroundColor(.white)
                
            }
            .sheet(isPresented: $showingSheet){
                quoteList(quotes: $quotes)
            }
            .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    showingSheet.toggle()
                } label: {
                    HStack{
                    Text("Add Quotes")
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
