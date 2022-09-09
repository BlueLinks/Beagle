//
//  ContentView.swift
//  Beagle
//
//  Created by Scott Brown on 16/04/2022.
//

import SwiftUI
import UserNotifications

struct quote: Codable, Identifiable {
    var id = UUID()
    var text: String
}

struct QuoteBox: View {
    
    @Binding var currentQuote : quote
    
    var body: some View {
        TextField("", text: $currentQuote.text, axis: .vertical)
    }
}

struct quoteList: View {
    @Environment(\.dismiss) var dismiss
    @Binding var quotes: [quote]
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach($quotes) {$quote in
                        QuoteBox(currentQuote: $quote)
                    }
                    .onDelete{ indexSet in
                        quotes.remove(atOffsets: indexSet)
                    }
                    HStack{
                        Spacer()
                        Button{
                            quotes.append(quote(text: ""))
                        } label: {
                            Text("Add quote")
                                .foregroundColor(Color.white)
                                .padding()
                                .background(Color("Evening Sea"))
                                .clipShape(Capsule())
                        }
                        Spacer()
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
    @State var bouncing : Bool = false
    
    
    var body: some View {
        GeometryReader{ geo in
            NavigationView{
                
                ZStack(alignment: .bottom){
                    LinearGradient(gradient: Gradient(colors: [.blue, .yellow]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: geo.size.height)
                    
                    ZStack(alignment: .top){
                        LinearGradient(gradient: Gradient(colors: [.green,Color("Viridian")]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.bottom)
                            .frame(height: geo.size.height*0.65)
                            .ignoresSafeArea()
                        Text("🐶")
                            .font(.largeTitle).offset(y: -20)
                        
                        Text("☁️")
                            .font(.title)
                            .offset(x: 120, y: -220)
                        Text("☁️")
                            .font(.title)
                            .offset(x: -120, y: -180)
                        
                        
                        ZStack {
                            SpeechBubble()
                                .fill(.white)
                                .shadow(color: .black, radius: 5, x: 5, y: 5)
                                .frame(width: 300, height: 70)
                            Text("Shake for some motivation!").padding(10)
                        }.offset(y: bouncing ? -110 : -115)
                            .animation(Animation.easeInOut(duration: 2).repeatForever(), value: self.bouncing)
                            .onAppear {
                                self.bouncing.toggle()
                            }
                            .onShake {
                                withAnimation{
                                    if !showingBone {
                                        displayedQuote = quotes.randomElement()?.text ?? ""
                                    }
                                    self.showingBone = true
                                }
                            }
                            .foregroundColor(.black)
                        
                        
                        
                        
                        VStack(){
                            
                            Spacer()
                            
                            if showingBone{
                                HStack{
                                    Image(systemName: "pawprint.circle")
                                    Divider()
                                    Text(displayedQuote)
                                        .id("Quote" + displayedQuote)
                                }
                                .padding()
                                .frame(minWidth: 100, maxWidth: 350, minHeight: 0, maxHeight: 250)
                                .background(Color("Athens Grey"))
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(color: .black, radius: 5, x: 5, y: 5)
                                .foregroundColor(.black)
                                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                                
                                Spacer()
                                
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
                                }
                                
                                Spacer()
                                
                            }
                            
                        }.frame(height: geo.size.height*0.65)
                        
                    }
                    
                    
                    .sheet(isPresented: $showingAddQuoteSheet){
                        quoteList(quotes: $quotes)
                    }
                    .sheet(isPresented: $showingSettingsSheet){
                        SettingsView(quotes: $quotes)
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
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
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
