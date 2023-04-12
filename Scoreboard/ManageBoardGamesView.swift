import SwiftUI

struct ManageBoardGamesView: View {
    @Binding var boardGames: [BGG]
    @State private var newGameName: String = ""
    @State private var showingAddGameSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            List {
                ForEach(boardGames, id: \.id) { game in
                    Text(game.name)
                }
                .onDelete(perform: deleteGame)
            }

            Button("Add Game") {
                showingAddGameSheet.toggle()
            }
            .sheet(isPresented: $showingAddGameSheet) {
                VStack {
                    TextField("Game Name", text: $newGameName)
                        .padding()

                    Button("Save") {
                        if newGameName.isEmpty {
                            alertMessage = "Game name cannot be empty."
                            showAlert = true
                        } else if boardGames.contains(where: { $0.name.lowercased() == newGameName.lowercased() }) {
                            alertMessage = "Game already exists."
                            showAlert = true
                        } else {
                            let newGame = BGG(id: UUID().uuidString, name: newGameName)
                            boardGames.append(newGame)
                            saveBGGToUserDefaults(boardGames: boardGames)
                            newGameName = ""
                            showingAddGameSheet.toggle()
                        }
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
        .navigationBarTitle("Manage Board Games")
    }

    private func deleteGame(at offsets: IndexSet) {
        boardGames.remove(atOffsets: offsets)
        saveBGGToUserDefaults(boardGames: boardGames)
    }
}
