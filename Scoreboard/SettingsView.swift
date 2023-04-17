import SwiftUI
import UIKit // Add this line

struct ExportData: Codable {
    var scoreboardData: ScoreboardData
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scoreboardData: ScoreboardData
    @State private var newScores: [Int] = []
    @State private var showResetAlert = false
    @State private var bggUsername: String = UserDefaults.standard.string(forKey: "bggUsername") ?? ""
    @State private var showAlert = false
    @State private var showDocumentBrowser = false
    @State private var alertMessage = ""
    @State private var selectedGame: BGG?
    @State private var boardGames: [BGG] = loadBGGFromUserDefaults()
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Manage Players")) {
                    NavigationLink(destination: ManagePlayersView(players: $scoreboardData.players)) {
                        Text("Edit Players")
                    }
                }
                
                Section(header: Text("Manage Game Sessions")) {
                    NavigationLink(destination: ManageGameSessionsView()) { // Update this line
                        Text("Remove Sessions")
                    }
                }
                
                Section(header: Text("Manage Game Library")) {
                    NavigationLink(destination: ManageBoardGamesView(boardGames: $boardGames)) {
                        Text("Edit Boardgames")
                    }
                    
                }
                
                Section(header: Text("BoardGameGeek")) {
                    TextField("Username", text: $bggUsername)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit {
                            UserDefaults.standard.set(bggUsername, forKey: "bggUsername")
                        }
                    
                    Button("Fetch Games") {
                        if !bggUsername.isEmpty {
                            UserDefaults.standard.set(bggUsername, forKey: "bggUsername")
                            fetchGames()
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Fetch Complete"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                }
                Button(action: {
                    exportScoreboardData()
                }) {
                    Text("Export Data")
                }
                
                Button(action: {
                    showDocumentBrowser.toggle()
                }) {
                    Text("Import Data")
                }
                .sheet(isPresented: $showDocumentBrowser) {
                    DocumentBrowser(scoreboardData: scoreboardData)
                }
                Button("Reset Database") {
                    showResetAlert = true
                }
                .alert(isPresented: $showResetAlert) {
                    Alert(
                        title: Text("Reset Database"),
                        message: Text("Are you sure you want to reset the database?"),
                        primaryButton: .destructive(Text("Reset")) {
                            resetDatabase()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationBarTitle("Settings")
            .accessibilityElement(children: .combine)
        }
    }
    
    private func clearBoardGamesFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "boardGames")
    }
    
    private func resetDatabase() {
        clearPlayersFromUserDefaults()
        clearGamesFromUserDefaults()
        clearBoardGamesFromUserDefaults()
        scoreboardData.players = []
        scoreboardData.games = []
        boardGames = []
    }
    
    private func fetchGames() {
        fetchBoardGames(username: bggUsername) { fetchedGames in
            let uniqueFetchedGames = Array(Set(fetchedGames)) // Remove duplicates from fetched games
            let filteredGames = uniqueFetchedGames.filter { fetchedGame in
                !boardGames.contains(where: { $0.id == fetchedGame.id })
            }
            
            let updatedBoardGames = (boardGames + filteredGames).sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            saveBGGToUserDefaults(boardGames: updatedBoardGames)
            let addedCount = filteredGames.count
            let duplicateCount = uniqueFetchedGames.count - addedCount
            alertMessage = "Fetched \(uniqueFetchedGames.count) games. Added \(addedCount) games. Skipped \(duplicateCount) duplicates."
            showAlert = true
            boardGames = updatedBoardGames
        }
    }
    // Add this Coordinator class within the SettingsView
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {
        @Binding var isPresented: Bool
        var completionHandler: ((URL) -> Void)?
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            
            completionHandler?(url)
            isPresented = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            isPresented = false
        }
    }
    
    func exportScoreboardData() {
        if let data = scoreboardData.exportScoreboardData() {
            let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent("scoreboard_data.json")
            do {
                try data.write(to: exportURL)
                let picker = UIDocumentPickerViewController(forExporting: [exportURL], asCopy: true)
                let coordinator = Coordinator(isPresented: .constant(false))
                picker.delegate = coordinator
                UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive })
                    .map({ $0 as? UIWindowScene })
                    .flatMap({ $0?.windows.first })
                    .map({ $0.rootViewController?.present(picker, animated: true) })
            } catch {
                print("Error exporting scoreboard data: \(error)")
            }
        }
    }
    
    func importScoreboardData() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        let coordinator = Coordinator(isPresented: .constant(false))
        picker.delegate = coordinator
        picker.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        coordinator.completionHandler = { url in
            do {
                let data = try Data(contentsOf: url)
                self.scoreboardData.importScoreboardData(from: data)
            } catch {
                print("Error importing scoreboard data: \(error)")
            }
        }
        UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .flatMap({ $0?.windows.first })
            .map({ $0.rootViewController?.present(picker, animated: true) })
    }
}

struct DocumentBrowser: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var scoreboardData: ScoreboardData

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentBrowserViewController {
        let browser = UIDocumentBrowserViewController(forOpening: [.json])
        browser.delegate = context.coordinator
        return browser
    }

    func updateUIViewController(_ uiViewController: UIDocumentBrowserViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentBrowserViewControllerDelegate {
        var parent: DocumentBrowser

        init(_ parent: DocumentBrowser) {
            self.parent = parent
        }

        func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                do {
                    let data = try Data(contentsOf: url)
                    parent.scoreboardData.importScoreboardData(from: data)
                    parent.presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Error importing scoreboard data: \(error)")
                }
            }
        }
    }
}
