/*:
⬇️ *Vous pouvez ignorez le code ci-dessous, il nous permet juste d'initialiser et de visualiser le canvas à droite.*
 */
import PlaygroundSupport
let canvas = Canvas()
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = canvas

/*:
 - - -
 # Découverte du canevas
 Le canevas, c'est l'étendue de pelouse verte qui se trouve sur la droite 🌿.
 Sur ce canevas, nous allons pouvoir dessiner notre route. Et nous allons faire cela en utilisant les fonctions proposées par le canevas :
 ## Route

 `canvas.createRoadSection()`
 - 🛣 Cette fonction permet de **créer une section de route**. A chaque appel de cette fonction, une nouvelle section de route est crée.

 `canvas.createHomeRoadSection()`
 - 🛣🏠 Similaire à la précédente, cette fonction permet de créer une section de route **qui contient une maison**.

 `canvas.createSchoolRoadSection()`
 - 🛣🏫 Similaire à la précédente, cette fonction permet de créer une section de route **qui contient une école**.

 ## Bus
 `canvas.moveBusForward()`

 - 🚌➡️ Cette fonction permet de faire avancer le bus jusqu'à la section de route suivante. Attention, le bus ne peut pas avancer s'il n'y a plus de route devant lui.

 `canvas.stopBus()`
 - 🚌🛑 Cette fonction permet de faire marquer un arrêt au bus.

 ## A vous de jouer !
 */
class Bus {
    var driverName : String
    var seats = 20
    var occupiedSeats = 0 {
        willSet {
            print("Il y a du mouvement dans le bus...")
        }
        didSet {
            if occupiedSeats < oldValue {
                print("\(oldValue - occupiedSeats) personnes viennent de descendre !")
            }
            else {
                print("\(occupiedSeats - oldValue) personnes viennent de monter !")
            }
        }
    }
    
    var description : String {
        return "Je suis un bus conduit par \(driverName) avec \(occupiedSeats) personnes dedans."
    }
    
    init(driverName : String) {
        self.driverName = driverName
    }
    
    func moveForward() {
        canvas.moveBusForward()
    }
    
    func stop () {
        canvas.stopBus()
    }
    
    func drive (road : Road) {
        for _ in road.sections {
            moveForward()
        }
    }
}

class SchoolBus : Bus {
    var schoolName = ""
    
    override func drive(road: Road) {
        for sectionIndex in road.sections {
            switch sectionIndex.type {
                case .plain :
                    moveForward()
                case .home :
                    if let homeRoadSection = sectionIndex as? HomeRoadSection {
                        if shouldPickChildren(from: homeRoadSection) {
                            stop()
                            pickChildren(from: homeRoadSection)
                        }
                        else {
                            print("Le bus est plein...")
                        }
                    }
                    moveForward()
                case .school :
                    dropChildren()
                    stop()
            }
            print(description)
        }
    }
    
    private func shouldPickChildren(from homeRoadSection : HomeRoadSection) -> Bool {
        return occupiedSeats + homeRoadSection.children < seats
    }
    
    private func pickChildren(from homeRoadSection : HomeRoadSection) {
        occupiedSeats += homeRoadSection.children
    }
    
    private func dropChildren() {
        occupiedSeats = 0
    }
}
enum RoadSectionType {
    case plain
    case home
    case school
}

class RoadSection {
    var type : RoadSectionType
    
    init(type : RoadSectionType) {
        self.type = type
        switch type {
            case .plain :
                canvas.createRoadSection()
            case .home :
                canvas.createHomeRoadSection()
            case .school :
                canvas.createSchoolRoadSection()
        }
    }
    
    convenience init() {
        self.init(type : .plain)
    }
}

class HomeRoadSection : RoadSection {
    var children : Int
    
    init(children : Int) {
        self.children = children
        super.init(type: .home)
    }
    
    convenience init() {
        self.init(children : 2)
    }
}

class SchoolRoadSection : RoadSection {
    init() {
        super.init(type: .school)
    }
}

class Road {
    static var maxLength = 77
    
    static func createStraightRoad() -> Road {
        return Road(length: 11)
    }
    
    static func createRoadToSchool(length : Int) -> Road {
        let road = Road()
        for i in 0..<length {
            if i%3 == 1 {
                road.sections.append(HomeRoadSection(children: Int.random(in: 1..<6)))
            } else {
                road.sections.append(RoadSection(type: .plain))
            }
        }
        road.sections.append(SchoolRoadSection())
        return road
    }
    var sections = [RoadSection]()
    
    init() {}
    
    init(length: Int) {
        var length = length
        if length > Road.maxLength {
            length = Road.maxLength
        }
        for _ in 0..<length {
            self.sections.append(RoadSection(type : .plain))
        }
    }
}

var road = Road.createRoadToSchool(length: 55)
var unBusScolaire = SchoolBus(driverName: "Joe")
unBusScolaire.seats = 41
unBusScolaire.drive(road: road)

