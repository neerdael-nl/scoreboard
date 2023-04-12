import SwiftUI


struct PlayerGameHistoryView: View {
    let player: Player
    @Binding var games: [Game]

    
    private var playerGames: [Game] {
            games.filter { game in
                game.playerResults.contains(where: { $0.player.id == player.id })
            }
        }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
            List(playerGames) { game in
                VStack(alignment: .leading) {
                    Text(game.name)
                        .font(.headline)
                    if let playerResult = game.playerResults.first(where: { $0.player.id == player.id }) {
                        Text("Position: \(playerResult.position)")
                    }
                    Text("Date: \(dateFormatter.string(from: game.date))")
                }
            }
            .navigationTitle("\(player.name)'s Game History")
        }
    }
