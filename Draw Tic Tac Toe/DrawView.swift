//
//  DrawView.swift
//  Draw Tic Tac Toe
//
//  Created by Nicholas Arduini on 2016-03-21.
//  Copyright © 2016 Nicholas Arduini. All rights reserved.
//

import UIKit

class DrawView: UIView {
    //shapes
    private var shapes = [Shape]()
    private var curShapes = [Shape]()
    
    //board lines
    private var lineStartLocDic = [Int: CGPoint]()//for the board lines start locations
    private var currentLines = [NSValue: Line]()
    private var finishedLines = [Line]()
    
    //game states
    private var boardDrawn = false
    private var gameOver = false
    private var oTurn = true
    private var xTurn = true
    
    //score counter
    private var xWins = 0
    private var oWins = 0
    
    //line to be drawn when winner is found
    private var winnerShape = " "
    private var winLine = Line()
    
    //game board to handle board events
    private var gameBoard = GameBoard()
    
    //ui labels
    @IBOutlet var menuWinnerLabel: UILabel!
    @IBOutlet var gameInfoLabel: UILabel!
    @IBOutlet var xScoreLabel: UILabel!
    @IBOutlet var oScoreLabel: UILabel!
    @IBOutlet var menuXScoreLabel: UILabel!
    @IBOutlet var menuOScoreLabel: UILabel!
    
    //play again menu to be shown after game is over
    @IBOutlet var menuBlurr: UIVisualEffectView!
    @IBAction func playAgainButton(sender: AnyObject) {
        menuBlurr.hidden = true
        resetGame()
    }
    @IBAction func clearScoreButton(sender: AnyObject) {
        xWins = 0
        oWins = 0
        updateScore()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.delaysTouchesBegan = true
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }
    
    
    //set colors from storyboard inspector
    @IBInspectable var lineColor: UIColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var xColor: UIColor = UIColor.redColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var oColor: UIColor = UIColor.blueColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var currentShapeColor: UIColor = UIColor.greenColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var winLineColor: UIColor = UIColor.cyanColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func resetGame(){
        gameBoard.resetBoard()
        shapes.removeAll()
        curShapes.removeAll()
        finishedLines.removeAll()
        currentLines.removeAll()
        lineStartLocDic.removeAll()
        
        boardDrawn = false
        gameOver = false
        oTurn = true
        xTurn = true
        
        gameInfoLabel.text = NSLocalizedString("drawBoard", comment: "")
        setNeedsDisplay()
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer){
        //reset the game on double tap only if the game hasn't started
        if(!boardDrawn){
            resetGame()
        }
    }
    
    //delay the program, to be used to delay the play again menu from showing up
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func updateScore(){
        xScoreLabel.text = "\(NSLocalizedString("xScoreText", comment: "")) \(xWins)"
        oScoreLabel.text = "\(NSLocalizedString("oScoreText", comment: "")) \(oWins)"
        menuXScoreLabel.text = "\(NSLocalizedString("xScoreText", comment: "")) \(xWins)"
        menuOScoreLabel.text = "\(NSLocalizedString("oScoreText", comment: "")) \(oWins)"
    }
    
    func strokeLine(line: Line){
        //User BezierPath to draw lines
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = CGLineCap.Round
        
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        path.stroke() //actually draw the path
    }
    
    func distanceBetween(from: CGPoint, to: CGPoint) -> CFloat{
        let distXsquared = Float((to.x-from.x)*(to.x-from.x))
        let distYsquared = Float((to.y-from.y)*(to.y-from.y))
        return sqrt(distXsquared + distYsquared)
    }
    
    //check if two shapes intersect each other with a tolerance of 20
    func intersection(shape1: Shape, shape2: Shape) ->Bool{
        for point1 in shape1.coordinates {
            for point2 in shape2.coordinates{
                if(distanceBetween(point1, to: point2) < 20){
                    return true
                }
            }
        }
        return false
    }
    
    //find the average of given x coordinates
    func xCordsAvg(cords: [CGPoint]) -> CGFloat{
        var total : CGFloat
        var num : CGFloat
        total = 0
        num = 0
        
        for cord in cords {
            total += cord.x
            num += 1.0
        }
        
        return (total / num)
    }
    
    //find the average of given y coordinates
    func yCordsAvg(cords: [CGPoint]) -> CGFloat{
        var total : CGFloat
        var num : CGFloat
        total = 0
        num = 0
        
        for cord in cords {
            total += cord.y
            num += 1.0
        }
        
        return (total / num)
    }
    
    //use intersection to determine if the shape drawn is close enough to an X
    func isX(shape1: Shape, shape2: Shape) -> Bool{
        return intersection(shape1, shape2: shape2)
    }
    
    //use the distance between the last points off the shape to determine if the shape drawn is close enoguh to an O
    func isO(shape: Shape) -> Bool {
        return (distanceBetween(shape.coordinates.first!, to: shape.coordinates.last!) < 20)
    }

    override func drawRect(rect: CGRect) {
        //draw the exisiting lines
        for line in finishedLines{
            lineColor.setStroke()
            strokeLine(line)
        }
        
        //draw the new lines
        for line in currentLines {
            lineColor.setStroke()
            strokeLine(line.1)
        }
        
        //draw existing shapes
        for shape in shapes {
            //change color depdending on the shape
            if(shape.shape == NSLocalizedString("X", comment: "")){
                xColor.setStroke()
            } else {
                oColor.setStroke()
            }
            //draw the shape given if it has more than 3 coordinates
            if(shape.coordinates.count > 2){
                for i in 0...shape.coordinates.count-2 {
                    strokeLine(Line(begin: shape.coordinates[i], end: shape.coordinates[i + 1]))
                }
            }
        }
        
        //draw the new shapes
        if(curShapes.count > 0){
            for shape in curShapes {
                currentShapeColor.setStroke()
                
                //draw the current shape if it has more than 3 coordinates
                if(shape.coordinates.count > 2){
                    for i in 0...shape.coordinates.count-2 {
                        strokeLine(Line(begin: shape.coordinates[i], end: shape.coordinates[i + 1]))
                    }
                }
            }
        }
        
        //when the game is over draw the winning line if it exists, and show the menu
        if(gameOver){
            winLineColor.setStroke()
            strokeLine(winLine)
            delay(0.3){
                self.menuBlurr.hidden = false
            }
        }
    }
    
    
    //override touch Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(!gameOver){
            //start lines for the board if only if it hasn't already been drawn and if there isn't already 4 touch events
            if(!boardDrawn && finishedLines.count < 4){
                for touch in touches {
                    let t = touch.locationInView(self)
                    lineStartLocDic.updateValue(t, forKey: touch.hash) /// store start locations
                }
            } else { //if the board is drawn draw shapes
                var cords = [CGPoint]()
                cords.append(touches.first!.locationInView(self))
                
                let shape = Shape(cords: cords)
                curShapes.append(shape)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //track board lines if it isnt drawn
        if(!boardDrawn && !gameOver){
            //reset the start locations count
            for touch in touches {
                let location = touch.locationInView(self) //get location in view co-ordinates
                let newLine = Line(begin: lineStartLocDic[touch.hash]!, end: location)
                let key = NSValue(nonretainedObject: touch)
                currentLines[key] = newLine
            }
            
        } else if(curShapes.count > 0){//if drawing shape track these coordinates
            curShapes[curShapes.endIndex-1].coordinates.append(touches.first!.locationInView(self))
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(!gameOver){
            //if the board is not yet drawn, draw the current lines
            if(!boardDrawn){
                for touch in touches {
                    let location = touch.locationInView(self) //get location in view co-ordinates
                    let newLine = Line(begin: lineStartLocDic[touch.hash]!, end: location)
                    let key = NSValue(nonretainedObject: touch)
                    currentLines[key] = newLine
                    finishedLines.append(newLine)
                }
                
                //if this was the last line to the board let the player know
                if(finishedLines.count >= 4){
                    gameInfoLabel.text = NSLocalizedString("startGame", comment: "")
                    gameBoard.analyzeBoard(finishedLines)//analyze where the cells on the board are
                    gameBoard.drawCaracBoard(shapes) //print the board to the console
                    boardDrawn = true
                }
                
            } else if(curShapes.count > 0){ //shapes are drawn
                if(!isO(curShapes[curShapes.endIndex-1]) && oTurn && !xTurn || curShapes[curShapes.endIndex-1].coordinates.count < 3){ //if the shape is not an o or part of an x erase it or if there are not enough coordinates for a shape
                    curShapes.removeAll()
                } else if(isO(curShapes[curShapes.endIndex-1]) && oTurn){ //if the shape is an o and it is the o turn update the board
                    //get the o shape and it's coordinates
                    let shape = curShapes.last
                    let xCords = xCordsAvg((shape?.coordinates)!)
                    let yCords = yCordsAvg((shape?.coordinates)!)
                    
                    let cell = gameBoard.findCell(xCords, yCords: yCords)
                    
                    //check if that cell is taken, if so erase the current shape
                    if(!gameBoard.cellTaken(cell, shapes: shapes)){
                        shapes.appendContentsOf(curShapes)
                        
                        //update the shape's values with what is now known
                        shapes[shapes.endIndex-1].shape = NSLocalizedString("O", comment: "")
                        shapes[shapes.endIndex-1].cell = cell
                        shapes[shapes.endIndex-1].cellAvgXPos = xCords
                        shapes[shapes.endIndex-1].cellAvgYPos = yCords
                        
                        //switch turns
                        oTurn = false
                        xTurn = true
                        
                        gameInfoLabel.text = NSLocalizedString("xTurn", comment: "")
                        
                        //check if o has won
                        if(gameBoard.didWin(shapes, letter: NSLocalizedString("O", comment: ""))){
                            winnerShape = NSLocalizedString("O", comment: "")
                            gameInfoLabel.text = NSLocalizedString("oWins", comment: "")
                            menuWinnerLabel.text = NSLocalizedString("oWins", comment: "")
                            oWins += 1
                            updateScore()
                            gameOver = true
                        } else if(gameBoard.tie(shapes)){ //check if there is a tie
                            gameInfoLabel.text = NSLocalizedString("tie", comment: "")
                            menuWinnerLabel.text = NSLocalizedString("tie", comment: "")
                            gameOver = true
                        }
                    }
                    
                    //clear the current shapes and update the console
                    curShapes.removeAll()
                    gameBoard.drawCaracBoard(shapes)
                    
                } else if(xTurn && isO(curShapes[curShapes.endIndex-1])) {//if the first shape of an x is an o delete it
                    curShapes.removeAll()
                } else if(curShapes.count >= 2){ //two shapes are made to make an x
                    if(isX(curShapes[curShapes.endIndex-2], shape2: curShapes[curShapes.endIndex-1]) && xTurn){ //if the shapes make an x and it is the x turn update the board
                        //get the x shape and it's coordinates
                        let shape1 = curShapes.last
                        let shape2 = curShapes[curShapes.endIndex-2]
                        let xCords = (xCordsAvg((shape1?.coordinates)!) + xCordsAvg(shape2.coordinates))/2
                        let yCords = (yCordsAvg((shape1?.coordinates)!) + yCordsAvg(shape2.coordinates))/2
                        
                        let cell = gameBoard.findCell(xCords, yCords: yCords)
                        
                        //check if that cell is taken, if so erase the current shape
                        if(!gameBoard.cellTaken(cell, shapes: shapes)){
                            shapes.appendContentsOf(curShapes)
                            
                            //update the shapes values with what is now known
                            shapes[shapes.endIndex-1].shape = NSLocalizedString("X", comment: "")
                            shapes[shapes.endIndex-1].cell = cell
                            shapes[shapes.endIndex-1].cellAvgXPos = xCords
                            shapes[shapes.endIndex-1].cellAvgYPos = yCords
                            shapes[shapes.endIndex-2].shape = NSLocalizedString("X", comment: "")
                            shapes[shapes.endIndex-2].cell = cell
                            shapes[shapes.endIndex-2].cellAvgXPos = xCords
                            shapes[shapes.endIndex-2].cellAvgYPos = yCords
                            
                            //switch turns
                            oTurn = true
                            xTurn = false
                            
                            gameInfoLabel.text = NSLocalizedString("oTurn", comment: "")
                            
                            //check if x has won
                            if(gameBoard.didWin(shapes, letter: NSLocalizedString("X", comment: ""))){
                                winnerShape = NSLocalizedString("X", comment: "")
                                gameInfoLabel.text = NSLocalizedString("xWins", comment: "")
                                menuWinnerLabel.text = NSLocalizedString("xWins", comment: "")
                                xWins += 1
                                updateScore()
                                gameOver = true
                            } else if(gameBoard.tie(shapes)){ //check if there is a tie
                                gameInfoLabel.text = NSLocalizedString("tie", comment: "")
                                menuWinnerLabel.text = NSLocalizedString("tie", comment: "")
                                gameOver = true
                            }
                        }
                        
                        //clear the current shapes and update the console
                        curShapes.removeAll()
                        gameBoard.drawCaracBoard(shapes)
                        
                    } else { //if the two shapes drawn do not make an x erase it
                        curShapes.removeAll()
                    }
                }
            }
        }
        
        //if the game is over update to info lable and menu
        if(gameOver){
            winLine = gameBoard.winLine(shapes, letter: winnerShape)
            updateScore()
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        //if the touch event is cancelled clear the current collections
        currentLines.removeAll()
        lineStartLocDic.removeAll()
        curShapes.removeAll()
    }
}
