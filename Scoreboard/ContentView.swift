import SwiftUI

struct ContentView: View {
    @EnvironmentObject var scoreboardData: ScoreboardData
    @State private var players: [Player] = loadPlayersFromUserDefaults()
    @State private var games: [Game] = []
    @State private var boardGames: [BGG] = []




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
                .onAppear {
                    boardGames = loadBGGFromUserDefaults()
                }
                
                // Add Game Button
                NavigationLink(destination: AddGameView(players: $players, games: $games, boardGames: $boardGames)) {
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
