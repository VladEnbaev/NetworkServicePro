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
    let priorities: [TaskPriority] = [.background, .high, .low, .medium]
    
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
                for path in paths {
                    let randomDuration = Int.random(in: 50...100)
                    let randomPriority = priorities.randomElement()
                    try? await Task.sleep(for: .nanoseconds(randomDuration))
                    Task.detached(priority: randomPriority) {
                        print("\(path): TASK_DETACHED priority: \(Task.currentPriority), interval: \(randomDuration), thread: \(Thread.current)")
                        let data = try await networkService.request(path: path)
                        print("Some data for \(path): \(data)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}