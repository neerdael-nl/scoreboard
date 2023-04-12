import SwiftUI


struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scoreboardData: ScoreboardData
    @State private var newScores: [Int] = []
    @State private var showResetAlert = false
    @State private var bggUsername: String = UserDefaults.standard.string(forKey: "bggUsername") ?? ""
    @State private var showAlert = false
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
                    NavigationLink(destination: ManageGameSessionsView(games: $scoreboardData.games)) { // Update this line
                        Text("Edit Game Sessions")
                    }
                }
                
                Section(header: Text("Manage Game Librart")) {
                    NavigationLink(destination: ManageBoardGamesView(boardGames: $boardGames)) {
                        Text("Manage Board Games")
                    }

                }
                
                Section(header: Text("BoardGameGeek")) {
                    TextField("Username", text: $bggUsername)
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
        }
    }
    
    private func resetDatabase() {
        clearPlayersFromUserDefaults()
        clearGamesFromUserDefaults()
        scoreboardData.players = []
        scoreboardData.games = []
    }
    
    private func fetchGames() {
        fetchBoardGames(username: bggUsername) { fetchedGames in
            saveBGGToUserDefaults(boardGames: fetchedGames)
            alertMessage = "Fetched \(fetchedGames.count) games"
            showAlert = true
            boardGames = fetchedGames // update the state with fetched games
        }
    }

    
}
