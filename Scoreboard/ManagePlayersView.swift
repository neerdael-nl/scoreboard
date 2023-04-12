import SwiftUI

struct ManagePlayersView: View {
    @Binding var players: [Player]
    @State private var newPlayerName: String = ""
    @FocusState private var isFocused: Bool
    @State private var showingDuplicateAlert = false
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Add a new player", text: $newPlayerName, onCommit: {
                        if !newPlayerName.isEmpty {
                            addPlayer()
                            newPlayerName = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isFocused)

                    Button(action: {
                        if !newPlayerName.isEmpty {
                            addPlayer()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
                .padding()

                ForEach(players) { player in
                    HStack {
                        TextField("Edit player name", text: Binding(
                            get: { player.name },
                            set: { newValue in
                                if let index = players.firstIndex(where: { $0.id == player.id }) {
                                    players[index].name = newValue
                                    savePlayersToUserDefaults(players: players)
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Spacer()
                        
                        Button(action: {
                            deletePlayer(player: player)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("Manage Players")
            .alert(isPresented: $showingDuplicateAlert) {
                Alert(title: Text("Duplicate Name"),
                      message: Text("Player names must be unique."),
                      dismissButton: .default(Text("OK")) {
                        newPlayerName = ""
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                      })
            }
        }
        .responsiveWidth(0.9)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
    
    private func addPlayer() {
        // Check if the player name already exists
        guard !players.contains(where: { $0.name.lowercased() == newPlayerName.lowercased() }) else {
            showingDuplicateAlert = true
            return
        }
        
        let newPlayer = Player(name: newPlayerName)
        players.append(newPlayer)
        savePlayersToUserDefaults(players: players)
        newPlayerName = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFocused = true
        }
    }
    
    private func deletePlayer(player: Player) {
        players.removeAll { $0.id == player.id }
        savePlayersToUserDefaults(players: players)
    }
}
