/**
 * @name Floating point arithmetic
 * @kind problem
 * @description Floating point operations are not associative and may lead to surprising situations: https://en.wikipedia.org/wiki/Floating-point_arithmetic#Accuracy_problems
 * @problem.severity recommendation
 * @id crypto-com/cosmos-sdk-codeql/floating-point-arithmetic
 * @tags correctness
 */

import go

from ArithmeticBinaryExpr e
where
  (
    e.getLeftOperand().getType() instanceof FloatType or
    e.getRightOperand().getType() instanceof FloatType
  ) and
  e.getLocation().getFile().getPackageName() != "simulation" and
  // explicit comment explaining why it is safe
  // TODO: extract to a common predicate or a class
  not exists(CommentGroup c |
    e.getLocation().getStartLine() - 1 = c.getLocation().getStartLine() or
    e.getEnclosingFunction().getLocation().getStartLine() - 1 = c.getLocation().getStartLine()
  |
    c.getAComment().getText().matches("%SAFE:%")
  )
select e, "Floating point arithmetic"
