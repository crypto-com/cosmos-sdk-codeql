/**
 * @name Calling the system time
 * @description Calling the system time is non-deterministic and could cause issues in consensus-critical code.
 * @kind problem
 * @problem.severity warning
 * @id crypto-com/cosmos-sdk-codeql/system-time
 * @tags correctness
 */

import go

predicate isIrrelevantPackage(string packageName) {
  packageName = "cli" or packageName = "main" or packageName = "testutil"
}

from CallExpr call
where
  call.getTarget().getQualifiedName() = "time.Now" and
  // string formatting is usually a false positive (used in logging etc.),
  // so it's usually ok to ignore.
  // but there could be false negatives (if the string formatting output is written to a consensus state)
  not (
    call.getParent().(CallExpr).getTarget().getQualifiedName() =
      "github.com/cosmos/cosmos-sdk/types.FormatTimeBytes" or
    call.getParent*().(CallExpr).getTarget().getQualifiedName().matches("fmt.Sprintf")
  ) and
  not call.getEnclosingFunction().getName().matches("Test%") and
  call.getLocation().getFile().getBaseName() != "test_helpers.go" and
  not isIrrelevantPackage(call.getLocation().getFile().getPackageName()) and
  // ignore cases where time is fed into telemetry calls
  not exists(DataFlow::CallNode telemetryCall |
    telemetryCall
        .getExpr()
        .(CallExpr)
        .getTarget()
        .getQualifiedName()
        .matches("github.com/cosmos/cosmos-sdk/telemetry%")
  |
    DataFlow::localFlow(DataFlow::exprNode(call), telemetryCall.getAnArgument())
  ) and
  // explicit comment explaining why it is safe
  // TODO: extract to a common predicate or a class
  not exists(CommentGroup c |
    call.getLocation().getStartLine() - 1 = c.getLocation().getStartLine() or
    call.getEnclosingFunction().getLocation().getStartLine() - 1 = c.getLocation().getStartLine()
  |
    c.getAComment().getText().matches("%SAFE:%")
  )
select call, "Calling the system time may be a possible source of non-determinism"
