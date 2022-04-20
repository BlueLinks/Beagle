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
                }
                .padding()
                .background(Color(red: 242/255, green: 242/255, blue: 247/255))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .foregroundColor(.black)
                .frame(minWidth: 250, maxWidth: 500, minHeight: 0, maxHeight: 250)
                
                Button("Get some motivation!"){
                    displayedQuote = quotes.randomElement()?.text ?? "Enter some quotes!"
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
