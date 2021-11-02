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
  // TODO: uncomment if ignoring string formatting is desired
  // not (
  //   call.getParent().(CallExpr).getTarget().getQualifiedName() =
  //     "github.com/cosmos/cosmos-sdk/types.FormatTimeBytes" or
  //   call.getParent*().(CallExpr).getTarget().getQualifiedName().matches("fmt.Sprintf")
  // ) and
  not call.getEnclosingFunction().getName().matches("Test%") and
  call.getLocation().getFile().getBaseName() != "test_helpers.go" and
  not isIrrelevantPackage(call.getLocation().getFile().getPackageName()) and
  not exists(DataFlow::CallNode telemetryCall |
    telemetryCall
        .getExpr()
        .(CallExpr)
        .getTarget()
        .getQualifiedName()
        .matches("github.com/cosmos/cosmos-sdk/telemetry%")
  |
    DataFlow::localFlow(DataFlow::exprNode(call), telemetryCall.getAnArgument())
  )
select call, "Calling the system time"