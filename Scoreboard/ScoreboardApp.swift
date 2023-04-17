import SwiftUI

@main
struct ScoreboardApp: App {
    @StateObject private var scoreboardData = ScoreboardData()
    
    init() {
        // Set navigation bar background image
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(scoreboardData)
                    .preferredColorScheme(.dark)
                    .modifier(GlobalPaddingModifier(screenWidth: UIScreen.main.bounds.width, screenHeight: UIScreen.main.bounds.height))
            }
        }
    }
}

struct GlobalPaddingModifier: ViewModifier {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.leading, screenWidth * 0.05)
            .padding(.trailing, screenWidth * 0.05)
            .padding(.top, screenHeight * 0.05)
            .padding (.bottom, screenHeight * 0.05)
    }
}



struct BoardGame {
    let id: String
    let name: String

}

class BoardGameXMLParser: NSObject, XMLParserDelegate {
    var games: [BoardGame] = []
    var currentElement: String = ""
    var currentID: String = ""
    var currentName: String = ""

    func parse(data: Data) -> [BoardGame] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return games
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentID = attributeDict["objectid"] ?? ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "name" {
            currentName += string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name" {
            games.append(BoardGame(id: currentID, name: currentName))
            currentName = ""
        }
    }
}

func fetchBoardGames(username: String, completion: @escaping ([BGG]) -> Void) {
    let urlString = "https://boardgamegeek.com/xmlapi2/collection?username=\(username)&own=1&excludesubtype=boardgameexpansion"
    guard let url = URL(string: urlString) else { return }

    var request = URLRequest(url: url)
    request.timeoutInterval = 5

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 202 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    fetchBoardGames(username: username, completion: completion)
                }
                return
            }
        }

        if let data = data {
            let parser = BoardGameXMLParser()
            let games = parser.parse(data: data)
            DispatchQueue.main.async {
                completion(games.map { BGG(name: $0.name) }) // Convert BoardGame to BGG
            }
        }
    }
    task.resume()
}



