import SwiftUI


func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(from: NSNumber(value: n)) ?? ""
}

struct MultiPicker<DataElement: Hashable, LabelView: View, ItemView: View>: View {
    private let data: [DataElement]
    private let label: LabelView
    private let itemContent: (DataElement) -> ItemView
    private let selection: Binding<Set<DataElement>>

    init(data: [DataElement], label: LabelView, selection: Binding<Set<DataElement>>, @ViewBuilder itemContent: @escaping (DataElement) -> ItemView) {
        self.data = data
        self.label = label
        self.itemContent = itemContent
        self.selection = selection
    }

    var body: some View {
        Picker(selection: selection.animation(), label: label) {
            ForEach(data, id: \.self) { value in
                itemContent(value)
                    .tag(value)
            }
        }
    }
}

struct AddGameView: View {
    @Binding var players: [Player]
    @Binding var games: [Game]
    @State private var selectedPositions: [Player: Int] = [:]
    @State private var participatingPlayers: Set<Player> = []
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedGameIndex = 0
    @State private var selectedGame: BGG? // Add this line
    @State private var selectedPlayers: Set<Player> = []
    @State private var showAlert = false
    @State private var gameDate = Date() // new state variable for the game date
    @State private var currentStep: Int = 1
    @State private var isExpanded = false
    @Binding var boardGames: [BGG]
  
    init(players: Binding<[Player]>, games: Binding<[Game]>, boardGames: Binding<[BGG]>) {
        self._players = players
        self._games = games
        self._boardGames = boardGames // Update this line
        self._selectedGame = State(initialValue: boardGames.wrappedValue.first)
    }
    
    func gameSelectionView(scrollViewProxy: ScrollViewProxy) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                VStack {
                    Text("Select Game")
                        .font(.title)
                        .padding()

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(gameSections(), id: \.0) { section in
                                Section(header: Text(section.0).frame(maxWidth: .infinity, alignment: .leading)) {
                                    ForEach(section.1, id: \.id) { game in
                                        Button(action: {
                                            selectedGame = game
                                        }) {
                                            HStack {
                                                Text(game.name)
                                                Spacer()
                                                if selectedGame?.id == game.id {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)

                VStack {
                    ForEach(0..<alphabet.count, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                scrollToLetter(proxy: scrollViewProxy, at: index)
                            }
                        }) {
                            Text(String(alphabet[index]))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.trailing)
            }
        }
    }   



    
    var body: some View {
        VStack(alignment: .leading) {
            if currentStep == 1 {
                ScrollViewReader { scrollViewProxy in
                    gameSelectionView(scrollViewProxy: scrollViewProxy)
                }
            } else if currentStep == 2 {
                participantSelectionView()
            } else if currentStep == 3 {
                rankingSelectionView()
            } else if currentStep == 4 {
                overviewView()
            }

            HStack {
                if currentStep > 1 {
                    Button("Previous") {
                        currentStep -= 1
                    }
                }

                Spacer()

                if currentStep < 4 {
                    Button("Next") {
                        if currentStep == 2 {
                            participatingPlayers = selectedPlayers
                        }
                        currentStep += 1
                    }
                    .disabled(currentStep == 1 && selectedGame == nil) // Change the validation condition here
                } else {
                    Button("Confirm") {
                        saveGame()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(participatingPlayers.isEmpty || selectedGame == nil) // Change the validation condition here
                }
            }
            .padding()
        }
        .padding()
    }
    
    func participantSelectionView() -> some View {
        VStack {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text("Select Players")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            if isExpanded {
                VStack(alignment: .leading) {
                    ForEach(players, id: \.id) { player in
                        Button(action: {
                            if let index = selectedPlayers.firstIndex(of: player) {
                                selectedPlayers.remove(at: index)
                            } else {
                                selectedPlayers.insert(player)
                            }
                        }) {
                            HStack {
                                Text(player.name)
                                Spacer()
                                if selectedPlayers.contains(player) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .animation(.easeInOut(duration: 0.25))
    }
    var isGameNameValid: Bool {
        return (selectedGame?.name ?? "").isEmpty && (selectedGameIndex > 0 || !participatingPlayers.isEmpty)
    }
    
    
    func rankingSelectionView() -> some View {
        VStack {
            Text("Assign positions")
                .font(.headline)
                .padding()
            
            List(participatingPlayers.sorted(by: { $0.name < $1.name }), id: \.id) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Picker("", selection: Binding(get: {
                        selectedPositions[player] ?? 0
                    }, set:     { newValue in
                        selectedPositions[player] = newValue
                    })) {
                        ForEach(0...4, id: \.self) { position in
                            Text(position == 0 ? "0 (participated, no points)" : "\(ordinal(position)): \(position == 1 ? "1st" : position == 2 ? "2nd" : position == 3 ? "3rd" : "\(position)th")")
                                .tag(position)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    .frame(width: 150)
                }
            }
            .disabled(participatingPlayers.isEmpty)
            
            DatePicker("Date Played", selection: $gameDate, displayedComponents: .date)
                .padding()
        }
    }
    
    func overviewView() -> some View {
        VStack {
            Text("Game Overview")
                .font(.headline)
                .padding()
            
            Text("Game Name: \(selectedGame?.name ?? "")")
                .padding(.bottom)
            
            Text("Participants:")
                .padding(.bottom)
            
            ForEach(participatingPlayers.sorted(by: { $0.name < $1.name }), id: \.id) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Text("Position: \(ordinal(selectedPositions[player] ?? 0))")
                }
            }
            
            Text("Date Played: \(formattedDate(gameDate))")
                .padding(.top)
            
            
            Button("Save Game") {
                saveGame()
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .disabled(participatingPlayers.isEmpty || !isGameNameValid)
            
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func gameSections() -> [(String, [BGG])] {
        let sortedGames = boardGames.sorted { $0.name < $1.name }
        let groupedGames = Dictionary(grouping: sortedGames, by: { String($0.name.prefix(1)).uppercased() })
        let sections = groupedGames.sorted { $0.0 < $1.0 }
        print("Sections: \(sections)")
        return sections
    }
    
    // Fast scroller functionality
    private let alphabet = (65...90).map { UnicodeScalar($0) }.compactMap { $0.map(String.init) }
    
    private func scrollToLetter(proxy: ScrollViewProxy, at index: Int) {
        if let section = gameSections().first(where: { $0.0 == alphabet[index] }) {
            if let firstGame = section.1.first {
                withAnimation {
                    proxy.scrollTo(firstGame.id, anchor: .top)
                }
            }
        }
    }
    
    
    private func saveGame() {
        if (selectedGame?.name ?? "").isEmpty == true || (selectedGame?.name ?? "").isEmpty || participatingPlayers.count < 2 || _games.wrappedValue.contains(where: { $0.name == selectedGame?.name || $0.name == selectedGame?.name }) {
            showAlert = true
            return
        }
        
        let sortedParticipatingPlayers = participatingPlayers.sorted(by: { selectedPositions[$0] ?? 0 < selectedPositions[$1] ?? 0 })
        
        let playerResults = sortedParticipatingPlayers.enumerated().map { (index, player) -> PlayerResult in
            let score: Double = 10.0 * (Double(sortedParticipatingPlayers.count - index) / Double(sortedParticipatingPlayers.count))
            return PlayerResult(player: player, position: index + 1, score: score)
        }
        
        let newGame = Game(name: selectedGame?.name ?? "", playerResults: playerResults)
        games.append(newGame)
        saveGamesToUserDefaults(games: games)
        
        for result in playerResults {
            if let playerIndex = players.firstIndex(where: { $0.id == result.player.id }) {
                players[playerIndex].totalPoints += result.score
                players[playerIndex].gamesPlayed += 1
            }
        }
        
        savePlayersToUserDefaults(players: players)
        presentationMode.wrappedValue.dismiss()
    }
}
