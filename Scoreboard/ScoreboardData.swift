import SwiftUI
import Combine

class ScoreboardData: ObservableObject {
    @Published var players: [Player]
    @Published var games: [Game]
    @Published var scores: [Int] = [4, 3, 2, 1] // Add this line

    //


    init() {
        self.players = loadPlayersFromUserDefaults()
        self.games = loadGamesFromUserDefaults()
    }
}
