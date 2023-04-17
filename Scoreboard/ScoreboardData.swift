import SwiftUI
import Combine

class ScoreboardData: ObservableObject, Codable {
    @Published var players: [Player]
    @Published var games: [Game]
    
    private enum CodingKeys: CodingKey {
        case players
        case games
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        players = try container.decode([Player].self, forKey: .players)
        games = try container.decode([Game].self, forKey: .games)
        calculateScoresAndGamesPlayed()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players, forKey: .players)
        try container.encode(games, forKey: .games)
    }

    //
    func calculateScoresAndGamesPlayed() {
        // Reset all player scores and games played
        for index in players.indices {
            players[index].totalPoints = 0
            players[index].gamesPlayed = 0
        }

        // Iterate through all games and update player scores and games played
        for game in games {
            for result in game.playerResults {
                if let playerIndex = players.firstIndex(where: { $0.id == result.player.id }) {
                    players[playerIndex].totalPoints += result.score
                    players[playerIndex].gamesPlayed += 1
                }
            }
        }
    }
    
    init() {
        self.players = loadPlayersFromUserDefaults()
        self.games = loadGamesFromUserDefaults()
        calculateScoresAndGamesPlayed()
    }
    // Export function
    func exportScoreboardData() -> Data? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return data
        } else {
            return nil
        }
    }

    // Import function
    func importScoreboardData(from data: Data) {
        let decoder = JSONDecoder()
        if let scoreboardData = try? decoder.decode(ScoreboardData.self, from: data) {
            self.players = scoreboardData.players
            self.games = scoreboardData.games
            savePlayersToUserDefaults(players: self.players)
            saveGamesToUserDefaults(games: self.games)
            calculateScoresAndGamesPlayed()
        }
    }
}
