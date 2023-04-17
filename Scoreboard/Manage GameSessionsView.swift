//
//  Manage GameSessionsView.swift
//  Scoreboard
//
//  Created by John Neerdael on 10/04/2023.
//
// ManageGameSessionsView
import SwiftUI

struct ManageGameSessionsView: View {
    @EnvironmentObject var scoreboardData: ScoreboardData
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(scoreboardData.games) { game in
                HStack {
                    VStack(alignment: .leading) {
                        Text(game.name)
                            .font(.headline)
                        Text("Played on \(dateFormatter.string(from: game.date))")
                            .font(.subheadline)
                    }
                    Spacer()
                    Button(action: {
                        deleteGame(game: game)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Manage Game Sessions")
        }
    }
    
    func deleteGame(game: Game) {
        // Iterate through the playerResults in the game to be deleted
        for playerResult in game.playerResults {
            if let index = scoreboardData.players.firstIndex(where: { $0.id == playerResult.player.id }) {
                // Update the player's score and games played count
                scoreboardData.players[index].totalPoints -= playerResult.score
                scoreboardData.players[index].gamesPlayed -= 1
            }
        }
        
        // Remove the game from the list
        scoreboardData.games.removeAll { $0.id == game.id }
        
        // Save the updated players and games lists to UserDefaults
        savePlayersToUserDefaults(players: scoreboardData.players)
        saveGamesToUserDefaults(games: scoreboardData.games)
    }
}
