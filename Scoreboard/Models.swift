//
//  Models.swift
//  Scoreboard
//
//  Created by John Neerdael on 09/04/2023.
//
// Test 
import Foundation

struct Player: Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var totalPoints: Double
    var gamesPlayed: Int
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.totalPoints = 0
        self.gamesPlayed = 0
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        totalPoints = try container.decode(Double.self, forKey: .totalPoints)
        gamesPlayed = try container.decode(Int.self, forKey: .gamesPlayed)
    }
    
    mutating func updateScore(newScore: Double, isAdding: Bool) {
        if isAdding {
            totalPoints += newScore
            gamesPlayed += 1
        } else {
            totalPoints -= newScore
            gamesPlayed -= 1
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }

    // Add this computed property to the Player struct
    var averageScore: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(totalPoints) / Double(gamesPlayed) * 10 / 4
    }
}

struct Game: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let playerResults: [PlayerResult]
    let date: Date = Date() // add a default value for the new property


    init(id: UUID = UUID(), name: String, playerResults: [PlayerResult]) {
        self.id = id
        self.name = name
        self.playerResults = playerResults

    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        playerResults = try container.decode([PlayerResult].self, forKey: .playerResults)
    }

    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct PlayerResult: Codable {
    let player: Player
    let position: Int
    let score: Double // Add this line

}

struct BGG: Codable, Identifiable {
    let id: String
    let name: String
}


func savePlayersToUserDefaults(players: [Player]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(players) {
        UserDefaults.standard.set(data, forKey: "players")
    }
}

func loadPlayersFromUserDefaults() -> [Player] {
    let decoder = JSONDecoder()
    if let data = UserDefaults.standard.data(forKey: "players"),
       let players = try? decoder.decode([Player].self, from: data) {
        return players
    } else {
        return []
    }
}

func saveGamesToUserDefaults(games: [Game]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(games) {
        UserDefaults.standard.set(data, forKey: "games")
    }
}

func loadGamesFromUserDefaults() -> [Game] {
    let decoder = JSONDecoder()
    if let data = UserDefaults.standard.data(forKey: "games"),
       let games = try? decoder.decode([Game].self, from: data) {
        return games
    } else {
        return []
    }
}

func clearPlayersFromUserDefaults() {
    UserDefaults.standard.removeObject(forKey: "players")
}

func clearGamesFromUserDefaults() {
    UserDefaults.standard.removeObject(forKey: "games")
}

func saveBGGToUserDefaults(boardGames: [BGG]) {
    if let data = try? JSONEncoder().encode(boardGames) {
        UserDefaults.standard.set(data, forKey: "boardGames")
    }
}

func loadBGGFromUserDefaults() -> [BGG] {
    if let data = UserDefaults.standard.data(forKey: "boardGames"),
       let boardGames = try? JSONDecoder().decode([BGG].self, from: data) {
        return boardGames
    } else {
        return []
    }
}
