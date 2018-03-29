//: Please build the scheme 'RxSwiftPlayground' first
import PlaygroundSupport
import RxSwift

//OPERADORES
example(of: "just") {
    let myObservable = Observable.just("AQUI ANDRES")
    myObservable.subscribe({ (myEvent : Event<String>) in
        print(myEvent)
    })
}

example(of: "of") {
    let myObservable = Observable.of(1,2,3,4)
    myObservable.subscribe({
        print($0)
    })
}


example(of: "from") {
    
    let disposeBag = DisposeBag()
    
    let subscription = Observable.from([1,2,3])
        .subscribe(onNext:{
            print($0)
        })
    subscription.disposed(by: disposeBag)
    
    
    Observable.from([4,5,6,7])
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("Completado")
        }, onDisposed: {
            print("Disposed")
        })
        .disposed(by: disposeBag)
}

example(of: "Error") {
    enum MyError : Error{
        case test
    }
    
    let disposeBag = DisposeBag()
    
    Observable<Void>.error(MyError.test)
        .subscribe(onError:{
            print($0)
        })
        .disposed(by: disposeBag)
}

// OPERADORES
exampleTwo(of: "PublishSubjetc") {
    
    let subject = PublishSubject<String>()
    let disposeBag = DisposeBag()
    subject.subscribe({
        print($0)
    })
        .disposed(by: disposeBag)
    
    enum MyError : Error{
        case testTwo
    }
    
    //let disposeBag = DisposeBag()
    subject.on(.next ("Hola de nuevo Andres"))
    //subject.onCompleted()
    //subject.onError(MyError.testTwo)
    subject.onNext("AQUI")
    
    let newSubscription = subject.subscribe(onNext:{
        print("New Subscription:", $0)
    })
    
    subject.onNext("Que pasa no entiendes?")
    
    newSubscription.dispose()
    
    subject.onNext("Aqui estamos chaval")
}

exampeThree(of: "BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subjetc = BehaviorSubject(value: "a")
    let firstSubscription = subjetc.subscribe(onNext:{
        print(#line, $0)
    })
    
    subjetc.onNext("b")
    
    let secondSubscription = subjetc.subscribe(onNext:{
         print(#line, $0)
    })
    firstSubscription.disposed(by: disposeBag)
    secondSubscription.disposed(by: disposeBag)
}


exampleFour(of: "ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<Int>.create(bufferSize: 3)
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    
    subject.onNext(4)
    
    subject.subscribe(onNext:{
        print($0)
    })
        .disposed(by: disposeBag)
    
    subject.onNext(5)
    
    subject.subscribe(onNext:{
        print("New Subscrition:", $0)
    })
        .disposed(by: disposeBag)
}

exampleFive(of: "Variable") {
    let disposeBag = DisposeBag()
    let variable = Variable("A")
    variable.asObservable()
        .subscribe({
            print($0)
        })
        .disposed(by: disposeBag)
    
    variable.value
    variable.value = "B"
    
}

exampleSingle(of: "Single") {
    let disposeBag = DisposeBag()
    
    enum FileReadError : Error{
        case fileNotFound, unreadable, encodingFailed
    }
    
    func contentsOfTextFile(named name : String)-> Single<String>{
        return Single.create{ single in
            let disposable = Disposables.create {}
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            guard let data = FileManager.default.contents(atPath: path) else{
                single(.error(FileReadError.unreadable))
                return disposable
            }
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
        }
    }
    
    contentsOfTextFile(named: "Crazy ones")
        .subscribe{
            switch $0 {
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
        }
    
}

/*exampleCompletable(of: "Completable") {
    
    let disposeBag = DisposeBag()
    
    func writeText(_ textData : String, toFileNamed name : String) -> Completable{
        return Completable.create{ completable in
            let disposable  = Disposables.create {}
            let url = playgroundSharedDataDirectory.appendingPathComponent("\(name).txt").path
            do{
                try textData.write(to: URL(string: url)!, atomically : false, encoding: .utf8)
                completable(.completed)
                return disposable
            }catch{
                completable(.error(error))
                return disposable
            }
        }
    }
    
    writeText("Aqui esta los crazy ones", toFileNamed: "Crazy ones")
        .subscribe{
            switch $0 {
            case .completed:
                print("Success!")
            case .error(let error):
                print("Failed:", error)
            }
        }
        .disposed(by: disposeBag)
}

exampleMaybe(of: "Maybe") {
    let disposeBag = DisposeBag()
    enum FileWriteError : Error{
        case unreadable , encodignFailed
    }
    
    func write(_ text : String, toFileNamed  name : String) -> Maybe<String>{
        return Maybe.create{ myMaybe in
            let disposable = Disposables.create {
                //TODO:
            }
            let url = playgroundSharedDataDirectory.appendingPathComponent("\(name).txt").path
            if let handle = FileHandle(forWritingAtPath: playgroundSharedDataDirectory.appendingPathComponent("\(name).txt").path){
                guard let readData = FileManager.default.contents(atPath: (URL(string: url)?.path)!),
                    let contents = String(data: readData, encoding: .utf8),
                    contents.lowercased().range(of: text.lowercased()) == nil
                    else {
                        myMaybe(.completed)
                        return disposable
                        
                }
                
                handle.seekToEndOfFile()
                guard let writeData = text.data(using: .utf8) else{
                    myMaybe(.error(FileWriteError.encodignFailed))
                    return disposable
                }
                
                handle.write(writeData)
                myMaybe(.success("Success!"))
                return disposable
            }else{
                do{
                    try text.write(to: URL(string: url)!, atomically: false, encoding: .utf8)
                    myMaybe(.success("Success!"))
                    return disposable
                }catch{
                    myMaybe(.error(error))
                    return disposable
                }
            }
        }
    }
    
    write("Here's to crazy ones", toFileNamed: "Crazy ones")
        .subscribe{ myMaybe in
            switch myMaybe {
            case .success(let element):
                print(element)
            case .completed :
                print("Completed")
            case .error(let error):
                print("Failed", error)
            }
        }
        .disposed(by: disposeBag)
}*/

example(of: "map") {
    Observable.of(1,2,3)
        .map{$0 * $0}
        .subscribe(onNext:{
            print($0)
        })
        .dispose()
}

example(of: "flatMap") {
    struct PLayer{
        let score: Variable<Int>
    }
    
    let disposeBag = DisposeBag()
    let scott = PLayer(score: Variable(80))
    let lori = PLayer(score: Variable(90))
    var currentPlayer = Variable(scott)
    currentPlayer.asObservable()
        .flatMapLatest{ $0.score.asObservable() }
        .subscribe(onNext:{
            print($0)
        })
        .disposed(by: disposeBag)
    currentPlayer.value.score.value = 85
    scott.score.value = 88
    currentPlayer.value = lori
    scott.score.value = 98
}

example(of: "scan & buffer") {
    let disposeBag = DisposeBag()
    
    let dartScore = PublishSubject<Int>()
    dartScore
        .buffer(timeSpan: 0.0, count: 3, scheduler: MainScheduler.instance)
        .map{
            print($0, "=> ", terminator: "")
            return $0.reduce(0, +)
        }
        .scan(501, accumulator: -)
        .map{max($0, 0)}
        .subscribe(onNext:{
            print($0)
        })
        .disposed(by: disposeBag)
    dartScore.onNext(13)
    dartScore.onNext(60)
    dartScore.onNext(87)
}

delay(0.3) {
    <#code#>
}




























/*:
 Copyright © 2017 Optimac, Inc. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
