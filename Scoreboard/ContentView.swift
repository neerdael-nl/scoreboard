import SwiftUI

struct ContentView: View {
    @EnvironmentObject var scoreboardData: ScoreboardData
    @State private var boardGames: [BGG] = []
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    
    private var sortedPlayers: [Player] {
        scoreboardData.players.sorted(by: { $0.averageScore > $1.averageScore })
    }
    
    private func playerRow(player: Player, index: Int) -> some View {
            NavigationLink(destination: PlayerDetailView(player: player)) {
                HStack {
                    if index == 0 {
                        Image("gold_cup")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                    } else if index == 1 {
                        Image("silver_cup")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                    } else if index == 2 {
                        Image("bronze_cup")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                    }
                    
                    Text(player.name)
                        .background(Color.clear)
                    Spacer()
                    Text("\(player.averageScore, specifier: "%.0f") Points")
                        .background(Color.clear)
                }
                .listRowBackground(Color.clear)
            }
            .listRowBackground(Color.clear)
        }
    
    var body: some View {
        NavigationView {
            VStack {
                // Scoreboard
                Text("Scoreboard")
                List {
                    ForEach(sortedPlayers.indices, id: \.self) { index in
                        if sortedPlayers[index].totalPoints > 0 {
                            playerRow(player: sortedPlayers[index], index: index)
                        }
                    }
                }
                .onAppear {
                    boardGames = loadBGGFromUserDefaults()
                }

                // Add Game Button
                NavigationLink(destination: AddGameView(boardGames: $boardGames)) {
                    Text("Add Game")
                        .padding()
                }
            }
            .navigationBarTitle("Game Ranking", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: SettingsView()
                                        .environmentObject(scoreboardData)) {
                Image(systemName: "gearshape")
            }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force the NavigationView to use the stack style
        .environmentObject(scoreboardData) // Add this line
    }
}
    

