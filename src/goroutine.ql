/**
 * @name Spawning a Go routine
 * @kind problem
 * @description The execution order of Go routines may cause a non-deterministic behavior, so a caution should be taken when using Go routines in consensus-critical code sections.
 * @problem.severity recommendation
 * @id crypto-com/cosmos-sdk-codeql/goroutine
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
  packageName = "genutil" or
  packageName = "memdb" or
  packageName = "db" or
  packageName = "server" or
  packageName = "snapshots" or
  packageName = "file" or
  packageName = "network" or
  packageName = "grpc"
}

from GoStmt goroutine
where
  not goroutine.getFile().getBaseName().matches("%.pb.%") and
  not goroutine.getCall().getCalleeName().matches("%Snapshot%") and
  not isIrrelevantPackage(goroutine.getFile().getPackageName())
select goroutine, goroutine.getFile().getPackageName()
