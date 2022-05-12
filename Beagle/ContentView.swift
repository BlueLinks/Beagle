//
//  ContentView.swift
//  Beagle
//
//  Created by Scott Brown on 16/04/2022.
//

import SwiftUI

struct quote: Codable, Identifiable {
    var id = UUID()
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
                        print(quotes)
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(quotes), forKey:"quotes")
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
    
    @State private var showingAddQuoteSheet = false
    @State private var showingSettingsSheet = false
    @State var quotes: [quote] = []
    @State var displayedQuote: String = ""
    @State var showingBone: Bool = false
    
    var body: some View {
        NavigationView{
            ZStack{
                
                LinearGradient(gradient: Gradient(colors: [.blue, .yellow]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                
                Text("☁️")
                    .font(.title)
                    .offset(x: 120, y: -300)
                Text("☁️")
                    .font(.title)
                    .offset(x: -120, y: -325)
                
                LinearGradient(gradient: Gradient(colors: [
                    .green,
                    Color(red: 75/255, green: 134/255, blue: 112/255)
                ]), startPoint: .top, endPoint: .bottom)
                    .frame(width: 500, height: 500)
                    .offset(y: 150)
                
                
                ZStack {
                    SpeechBubble()
                        .fill(.white)
                        .shadow(color: .black, radius: 5, x: 5, y: 5)
                    Text("Shake for some motivation!").padding(10)
                }
                .frame(width: 300, height: 70)
                .onShake {
                    withAnimation{
                        if !showingBone {
                            displayedQuote = quotes.randomElement()?.text ?? ""
                        }
                        self.showingBone = true
                    }
                }
                .foregroundColor(.black)
                .offset(y:-200)
                
                VStack(spacing: 150){
                    
                    if showingBone{
                        HStack{
                            Image(systemName: "pawprint.circle")
                            Divider()
                            Text(displayedQuote)
                                .id("Quote" + displayedQuote)
                        }
                        .padding()
                        .frame(minWidth: 100, maxWidth: 350, minHeight: 0, maxHeight: 250)
                        .background(Color(red: 242/255, green: 242/255, blue: 247/255))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .black, radius: 5, x: 5, y: 5)
                        .foregroundColor(.black)
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        .offset(y: 175)
                        
                        Button{
                            withAnimation{
                                self.showingBone = false
                                displayedQuote = ""
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.largeTitle)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black)
                                .shadow(color: .black, radius: 5, x: 5, y: 5)
                        }.offset(y: 75)
                        
                    }
                    
                }
                
                Text("🐶")
                    .font(.largeTitle)
                    .offset(y: -100)
                
                
                    .sheet(isPresented: $showingAddQuoteSheet){
                        quoteList(quotes: $quotes)
                    }
                    .sheet(isPresented: $showingSettingsSheet){
                        SettingsView()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button{
                                showingAddQuoteSheet.toggle()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .black)
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading){
                            Button{
                                showingSettingsSheet.toggle()
                            } label: {
                                Image(systemName: "gear.circle.fill")
                                    .font(.largeTitle)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .black)
                            }
                        }
                    }
            }
        }
        .onAppear {
            if let data = UserDefaults.standard.value(forKey:"quotes") as? Data {
                if let quoteData = try? PropertyListDecoder().decode(Array<quote>.self, from: data) {
                    // Data has been found
                    quotes = quoteData
                }
            } else {
                // These are the default values
                quotes = [
                    quote(text: "I’ve always believed that you should never, ever give up and you should always keep fighting even when there’s only a slightest chance. – Michael Schumacher"),
                    quote(text: "Your time is limited, so don't waste it living someone else's life. Don't be trapped by dogma - which is living with the results of other people's thinking. Don't let the noise of other's opinions drown out your own inner voice. And most important, have the courage to follow your heart and intuition - Steve Jobs"),
                    quote(text: "Faith is taking the first step even when you don’t see the whole staircase. - Martin Luther King Jr"),
                    quote(text: "You miss 100% of the shots you don’t take – Wayne Gretzky"),
                    quote(text: "Keep your eyes on the stars, and your feet on the ground. ― Theodore Roosevelt")
                ]
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
