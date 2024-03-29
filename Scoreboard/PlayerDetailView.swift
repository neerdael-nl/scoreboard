import SwiftUI


struct PlayerDetailView: View {
    @EnvironmentObject var scoreboardData: ScoreboardData
    let player: Player

    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()
    
    init(player: Player, game: Game? = nil) { // make the game parameter optional with a default value of nil
        self.player = player
        dateFormatter.dateStyle = .long
    }
    
    var body: some View {
            List {
                ForEach(scoreboardData.games.filter { game in
                    game.playerResults.contains { $0.player.id == player.id }
                }.sorted { $0.date > $1.date }, id: \.id) { game in
                    HStack {
                        Text(game.name)
                        Spacer()
                        Text("Played on: \(dateFormatter.string(from: game.date))")
                        Spacer()
                        Text("Position: \(game.playerResults.first(where: { $0.player == player })?.position ?? 0)")
                    }
                }
            }
            .navigationBarTitle(player.name)
        }
    }
