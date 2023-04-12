import SwiftUI

struct AddPlayerView: View {
    @Binding var players: [Player]
    @State private var playerName = ""
    @State private var showDuplicatePlayerAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Spacer().frame(height: UIScreen.main.bounds.height * 0.05)
        VStack {
            TextField("Player Name", text: $playerName)
                .padding()
                .cornerRadius(8.0)
                .onSubmit {
                    addPlayer()
                }

            Button("Add Player") {
                            if !playerName.isEmpty {
                                players.append(Player(name: playerName))
                                savePlayersToUserDefaults(players: players)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }

            if players.count > 0 {
                Text("Existing Players")
                List {
                    ForEach(players) { player in
                        Text(player.name)
                    }
                    .onDelete(perform: deletePlayer)
                }
            }
        }
        .alert(isPresented: $showDuplicatePlayerAlert) {
            Alert(
                title: Text("Duplicate Player"),
                message: Text("A player with the same name already exists."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func addPlayer() {
        if playerName.isEmpty {
            return
        }
        
        if !players.contains(where: { $0.name == playerName }) {
            let newPlayer = Player(name: playerName)
            players.append(newPlayer)
            playerName = ""
        } else {
            showDuplicatePlayerAlert = true
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}
