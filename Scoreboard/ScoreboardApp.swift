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
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                ContentView()
                    .environmentObject(scoreboardData)
                    .preferredColorScheme(.dark)
            }
            .responsiveWidth(0.9)
        }
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
            currentName += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "name" {
            let trimmedName = currentName.trimmingCharacters(in: .whitespacesAndNewlines)
            games.append(BoardGame(id: currentID, name: trimmedName))
            currentName = ""
        }
    }
}

func fetchBoardGames(username: String, completion: @escaping ([BGG]) -> Void) {
    let urlString = "https://boardgamegeek.com/xmlapi2/collection?username=\(username)&own=1"
    guard let url = URL(string: urlString) else { return }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            let parser = BoardGameXMLParser()
            let games = parser.parse(data: data)
            DispatchQueue.main.async {
                completion(games.map { BGG(id: $0.id, name: $0.name) }) // Convert BoardGame to BGG
            }
        }
    }.resume()
}

struct ResponsiveViewModifier: ViewModifier {
    let widthRatio: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width * widthRatio)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}


extension View {
    func responsiveWidth(_ widthRatio: CGFloat) -> some View {
        self.modifier(ResponsiveViewModifier(widthRatio: widthRatio))
    }
}
