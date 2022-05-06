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
  packageName = "testdata_pulsar" or
  packageName = "rosetta" or
  packageName = "simapp" or
  packageName = "simulation" or
  packageName = "testutil" or
  packageName = "client" or
  packageName = "cli" or
  packageName = "mocks" or
  packageName = "mock" or
  packageName = "version" or
  packageName = "genutil"
}

from RangeStmt loop
where
  loop.getDomain().getType() instanceof MapType and
  // ignore iterations over maps where keys are subsequently sorted
  // TODO: make it more general to also ignore cases where keys are written to fields
  // in structs that are stored in arrays which are then sorted by those fields
  not exists(
    Assignment a, CallExpr sort, VariableName unsorted, VariableName sorted, VariableName key
  |
    loop.getBody().getAChild*() = a and
    sort.getTarget().getQualifiedName().prefix(4) = "sort" and
    a.getAnRhs().getAChild*() = key and
    key.getTarget() = loop.getKey().(VariableName).getTarget() and
    a.getAnLhs() = unsorted and
    sort.getAnArgument() = sorted and
    unsorted.getTarget() = sorted.getTarget() and
    loop.getParent*().getAChild*() = sort
  ) and
  not isIrrelevantPackage(loop.getFile().getPackageName())
select loop, "Iteration over map"
