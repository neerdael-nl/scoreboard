import SwiftUI

struct ManagePlayersView: View {
    @Binding var players: [Player]
    @State private var newPlayerName: String = ""
    @State private var showingAddPlayerSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            List {
                ForEach(players, id: \.id) { player in
                    Text(player.name)
                }
                .onDelete(perform: deletePlayer)
            }

            Button("Add Player") {
                showingAddPlayerSheet.toggle()
            }
            .sheet(isPresented: $showingAddPlayerSheet) {
                VStack {
                    TextField("Player Name", text: $newPlayerName)
                        .padding()

                    Button("Save") {
                        if newPlayerName.isEmpty {
                            alertMessage = "Player name cannot be empty."
                            showAlert = true
                        } else if players.contains(where: { $0.name.lowercased() == newPlayerName.lowercased() }) {
                            alertMessage = "Player already exists."
                            showAlert = true
                        } else {
                            let newPlayer = Player(name: newPlayerName)
                            players.append(newPlayer)
                            savePlayersToUserDefaults(players: players)
                            newPlayerName = ""
                            showingAddPlayerSheet.toggle()
                        }
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
        .navigationBarTitle("Manage Players")
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
        savePlayersToUserDefaults(players: players)
    }
}
