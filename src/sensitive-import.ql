/**
 * @name Sensitive package import
 * @kind problem
 * @description Certain system packages (unsafe, rand, reflect, runtime...) may cause a non-deterministic behavior, so a caution should be taken when importing them.
 * @problem.severity recommendation
 * @id crypto-com/cosmos-sdk-codeql/sensitive-import
 * @tags correctness
 */

import go

predicate isSensitiveImport(string packageName) {
  packageName = "unsafe" or
  packageName = "rand" or
  packageName = "reflect" or
  packageName = "runtime"
}

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

from ImportSpec imp
where
  isSensitiveImport(imp.getPath()) and
  not isIrrelevantPackage(imp.getFile().getPackageName()) and
  // explicit comment explaining why it is safe
  // TODO: extract to a common predicate or a class
  not exists(CommentGroup c |
    imp.getLocation().getStartLine() - 1 = c.getLocation().getStartLine()
  |
    c.getAComment().getText().matches("%SAFE:%")
  )
select imp,
  "Certain system packages contain functions which may be a possible source of non-determinism"
