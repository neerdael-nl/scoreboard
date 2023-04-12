//
//  Manage GameSessionsView.swift
//  Scoreboard
//
//  Created by John Neerdael on 10/04/2023.
//
// ManageGameSessionsView
import SwiftUI

struct ManageGameSessionsView: View {
    @Binding var games: [Game] // Change this line
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()

    var body: some View {
        List {
            ForEach(games) { game in
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
            .onAppear {
                games = loadGamesFromUserDefaults()
            }
        }
        .responsiveWidth(0.9)
    }
    
    func deleteGame(game: Game) {
        // Retrieve the current list of players and games
        var players = loadPlayersFromUserDefaults()
        var games = loadGamesFromUserDefaults()

        // Iterate through the playerResults in the game to be deleted
        for playerResult in game.playerResults {
            if let index = players.firstIndex(where: { $0.id == playerResult.player.id }) {
                // Update the player's score and games played count
                players[index].totalPoints -= playerResult.score
                players[index].gamesPlayed -= 1
            }
        }

        // Remove the game from the list
        games.removeAll { $0.id == game.id }

        // Save the updated players and games lists to UserDefaults
        savePlayersToUserDefaults(players: players)
        saveGamesToUserDefaults(games: games)

        // Update the binding
        self.games = games
    }
}
