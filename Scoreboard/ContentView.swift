import SwiftUI

struct ContentView: View {
    @EnvironmentObject var scoreboardData: ScoreboardData
    @State private var players: [Player] = loadPlayersFromUserDefaults()
    @State private var bggGames: [BGG] = [] // Change to store the selected game object



    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: UIScreen.main.bounds.height * 0.05)
                // Scoreboard
                Text("Scoreboard")
                List {
                    ForEach(scoreboardData.players.sorted(by: { p1, p2 in
                        if p1.gamesPlayed == 0 && p2.gamesPlayed == 0 { return false }
                        if p1.gamesPlayed == 0 { return false }
                        if p2.gamesPlayed == 0 { return true }
                        let p1Score = Double(p1.totalPoints) / Double(p1.gamesPlayed)
                        let p2Score = Double(p2.totalPoints) / Double(p2.gamesPlayed)
                        return p1Score > p2Score
                    }), id: \.id) { player in
                        if player.gamesPlayed > 0 {
                            NavigationLink(destination: PlayerGameHistoryView(player: player, games: $scoreboardData.games)) {
                                Text("\(player.name): \(Double(player.totalPoints) / Double(player.gamesPlayed), specifier: "%.1f")")
                            }
                        }
                    }
                }
                
                // Add Game Button
                NavigationLink(destination: AddGameView(players: $scoreboardData.players, games: $scoreboardData.games, bggGames: bggGames)) {
                    Text("Add Game")
                        .padding()
                }
            }
            .navigationBarTitle("Game Ranking", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            )
        }
    }
}
