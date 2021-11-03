/**
 * @name Iteration over map
 * @description Iteration over map is non-deterministic and could cause issues in consensus-critical code.
 * @kind problem
 * @problem.severity warning
 * @id crypto-com/cosmos-sdk-codeql/map-iteration
 * @tags correctness
 */

import go

predicate isIrrelevantPackage(string packageName) {
  packageName = "testdata" or
  packageName = "simapp" or
  packageName = "testutil" or
  packageName = "client" or
  packageName = "cli"
}

from RangeStmt loop
where
  loop.getDomain().getType() instanceof MapType and
  not isIrrelevantPackage(loop.getFile().getPackageName())
select loop, "Iteration over map"
