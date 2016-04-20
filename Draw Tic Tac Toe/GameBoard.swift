//
//  GameBoard.swift
//  Draw Tic Tac Toe
//
//  Created by Nicholas Arduini on 2016-03-23.
//  Copyright © 2016 Nicholas Arduini. All rights reserved.
//

import Foundation
import CoreGraphics

class GameBoard {
    //baord lines to be sorted to be idfentified no matter the order they are drawn
    private var smallestXLines = [Line]()
    private var smallestYLines = [Line]()
    
    func resetBoard(){
        smallestXLines.removeAll()
        smallestYLines.removeAll()
    }
    
    func findIndex(lines: [Line], line: Line) -> Int{
        var index = 0
        for l in lines {
            if(l.begin.x == line.begin.x && l.begin.y == line.begin.y &&
                l.end.x == line.end.x && l.end.y == line.end.y){
                return index
            }
            index += 1
        }
        return -1
    }
    
    //find the horizontal board lines
    func getSmallestX(inout lines: [Line], inout smallestLines: [Line]){
        var smallestLine : Line
        var smallestX : CGFloat
        smallestX = 100000
        smallestLine = Line(begin: CGPoint(x:0,y:0), end: CGPoint(x:0,y:0))
        
        for line in lines {
            if(line.begin.x < smallestX){
                smallestX = line.begin.x
                smallestLine = line
            }
            if(line.end.x < smallestX){
                smallestX = line.end.x
                smallestLine = line
            }
        }
        
        smallestLines.append(smallestLine)
        if(findIndex(lines, line: smallestLine) > -1){
            lines.removeAtIndex(findIndex(lines, line: smallestLine))
        }
    }
    
    //find the vertial board lines
    func getSmallestY(inout lines: [Line], inout smallestLines: [Line]){
        var smallestLine : Line
        var smallestY : CGFloat
        smallestY = 100000
        smallestLine = Line(begin: CGPoint(x:0,y:0), end: CGPoint(x:0,y:0))
        
        for line in lines {
            if(line.begin.y < smallestY){
                smallestY = line.begin.y
                smallestLine = line
            }
            if(line.end.y < smallestY){
                smallestY = line.end.y
                smallestLine = line
            }
        }
        
        smallestLines.append(smallestLine)
        if(findIndex(lines, line: smallestLine) > -1){
            lines.removeAtIndex(findIndex(lines, line: smallestLine))
        }
    }
    
    //sort lines in order so the horizontal lines are sorted by closest to the top
    //the vertial lines are sorted by closest to the left side
    func analyzeBoard(finishedLines: [Line]){
        var tempLines = finishedLines
        
        getSmallestX(&tempLines, smallestLines: &smallestXLines)
        getSmallestX(&tempLines, smallestLines: &smallestXLines)
        getSmallestY(&tempLines, smallestLines: &smallestYLines)
        getSmallestY(&tempLines, smallestLines: &smallestYLines)
        
        //sort the smallest line collections
        smallestXLines.sortInPlace { (line1, line2) -> Bool in
            return line1.begin.y < line2.begin.y
        }
        
        smallestYLines.sortInPlace { (line1, line2) -> Bool in
            return line1.begin.x < line2.begin.x
        }
        
        //depending on where the user started drawing the line, ensure the smallest values are at the begin not end
        if(smallestXLines.first?.begin.x > smallestXLines.first?.end.x){
            smallestXLines[0] = Line(begin: (smallestXLines.first?.end)!, end: (smallestXLines.first?.begin)!)
        }
        
        if(smallestXLines.last?.begin.x > smallestXLines.last?.end.x){
            smallestXLines[1] = Line(begin: (smallestXLines.last?.end)!, end: (smallestXLines.last?.begin)!)
        }
        
        if(smallestYLines.first?.begin.y > smallestYLines.first?.end.y){
            smallestYLines[0] = Line(begin: (smallestYLines.first?.end)!, end: (smallestYLines.first?.begin)!)
        }
        
        if(smallestYLines.last?.begin.y > smallestYLines.last?.end.y){
            smallestYLines[1] = Line(begin: (smallestYLines.last?.end)!, end: (smallestYLines.last?.begin)!)
        }
    }
    
    //determine where on the board the shape is
    func findCell(xCords: CGFloat, yCords: CGFloat) -> String{
        let lineX1 = smallestXLines.first
        let lineX2 = smallestXLines.last
        let lineY1 = smallestYLines.first
        let lineY2 = smallestYLines.last
        
        if(xCords < lineY1!.begin.x && yCords < lineX1!.begin.y){
            return NSLocalizedString("q1", comment: "")
        } else if(xCords > lineY1!.begin.x && xCords < lineY2!.begin.x &&
            yCords < lineX1!.begin.y){
            return NSLocalizedString("q2", comment: "")
        } else if(xCords > lineY2!.begin.x && yCords < lineX1!.end.y){
            return NSLocalizedString("q3", comment: "")
        } else if(xCords < lineY1!.end.x && yCords > lineX1!.begin.y &&
            yCords < lineX2!.begin.y){
            return NSLocalizedString("q4", comment: "")
        } else if(xCords > lineY1!.end.x && xCords < lineY2!.end.x &&
            yCords > lineX1!.begin.y && yCords < lineX2!.begin.y){
            return NSLocalizedString("q5", comment: "")
        } else if(xCords > lineY2!.end.x && yCords > lineX1!.end.y &&
            yCords < lineX2!.end.y){
            return NSLocalizedString("q6", comment: "")
        } else if(xCords < lineY1!.end.x && yCords > lineX2!.begin.y){
            return NSLocalizedString("q7", comment: "")
        } else if(xCords > lineY1!.end.x && xCords < lineY2!.end.x &&
            yCords > lineX2!.begin.y){
            return NSLocalizedString("q8", comment: "")
        } else if(xCords > lineY2?.end.x && yCords > lineX2!.end.y){
            return NSLocalizedString("q9", comment: "")
        } else {
            return NSLocalizedString("q0", comment: "")
        }
    }
    
    //return a cell array that identifies the shape in a cell
    func getAllCellShapes(inout cells: [Shape], shapes: [Shape]){
        for _ in 0...8 {
            let newShape = Shape()
            cells.append(newShape)
        }
        
        for shape in shapes {
            if(shape.cell == NSLocalizedString("q1", comment: "")){
                cells[0] = shape
            } else if(shape.cell == NSLocalizedString("q2", comment: "")){
                cells[1] = shape
            } else if(shape.cell == NSLocalizedString("q3", comment: "")){
                cells[2] = shape
            } else if(shape.cell == NSLocalizedString("q4", comment: "")){
                cells[3] = shape
            } else if(shape.cell == NSLocalizedString("q5", comment: "")){
                cells[4] = shape
            } else if(shape.cell == NSLocalizedString("q6", comment: "")){
                cells[5] = shape
            } else if(shape.cell == NSLocalizedString("q7", comment: "")){
                cells[6] = shape
            } else if(shape.cell == NSLocalizedString("q8", comment: "")){
                cells[7] = shape
            } else if(shape.cell == NSLocalizedString("q9", comment: "")){
                cells[8] = shape
            }
        }
    }
    
    //prints the caracture to the console
    func drawCaracBoard(shapes: [Shape]){
        var cells = [Shape]()
        
        getAllCellShapes(&cells, shapes: shapes)
        
        let board = "\(cells[0].shape)|\(cells[1].shape)|\(cells[2].shape)\n\(cells[3].shape)|\(cells[4].shape)|\(cells[5].shape)\n\(cells[6].shape)|\(cells[7].shape)|\(cells[8].shape)\n\n"
        
        print(board)
    }
    
    //checks if the given letter has won
    func didWin(shapes: [Shape], letter: String) -> Bool{
        
        var cells = [Shape]()
        
        getAllCellShapes(&cells, shapes: shapes)
        
        //check all possible win combinations
        //horizontal
        let q123win = (cells[0].shape == letter && cells[1].shape == letter && cells[2].shape == letter)
        let q456win = (cells[3].shape == letter && cells[4].shape == letter && cells[5].shape == letter)
        let q789win = (cells[6].shape == letter && cells[7].shape == letter && cells[8].shape == letter)
        //vertical
        let q147win = (cells[0].shape == letter && cells[3].shape == letter && cells[6].shape == letter)
        let q258win = (cells[1].shape == letter && cells[4].shape == letter && cells[7].shape == letter)
        let q369win = (cells[2].shape == letter && cells[5].shape == letter && cells[8].shape == letter)
        //diagonal
        let q159win = (cells[0].shape == letter && cells[4].shape == letter && cells[8].shape == letter)
        let q357win = (cells[2].shape == letter && cells[4].shape == letter && cells[6].shape == letter)
        
        //if one combination is true there is a winner
        return q123win || q456win || q789win || q147win || q258win || q369win || q159win || q357win
    }
    
    //check if there is a tie
    func tie(shapes: [Shape]) -> Bool{
        var cells = [Shape]()
        
        getAllCellShapes(&cells, shapes: shapes)
        
        //check if the board is a shape on each cell
        let boardFull = (cells[0].shape != " " && cells[1].shape != " " && cells[2].shape != " " && cells[3].shape != " " && cells[4].shape != " " && cells[5].shape != " " && cells[6].shape != " " && cells[7].shape != " " && cells[8].shape != " ")
        
        //if the board is full and there is no winner it must be a tie
        return boardFull && !(didWin(shapes, letter: NSLocalizedString("X", comment: "")) || didWin(shapes, letter: NSLocalizedString("O", comment: "")))
    }
    
    //check if the given cell is free
    func cellTaken(cell: String, shapes: [Shape]) ->Bool {
        
        for shape in shapes {
            if(shape.cell == cell){
                return true
            }
        }
        
        return false
    }
    
    //when a winner is found draw a line connecting the winner depending on where it is placed
    func winLine(shapes: [Shape], letter: String) ->Line{
        var cells = [Shape]()
        
        getAllCellShapes(&cells, shapes: shapes)
        
        //check all possible win combinations
        //horizontal
        let q123win = (cells[0].shape == letter && cells[1].shape == letter && cells[2].shape == letter)
        let q456win = (cells[3].shape == letter && cells[4].shape == letter && cells[5].shape == letter)
        let q789win = (cells[6].shape == letter && cells[7].shape == letter && cells[8].shape == letter)
        //vertical
        let q147win = (cells[0].shape == letter && cells[3].shape == letter && cells[6].shape == letter)
        let q258win = (cells[1].shape == letter && cells[4].shape == letter && cells[7].shape == letter)
        let q369win = (cells[2].shape == letter && cells[5].shape == letter && cells[8].shape == letter)
        //diagonal
        let q159win = (cells[0].shape == letter && cells[4].shape == letter && cells[8].shape == letter)
        let q357win = (cells[2].shape == letter && cells[4].shape == letter && cells[6].shape == letter)
        
        //if one of these win combinations is true draw a line from the smallest numbered cell to the largest
        if(q123win){
            return Line(begin: CGPoint(x: cells[0].cellAvgXPos, y: cells[0].cellAvgYPos) , end: CGPoint(x: cells[2].cellAvgXPos, y: cells[2].cellAvgYPos))
        } else if(q456win){
            return Line(begin: CGPoint(x: cells[3].cellAvgXPos, y: cells[3].cellAvgYPos) , end: CGPoint(x: cells[5].cellAvgXPos, y: cells[5].cellAvgYPos))
        } else if(q789win){
            return Line(begin: CGPoint(x: cells[6].cellAvgXPos, y: cells[6].cellAvgYPos) , end: CGPoint(x: cells[8].cellAvgXPos, y: cells[8].cellAvgYPos))
        } else if(q147win){
            return Line(begin: CGPoint(x: cells[0].cellAvgXPos, y: cells[0].cellAvgYPos) , end: CGPoint(x: cells[6].cellAvgXPos, y: cells[6].cellAvgYPos))
        } else if(q258win){
            return Line(begin: CGPoint(x: cells[1].cellAvgXPos, y: cells[1].cellAvgYPos) , end: CGPoint(x: cells[7].cellAvgXPos, y: cells[7].cellAvgYPos))
        } else if(q369win){
            return Line(begin: CGPoint(x: cells[2].cellAvgXPos, y: cells[2].cellAvgYPos) , end: CGPoint(x: cells[8].cellAvgXPos, y: cells[8].cellAvgYPos))
        } else if(q159win){
            return Line(begin: CGPoint(x: cells[0].cellAvgXPos, y: cells[0].cellAvgYPos) , end: CGPoint(x: cells[8].cellAvgXPos, y: cells[8].cellAvgYPos))
        } else if(q357win){
            return Line(begin: CGPoint(x: cells[2].cellAvgXPos, y: cells[2].cellAvgYPos) , end: CGPoint(x: cells[6].cellAvgXPos, y: cells[6].cellAvgYPos))
        } else {
            return Line()
        }
    }
}