import Foundation

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

public func exampleTwo (of description : String, action : () -> ()){
    print("\n--- Example Two of:", description, "---")
    action()
}

public func exampeThree (of description : String, action : () -> ()){
    print("\n--- Example Three of:", description, "---")
    action()
}

public func exampleFour (of description : String, action : () -> ()){
    print("\n--- Example Four of:", description, "---")
    action()
}

public func exampleFive (of description : String, action : () -> ()){
    print("\n--- Example Five of:", description, "---")
    action()
}


public func exampleSingle (of description : String, action : () -> ()){
    print("\n--- Example Single of:", description, "---")
    action()
}


public func exampleCompletable (of description : String, action : () -> ()){
    print("\n--- Example Completable of:", description, "---")
    action()
}

public func exampleMaybe (of description : String, action : () -> ()){
    print("\n--- Example Completable of:", description, "---")
    action()
}

public func delay (_ delay : TimeInterval, action : @escaping () -> ()){
    DispatchQueue.main.asyncAfter(deadline: .now() + delay){
        action()
    }
}


