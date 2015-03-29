# CalcBrain

  CalcBrain - class for math expression calculation using shunting-yard algorithm and reverse polish notation. Designed for easy to add new operations.

## Example

```swift
let calc = CalcBrain()

calc.calculate("11 + (exp(2.010635 + sin(PI/2) * 3) + 50) / 2")
// return answer as String or error message
// in this case return -> "110.99998"
```
