//
//  ContentView.swift
//  FOOTBALL 3.0
//
//  Created by Matthew Berthoud on 7/29/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var gameState = "game off"
    @State var passState = ""
    @State var homePossession = true // home kicks to visitors to start
    @State var yardLine = 0 // 0-50-0 yardlines
    @State var leftSideOfField = true // home kicks to visitors to start

    @State var down = 0
    @State var fieldPosition = "0"
    @State var realYardsTo = 0
    @State var yardsTo = 0
    
    @State var home = 0
    @State var timeRemaining = "0:00" // minutes:seconds
    @State var visitors = 0
    
    
    @State var fieldArray = Array(repeating: Array(repeating: 0, count: 10), count: 3)
    @State var player:Sprite = Sprite(x: 7, y: 1, code: 1)
    @State var receiver:Sprite = Sprite(x: 5, y: 1, code: 2)
    @State var defenders:[Sprite] = []
    @State var ball:Sprite = Sprite(x: 5, y: 1, code: 5)
    
    @State var displayText = "First Half"
    @State var showingMessage = false

//    let gameTimer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common).autoconnect()
//    @State private var counter = 0
    
    @State var secondsLeft = 150
    @State var firstHalf = true
    @State var runningClock = true
    @State var gameClock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @State var tickClock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var tick = 0
    @State var ticking = true
    
    let timerSemaphore = DispatchSemaphore(value: 1)
    
    var body: some View {
        ZStack {
            Color(red: 0, green: 0.2, blue: 0.12)
                .ignoresSafeArea()
            VStack { // main

                
                ZStack { // Score info
                    Color(red: 0.9, green: 0.9, blue: 0.9)
                        // offwhite
                        .ignoresSafeArea()
                    HStack {
                        VStack {
                            Text("DOWN")
                                .foregroundColor(Color.blue)
                            Text(String(down))
                                .foregroundColor(Color.red)
                            Text("HOME")
                                .foregroundColor(Color.blue)
                            Text(String(home))
                                .foregroundColor(Color.red)
                        }
                        VStack {
                            Text("FIELD POSITION")
                                .foregroundColor(Color.blue)
                            Text(String(fieldPosition))
                                .foregroundColor(Color.red)
                            Text("TIME REMAINING")
                                .foregroundColor(Color.blue)
                            Text(String(timeRemaining))
                                .foregroundColor(Color.red)
                                .onReceive(gameClock) { time in
                                    if secondsLeft > 0 {
                                        if runningClock {
                                            secondsLeft -= 1
                                        }
                                    } else {
                                        secondHalf()
                                    }
                                    var secondsString = String(secondsLeft % 60)
                                    if secondsString.count == 1 {
                                        secondsString = "0" + secondsString
                                    }
                                    timeRemaining = String("\(secondsLeft / 60):\(secondsString)")
                                }
                            
                        }
                        VStack {
                            Text("YARDS TO")
                                .foregroundColor(Color.blue)
                            Text(String(yardsTo))
                                .foregroundColor(Color.red)
                            Text("VISITORS")
                                .foregroundColor(Color.blue)
                            Text(String(visitors))
                                .foregroundColor(Color.red)
                        }
                    }
                }
                .frame(height: 100.0)
                
               
                ZStack {
                    Color(.black)
                        .ignoresSafeArea()
                    if showingMessage {
                        Text(displayText)
                            .font(.title)
                            .foregroundColor(Color.blue)
                    }
                    else {
                        VStack {
                            ForEach(0..<3) { i in
                                HStack {
                                    ForEach(0..<10) { j in
                                        Image(String(fieldArray[i][j]))
                                    }
                                    .frame(width: 30.0, height: 30.0)
                                }
                            }
                        }
                    }
                }
                .frame(height: 200.0)

                
                
                VStack { // branding
                    HStack {
                        Text("MATTHEW ELECTRONICS")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Spacer()
                        ButtonView(title: "START", action: {
                            startGame()
                        }, color: .green)
                    }
                    .padding(.horizontal)
                    
                    
                    Text("FOOTBALL 3.0")
                        .font(.largeTitle)
                        .foregroundColor(Color.orange)
                }


                VStack { // buttons
                    HStack {
                        ButtonView(title: "NEXT", action: {
                            goNext()
                        }, color: .blue)
                        .padding(.horizontal, 25)
                        ButtonView(title: "KICK", action: {
                            kick()
                        }, color: .blue)
                        .padding(.horizontal, 25)
                        ButtonView(title: "PASS", action: {
                            pass()
                        }, color: .yellow)
                        .padding(.horizontal, 25)
                    }
                    Spacer()
                    HStack { // Run buttons
                        ButtonView(action: {
                            runLeft()
                        }, color: .red)
                        VStack {
                            ButtonView(action: {
                                runUp()
                            }, color: .red)
                            .padding(.bottom)
                            ButtonView(action: {
                                runDown()
                            }, color: .red)
                            .padding(.top)
                        }
                        ButtonView(action: {
                            runRight()
                        }, color: .red)
                    }
                }
            }
        }
        .onReceive(tickClock) { _ in
            timerSemaphore.wait()
            tick += 1
            print(tick)
            switch gameState {
            case "normal": // random defender movement
                for index in 0...(defenders.count - 1) {
                    let moveOrNot = Int.random(in: 0...16) // adjust to speed up or slow down defenders
                    if moveOrNot != 0 {
                        continue
                    }
                    
                    let moveOptions:[Character] = moveOptions(x:defenders[index].x, y:defenders[index].y)
                    if moveOptions == [] {
                        continue
                    }
                    let idx = Int.random(in: 0...(moveOptions.count - 1))
                    let direction = moveOptions[idx]
                    
                    switch direction {
                    case "l":
                        defenders[index].x = defenders[index].x - 1
                    case "r":
                        defenders[index].x = defenders[index].x + 1
                    case "u":
                        defenders[index].y = defenders[index].y - 1
                    case "d":
                        defenders[index].y = defenders[index].y + 1
                    default:
                        print("You shouldn't be here")
                    }
                    
                    defenders[index].hasMoved = true
                    
                    if defenders[index].x == player.x && defenders[index].y == player.y {
                        gameState = "tackled"
                    }
//                    print(idx)
//
//                    if defenders[index].x > 0 {
//                        defenders[index].x = defenders[index].x - 1
//                    }
                    update()
                }
                if passState == "before pass" {
                    let moveOrNot = Int.random(in: 0...20) // adjust to speed up or slow down reciever
                    if moveOrNot == 0 {
                        let moveOptions:[Character] = receiverMoveOptions(x:receiver.x, y:receiver.y)
                        if moveOptions == [] {
                            break
                        }
                        let idx = Int.random(in: 0...(moveOptions.count - 1))
                        let direction = moveOptions[idx]
                        
                        switch direction {
                        case "l":
                            receiver.x = receiver.x - 1
                        case "r":
                            receiver.x = receiver.x + 1
                        case "u":
                            receiver.y = receiver.y - 1
                        case "d":
                            receiver.y = receiver.y + 1
                        default:
                            print("You shouldn't be here")
                        }
                        
                        receiver.hasMoved = true
                        update()
                    }
                }
            default:
                print("tick leak! \(tick)")
            }
            timerSemaphore.signal()
        }
        .onAppear {
            stopClock()
            stopTicks()
        }
    }
    
    func moveOptions(x:Int, y:Int) -> [Character]{
        var moveOptions:[Character] = []
        
        if x != 0 && !isFull(x:x - 1, y:y) {
            moveOptions.append("l")
        }
        if x != 9 && !isFull(x:x + 1, y:y) {
            moveOptions.append("r")
        }
        if y != 0 && !isFull(x:x, y:y - 1) {
            moveOptions.append("u")
        }
        if y != 2 && !isFull(x:x, y:y + 1) {
            moveOptions.append("d")
        }
        return moveOptions
    }
    
    func receiverMoveOptions(x:Int, y:Int) -> [Character]{
        var moveOptions:[Character] = []
        
        if x > 4 && !isFull(x:x - 1, y:y) {
            moveOptions.append("l")
        }
        if x < 5 && !isFull(x:x + 1, y:y) {
            moveOptions.append("r")
        }
        if y != 0 && !isFull(x:x, y:y - 1) {
            moveOptions.append("u")
        }
        if y != 2 && !isFull(x:x, y:y + 1) {
            moveOptions.append("d")
        }
        return moveOptions
    }
    
    func isFull(x:Int, y:Int) -> Bool {
        for defender in defenders {
            if defender.x == x && defender.y == y {
                return true
            }
        }
        if receiver.x == x && receiver.y == y {
            return true
        }
        return false
    }
    
        
    func startGame() {
        timerSemaphore.wait()
        
        gameState = "before kick"
        homePossession = true // home kicks to visitors to start
        leftSideOfField = true // home kicks to visitors to start

        down = 0
        fieldPosition = "000"
        realYardsTo = 0
        yardsTo = 0
        
        home = 0
        timeRemaining = "2:30"
        visitors = 0
        
        fieldArray = Array(repeating: Array(repeating: 0, count: 10), count: 3)
        player = Sprite(x: 7, y: 1, code: 1)
        defenders = []
        ball = Sprite(x: 5, y: 1, code: 5)
        
        displayText = "First Half"
        
        stopClock()
        secondsLeft = 150
        firstHalf = true
        
        stopTicks()
        
        update()
        timerSemaphore.signal()
    }
    
    
    func goNext() { // gets called from button press AND from passing code
        if gameState != "tackled" && gameState != "touchback" && passState != "failed" {
            return
        }
        
        timerSemaphore.wait()
        if down == 4 {
            if homePossession {
                homePossession = false
            } else {
                homePossession = true
            }
            down = 0
        }
        down += 1
        gameState = "before snap"
        update()
        timerSemaphore.signal()
    }
    
    
    func kick() {
        timerSemaphore.wait()
        let kickedToYardline = Int.random(in: -40...0)
        // change to 30 for slightly over 50% chance of touchback
        // 100% chance of touchback for testing
        
        if gameState == "before kick" {
            print("kickoff")
            // DO THE START OF THE KICKING ANIMATION...
        } else if gameState == "before snap" {
            print("punt")
            // DO THE START OF THE PUNTING ANIMATION...
        } else if gameState == "normal" && passState == "before pass" {
            print("field goal attempt")
            let success = Int.random(in:0...1) // make this more realistic based on yardline at some point
            if success == 0 {
                print("field goal failed")
                passState = "failed"
                down = 4 // will cause turnover
                if yardLine <= 20 {
                    yardLine = 20
                }
                timerSemaphore.signal()
                goNext()
                return
            }
            print("field goal success!")
            if homePossession {
                home += 3
            } else {
                visitors += 3
            }
            gameState = "before kick"
            update()
            timerSemaphore.signal()
            return
            
        } else {
            timerSemaphore.signal()
            return
        }
        // ...BOTH KICKOFF AND PUNT ANIMATIONS EVENTUALLY LOOK THE SAME...
        
        down = 0
        if homePossession { // home kicks to visitors
            homePossession = false
            leftSideOfField = false // might not need to set this, if the kicking animation takes care of it
        } else { // visitors kick to home
            homePossession = true
            leftSideOfField = true // might not need to set this, if the kicking animation takes care of it
        }
        if kickedToYardline <= 0 {
            yardLine = 20
            gameState = "touchback"
        } else {
            print("caught")
            yardLine = kickedToYardline
            gameState = "kick return"
            // slowly add defenders
        }
        update()
        timerSemaphore.signal()
    }
    
    
    func pass() {
        if gameState != "normal" || passState != "before pass" {
            return
        }
        
        timerSemaphore.wait()

        print("pass")
        passState = "passing"
        update() // necessary for animation maybe?
        
        var sprite = findNextSprite(startX:player.x, startY:player.y)
        var funccall = 1
        print(sprite.code)
        while sprite.code != 2 && sprite.code != 0 {
            if !sprite.hasMoved || funccall > 1{
                print("interception")
                passState = "failed"
                down = 4 // will cause turnover
                timerSemaphore.signal()
                goNext()
                return
            }
            sprite = findNextSprite(startX:sprite.x, startY:sprite.y)
            funccall += 1
            print(sprite.code)
        }
        if sprite.code == 0 {
            print("incomplete")
            passState = "failed"
            timerSemaphore.signal()
            goNext()
            return
        }
        print("complete")
        
        
        // make passing yards count
        
        let yardsPassed = abs(player.x - receiver.x)
        realYardsTo -= yardsPassed
        if leftSideOfField && homePossession || !leftSideOfField && !homePossession {
            yardLine += yardsPassed
        } else {
            yardLine -= yardsPassed
        }
        
        if yardLine > 50 {
            yardLine = 50 - (yardLine - 51)
            if leftSideOfField {
                leftSideOfField = false
            } else {
                leftSideOfField = true
            }
        }
        
        if realYardsTo >= 0 {
            yardsTo = realYardsTo // display 0 once first down passed
        } else {
            yardsTo = 0
        }
        
        
        player.x = receiver.x
        player.y = receiver.y
        passState = "after pass"
        update()
        timerSemaphore.signal()
    }

    
    func runUp() {
        if invalidMove() {
            return
        }
        
        if player.y <= 0 {
            player.y = 0 // should already be but just in case
            return
        }
        
        timerSemaphore.wait()

        let newY = player.y - 1
        if collision(newX:player.x, newY:newY) {
            gameState = "tackled"
            update()
            timerSemaphore.signal()
            return
        }
        
        print("run up")
        player.y = newY

        update()
        timerSemaphore.signal()
    }
    
    
    func runDown() {
        if invalidMove() {
            return
        }
        
        if player.y >= 2 {
            player.y = 2 // should already be but just in case
            return
        }
        
        timerSemaphore.wait()

        let newY = player.y + 1
        if collision(newX:player.x, newY:newY) {
            gameState = "tackled"
            update()
            timerSemaphore.signal()
            return
        }
        
        print("run down")
        player.y = newY

        update()
        timerSemaphore.signal()
    }
    
    func runLeft() {
        if invalidMove() {
            return
        }
        
        if homePossession && player.x == 0 {
            return // can't backtrack off the screen
        }
        
        
        timerSemaphore.wait()
        // Mod operator is weird with negatives in swift
        // https://stackoverflow.com/questions/41180292/negative-number-modulo-in-swift
        var newX:Int
        if player.x == 0 {
            newX = 9
        } else {
            newX = (player.x - 1) % 10
        }
        
        var newYard:Int
        if leftSideOfField {
            newYard = yardLine - 1
        } else if yardLine == 50 {
            leftSideOfField = true
            newYard = yardLine
        } else {
            newYard = yardLine + 1
        }
                
        if collision(newX:newX, newY:player.y) {
            gameState = "tackled"
            update()
            timerSemaphore.signal()
            return
        }
        
        print("run left")
        player.x = newX
        yardLine = newYard
        
        if !homePossession && passState == "before pass" && player.x <= 6 {
            passState = "after pass"
        }
    
        if homePossession {
            realYardsTo += 1
        } else {
            realYardsTo -= 1
        }
        if realYardsTo >= 0 {
            yardsTo = realYardsTo // display 0 once first down passed
        } else {
            yardsTo = 0
        }

        update()
        timerSemaphore.signal()
    }
    
    func runRight() {
        if invalidMove() {
            return
        }
        
        if !homePossession && player.x == 9 {
            return // can't backtrack off the screen
        }
        
        timerSemaphore.wait()

        let newX = (player.x + 1) % 10
        
        var newYard:Int
        if !leftSideOfField {
            newYard = yardLine - 1
        } else if yardLine == 50 {
            leftSideOfField = false
            newYard = yardLine
        } else {
            newYard = yardLine + 1
        }
        
        if collision(newX:newX, newY:player.y) {
            gameState = "tackled"
            update()
            timerSemaphore.signal()
            return
        }
        
        print("run right")
        player.x = newX
        yardLine = newYard
        
        if homePossession && passState == "before pass" && player.x >= 3 {
            passState = "after pass"
        }

        if homePossession {
            realYardsTo -= 1
        } else {
            realYardsTo += 1
        }
        if realYardsTo >= 0 {
            yardsTo = realYardsTo // display 0 once first down passed
        } else {
            yardsTo = 0
        }
        update()
        timerSemaphore.signal()
    }
    
    
    func update() {
        print("")
//        if leftSideOfField {
//            print("left side of field")
//        } else {
//            print("right side of field")
//        }
//        if homePossession {
//            print("home possession")
//        } else {
//            print("visitors possession")
//        }
        
        fieldArray = Array(repeating: Array(repeating: 0, count: 10), count: 3)
        var toDisplay:[Sprite] = []
        switch gameState {
            
            
        case "before kick": // beginning of the game, also after touchdowns and safeties and fieldgoals
            print("before kick")
            stopClock()
            stopTicks()
            down = 0
            yardLine = 35
            if homePossession {
                leftSideOfField = true
                defenders = [
                    Sprite(x: 1, y: 1, code: 3), // kicker
                    Sprite(x: 0, y: 0, code: 3), // top guy
                    Sprite(x: 0, y: 2, code: 3)] // bottom guy
                ball = Sprite(x: 5, y: 1, code: 5)
            } else {
                leftSideOfField = false
                defenders = [
                    Sprite(x: 8, y: 1, code: 3), // kicker
                    Sprite(x: 9, y: 0, code: 3), // top guy
                    Sprite(x: 9, y: 2, code: 3)] // bottom guy
                ball = Sprite(x: 4, y: 1, code: 5)
            }
            
            for defender in defenders {
                toDisplay.append(defender)
            }
            toDisplay.append(ball)

            
        case "kicking":
            print("kicking")
            stopClock()
            stopTicks()

            
        case "kick return":
            print("kick return")
            startClock()
            startTicks()

        case "tackled":
            print("tackled")
            stopClock()
            stopTicks()
            if ((leftSideOfField && homePossession) || (!leftSideOfField && !homePossession)) && yardLine <= 0 {
                print("safety")
                if homePossession {
                    visitors += 2
                } else {
                    home += 2
                }
                gameState = "before kick"
                update()
                return
            }
            if realYardsTo <= 0 {
                realYardsTo = 10
                yardsTo = 10
                down = 0
            }
            
        case "touchback":
            print("touchback")
            stopClock()
            stopTicks()
            
            
        case "before snap":
            print("before snap")
            stopClock()
            stopTicks()
            if down == 1 { // needed for the first play of a possession
                yardsTo = 10
                realYardsTo = 10
            }
            
            let defenseFormation = Int.random(in: 0...1)
            let receiverYCoord = Int.random(in: 0...2)
                        
            if homePossession {
                defenders = [
                    Sprite(x: 3, y: 0, code: 3), // defensive line...
                    Sprite(x: 3, y: 1, code: 3),
                    Sprite(x: 3, y: 2, code: 3),
                    Sprite(x: 5, y: 1, code: 3)] // linebacker
                if defenseFormation == 0 {
                    defenders.append(Sprite(x: 7, y: 0, code: 3))
                    defenders.append(Sprite(x: 9, y: 2, code: 3))
                } else {
                    defenders.append(Sprite(x: 7, y: 2, code: 3))
                    defenders.append(Sprite(x: 9, y: 0, code: 3))
                }
                player = Sprite(x: 2, y: 1, code: 1)
                receiver = Sprite(x: 4, y: receiverYCoord, code: 2)
                
            } else {
                defenders = [
                    Sprite(x: 6, y: 0, code: 3), // defensive line...
                    Sprite(x: 6, y: 1, code: 3),
                    Sprite(x: 6, y: 2, code: 3),
                    Sprite(x: 4, y: 1, code: 3)]
                if defenseFormation == 0 {
                    defenders.append(Sprite(x: 2, y: 0, code: 3))
                    defenders.append(Sprite(x: 0, y: 2, code: 3))
                } else {
                    defenders.append(Sprite(x: 2, y: 2, code: 3))
                    defenders.append(Sprite(x: 0, y: 0, code: 3))
                }
                player = Sprite(x: 7, y: 1, code: 1)
                receiver = Sprite(x: 5, y: receiverYCoord, code: 2)
            }
            
            for defender in defenders {
                toDisplay.append(defender)
            }
            toDisplay.append(player)
            
            
        default: // case "normal": // normal gameplay
            switch passState {
            case "before pass":
                print("before pass")
                startClock()
                startTicks()
                // receiver initialized in "before snap" but not displayed
                // this way it can be moved around just like the defenders
                toDisplay.append(receiver)
            case "passing":
                print("passing")
                stopClock()
                stopTicks()
                toDisplay.append(receiver)
                
            default:
                print("after pass")
                startClock()
                startTicks()
            }
            
            if yardLine <= 0 {
                if (leftSideOfField && homePossession) || (!leftSideOfField && !homePossession) {
                    print("own endzone")
                } else {
                    if homePossession {
                        home += 7
                    } else {
                        visitors += 7
                    }
                    print("touchdown")
                    stopClock() // shouldn't need to do this but for some reason clock is running during before kick gameState
                    stopTicks() // not sure if I need this at all but putting it here cause of above
                    gameState = "before kick"
                    update()
                    return
                }
            }
            
            for defender in defenders {
                toDisplay.append(defender)
            }
            toDisplay.append(player)
        }
        
        
        for sprite in toDisplay {
            fieldArray[sprite.y][sprite.x] = sprite.code
        }
        
        if leftSideOfField {
            fieldPosition = String(yardLine) + "←"
        } else {
            fieldPosition = "→" + String(yardLine)
        }
    }
    
    
    func invalidMove() -> Bool {
        if (gameState != "normal" && gameState != "kick return" && gameState != "before snap") || passState == "passing" {
            return true
        }
        if !player.hasMoved {
            player.hasMoved = true
            gameState = "normal"
            passState = "before pass"
        }
        return false
    }
    
    
    func collision(newX:Int, newY:Int) -> Bool {
        for defender in defenders {
            if defender.x == newX && defender.y == newY {
                return true
            }
        }
        return false
    }
    
    func findNextSprite(startX:Int, startY:Int) -> Sprite {
        var matchingY:[Sprite] = []
        if receiver.y == startY {
            matchingY.append(receiver)
        }
        for defender in defenders {
            if defender.y == startY {
                matchingY.append(defender)
            }
        }
        
        if homePossession {
            let sorted = matchingY.sorted { $0.x < $1.x }
            for match in sorted {
                if match.x > startX {
                    return match
                }
            }
        } else {
            let sorted = matchingY.sorted { $0.x > $1.x }
            for match in sorted {
                if match.x < startX {
                    return match
                }
            }
        }
        let nullSprite = Sprite(x:0, y:0, code:0)
        return nullSprite
    }
    
    func startClock() {
        if !runningClock {
            runningClock = true
            gameClock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
    }
    
    func stopClock() {
        if runningClock {
            runningClock = false
            gameClock.upstream.connect().cancel()
        }
    }
    
    func secondHalf() {
        stopClock()
        secondsLeft = 150
        gameState = "before kick"
        homePossession = false
        update()
    }
    
    func startTicks() {
        if !ticking {
            ticking = true
            tick = 0
            tickClock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        }
    }
    
    func stopTicks() {
        if ticking {
            ticking = false
            tickClock.upstream.connect().cancel()
        }
    }
    
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

