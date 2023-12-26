//
//  ContentView.swift
//  NetworkServicePro
//
//  Created by Влад Енбаев on 24.12.2023.
//

import SwiftUI

struct ContentView: View {
    
    let networkService = NetworkService()
    let paths = ["one", "two", "three", "four", "five", "six", "seven", "nine", "ten"]
    let priorities: [TaskPriority] = [.background, .high, .low, .medium, .userInitiated, .utility]
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                for i in 0...500 {
                    let randomDuration = Int.random(in: 1...100)
                    let randomPriority = priorities.randomElement()
                    try? await Task.sleep(for: .nanoseconds(1000))
                    Task.detached(priority: randomPriority) {
                        print("\(i): TASK_DETACHED priority: \(Task.currentPriority), interval: \(randomDuration), thread: \(Thread.current)")
                        let data = try await networkService.request(path: i.description)
                        print("Some data for \(i): \(data)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
