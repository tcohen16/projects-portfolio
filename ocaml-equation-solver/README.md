# Mathematical Equation Solver

Given a list of floats, the problem is to find all correct ways of inserting the four basic arithmetic signs (operators) +, -, *, /,
and one equal sign between the floats such that the result is a correct equation. Parentheses can also be added.
For example, with the list of numbers [2; 3; 5; 7; 11] we can form the equations 2 - 3 + 5 + 7 = 11 or 2 = (3 * 5 + 7) / 11, plus some others.
We also chose that for consecutive additions and subtractions, or multiplications and divisions, only expressions with no parentheses should be outputted.
This is because any version with parentheses has an equivalent expression without parentheses, and all expressions with parentheses can be easily formed
from an expression without parentheses. For example, 2 + 6 - (3 - (4 - 6)) or 2 + 6 - (3 - 4) + 6 are never outputted; only 2 + 6 - 3 + 4 - 6 is outputted.
This causes the algorithm to not output multiple solutions that are essentially variations of the same solution but with some plus/minus
or multiplication/division signs flipped. In my submitted code, the function solve : float list -> string list takes the input list of floats and outputs a list of solutions.
