import SwiftUI
import Combine

class ScoreboardData: ObservableObject {
    @Published var players: [Player]
    @Published var games: [Game]

    //


    init() {
        self.players = loadPlayersFromUserDefaults()
        self.games = loadGamesFromUserDefaults()
    }
}
