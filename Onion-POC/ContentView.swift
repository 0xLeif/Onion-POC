//
//  ContentView.swift
//  Onion-POC
//
//  Created by Leif on 10/18/21.
//

import SwiftUI
import OnionStash

struct SomeData: Layerable, Codable, Equatable {
  var id: String
  var title: String
  var importance: Int
  var tags: String
  
  func idLayer() -> String {
    id
  }
  
  func metaLayer() -> [String : String]? {
    ["tags": tags]
  }
  
  func valueLayer() -> Data {
    try! JSONEncoder().encode(self)
  }
}

extension SomeData: CustomStringConvertible {
  var description: String {
    """
    id: \(id)
    title: \(title)
    importance: \(importance)
    tags: \(tags)
    """
  }
}

struct ContentView: View {
  @State private var bank = OnionBank(stashableOnionTypes: OnionStash<SomeData>.self)
  
  private var sortedBankData: [Onion<SomeData>] {
    (bank.all[0] as? OnionStash<SomeData>)?.onionSet
      .sorted { $0.id < $1.id } ?? []
  }
  
  var body: some View {
    VStack {
      Form {
        ForEach(sortedBankData, id: \.self) { onion in
          Section(
            content: {
              VStack {
                HStack{
                  Text("ID Layer:")
                  Spacer()
                  Text(onion.id)
                }
                
                Divider()
                
                HStack{
                  Text("Meta Layer:")
                  Spacer()
                  Text(onion.meta?.description ?? "")
                }
                
                Divider()
                
                HStack{
                  Text("Value Layer:")
                  Spacer()
                  Text(try! JSONDecoder().decode(SomeData.self, from: onion.value!).description)
                }
              }
            },
            header: {
              Text(onion.id)
            }
          )
        }
      }
      Spacer()
      HStack {
        Button("Add") {
          bank.add(value: SomeData(id: "first-\(UUID())", title: "First Data!", importance: Int.random(in: 0 ... 100), tags: "first, 1st, one"))
        }
        .padding()
        Spacer()
        Button("Delete All") {
          try! bank.deleteAll()
        }
        .padding()
        Spacer()
        Button("Save") {
          try! bank.save()
        }
        .padding()
      }
    }
    .onAppear {
      try! bank.load()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
