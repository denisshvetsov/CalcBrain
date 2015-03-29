//
//  Calc.swift
//  ShuntingYardCalc
//
//  Created by Denis Shvetsov on 21/02/15.
//  Copyright (c) 2015 Denis Shvetsov. All rights reserved.
//

import Foundation

/**
 * CalcBrain - class for expression calculation using shunting-yard algorithm and reverse polish notation.
 * Supported operations: '+', '-', '/', '*', '(' , ')', 'sqrt', 'exp', 'sin', 'cos'.
 * Supported constants: 'PI', 'E'.
 */
class CalcBrain {

    private enum Op: Printable {
        case Operand(value: Double)
        case ConstOperation(value: String, f: () -> Double)
        case UnaryOperation(value: String, precedence: Int, f: Double -> Double)
        case BinaryOperation(value: String, precedence: Int, f: (Double, Double) -> Double)
        case PrecedenceOperation(value: String, precedence: Int)
        
        var precedence: Int? {
            switch self {
            case .Operand(_), .ConstOperation(_, _):
                return nil
            case .UnaryOperation(_, let precedence, _):
                return precedence
            case .BinaryOperation(_, let precedence, _):
                return precedence
            case .PrecedenceOperation(_, let precedence):
                return precedence
            }
        }
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .ConstOperation(let symbol, _):
                return symbol
            case .UnaryOperation(let symbol, _, _):
                return symbol
            case .BinaryOperation(let symbol, _, _):
                return symbol
            case .PrecedenceOperation(let symbol, _):
                return symbol
            }
        }
    }
    
    private var knownOps = [String:Op]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.ConstOperation(value: "PI", f: { M_PI }))
        learnOp(Op.ConstOperation(value: "E", f: { M_E }))
        learnOp(Op.UnaryOperation(value: "sqrt", precedence: 4, f: sqrt))
        learnOp(Op.UnaryOperation(value: "sin", precedence: 4, f: sin))
        learnOp(Op.UnaryOperation(value: "cos", precedence: 4, f: cos))
        learnOp(Op.UnaryOperation(value: "exp", precedence: 4, f: exp))
        learnOp(Op.BinaryOperation(value: "*", precedence: 3, f: *))
        learnOp(Op.BinaryOperation(value: "/", precedence: 3, f: { $1 / $0 }))
        learnOp(Op.BinaryOperation(value: "+", precedence: 2, f: +))
        learnOp(Op.BinaryOperation(value: "-", precedence: 2, f: { $1 - $0 }))
        learnOp(Op.PrecedenceOperation(value: "(", precedence: 1))
        learnOp(Op.PrecedenceOperation(value: ")", precedence: 1))
    }
    
    /**
     * Main public function for calculation
     * @param input - math expression in infix notation
     * @return string with answer or error message
     */
    func calculate(input: String) -> String {
        let result = infixToPostfix(input).flatMap(evaluate).map(stringRoundingUpFive)
        return result.description
    }
    
    private func stringRoundingUpFive(value: Double) -> String {
        return stringRoundingUp(5, forValue: value)
    }
    
    private func stringRoundingUp(number: Int, forValue value: Double) -> String {
        let format = "%." + "\(number)" + "f"
        return String(format: format, arguments: [value])
    }
    
    // MARK: - Infix to postfix
    /**
    * Shunting-yard algorithm
    * @param input - math expression in infix notation
    * @return array of Ops in postfix notation or error message
    */
    private func infixToPostfix(input: String) -> Result<[Op]> {
        var operationStack = Stack<Op>()
        var postfixOutput = [Op]()
        var beginToken = 0
        for (endToken, char) in enumerate(input) {
            let currSymbol = String(char)
            let nextSymbol = input.stringFromIndex(endToken + 1) ?? ""
            if currSymbol.isSeparator || nextSymbol.isSeparator || nextSymbol.isEmpty {
                let token = input.substringWithRange(Range<String.Index>(start: input.indexFromInt(beginToken),
                                                                           end: input.indexFromInt(endToken + 1)))
                if token != " " {
                    if let error = handleToken(token, withStack: &operationStack, andOutput: &postfixOutput) {
                        return .Failure(error)
                    }
                }
                beginToken = endToken + 1
            }
        }
        while !operationStack.isEmpty {
            switch operationStack.last! { // need to refactor
            case .PrecedenceOperation(_, _):
                return .Failure("error: missing bracket \")\"")
            default:
                break
            }
            postfixOutput.append(operationStack.pop())
        }
        return .Success(Box(value: postfixOutput))
    }
    
    private func handleToken(token: String, inout withStack operationStack: Stack<Op>, inout andOutput postfixOutput: [Op]) -> String? {
        switch opFromToken(token) {
        case .Success(let box):
            let op = box.value
            switch op {
            case .Operand(_), .ConstOperation(_, _):
                postfixOutput.append(op)
            case .UnaryOperation(_, _, _), .BinaryOperation(_, _, _):
                if operationStack.isEmpty {
                    operationStack.push(op)
                } else if op.precedence! <= operationStack.last!.precedence! {
                    postfixOutput.append(operationStack.pop())
                    operationStack.push(op)
                } else {
                    operationStack.push(op)
                }
            case .PrecedenceOperation(let operationName, _):
                if operationName == "(" {
                    operationStack.push(op)
                } else if operationName == ")" {
                    while operationStack.last!.description != "(" {
                        postfixOutput.append(operationStack.pop())
                        if (operationStack.isEmpty) {
                            return "error: missing bracket \"(\""
                        }
                    }
                    operationStack.pop()
                }
            }
        case .Failure(let err):
            return err
        }
        return nil
    }
    
    private func opFromToken(token: String) -> Result<Op> {
        if let operation = knownOps[token] {
            return .Success(Box(value: operation))
        } else if let value = token.doubleValue {
            return .Success(Box(value: Op.Operand(value: value)))
        }
        return .Failure("error: unknown constant \"\(token)\"")
    }
    
    /**
    * Evaluation using reverse polish notation
    * @param postfix 
    * @return result as Double or error message
    */
    private func evaluate(postfix: [Op]) -> Result<Double> {
        let (result, remainder) = evaluation(postfix)
        if remainder.count > 0 {
            return .Failure("error: missing operand or operation")
        } else if let res = result {
            if res.isInfinite || res.isNaN {
                return .Failure("error: division by zero")
            }
            return .Success(Box(value: res))
        }
        return .Failure("error: empty input")
    }
    
    private func evaluation(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .ConstOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, _, let operation):
                let operandEvaluation = evaluation(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluation(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluation(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .PrecedenceOperation(_, _):
                break
            }
        }
        return (nil, ops)
    }
}