/**
 * @name Panic in BeginBock or EndBlock consensus methods
 * @description Panics in BeginBlocker and EndBlocker could cause a chain halt: https://docs.cosmos.network/master/building-modules/beginblock-endblock.html
 * @kind path-problem
 * @precision low
 * @problem.severity warning
 * @id crypto-com/cosmos-sdk-codeql/beginendblock-panic
 * @tags correctness
 */

import go

predicate isBeginOrEndBlock(string funName) {
  // TODO: make it more precise to check if it's from Keeper or ABCI interface
  funName = "BeginBlock" or
  funName = "EndBlock" or
  funName = "BeginBlocker" or
  funName = "EndBlocker"
}

predicate isIrrelevantPackage(string packageName) {
  // for normal cases, panics to cause chain halts are desired in crisis or upgrade
  // (but there may be unwanted cases, i.e. false negatives)
  packageName = "crisis" or
  packageName = "upgrade" or
  packageName = "mocks"
}

class CallNodeWithFamily extends DataFlow::CallNode, DataFlow::Node {
  CallNodeWithFamily() { this instanceof DataFlow::CallNode }

  DataFlow::CallNode getChildCallNode() { this.getACallee() = result.getRoot() }
}

query predicate edges(CallNodeWithFamily a, CallNodeWithFamily b) { a.getChildCallNode() = b }

/*
 * This query looks for all function call paths  originating from EndBlock or BeginBlock
 * (as defined by the isBeginOrEndBlock predicate) and ending in a panic.
 * It excludes irrelevant packages (as defined by isIrrelevantPackage predicate).
 * It also exludes panics which are preceded by a comment containing the string "SAFE:".
 */

from CallNodeWithFamily panicCall, CallNodeWithFamily sourceCall
where
  panicCall.getTarget().mustPanic() and
  edges*(sourceCall, panicCall) and
  isBeginOrEndBlock(sourceCall.getEnclosingCallable().getName()) and
  not isIrrelevantPackage(panicCall.getFile().getPackageName()) and
  not panicCall.getArgument(0).getStringValue() = "not implemented" and
  // explicit comment explaining why it is safe
  // TODO: extract to a common predicate or a class
  not exists(CommentGroup c |
    panicCall.asExpr().getLocation().getStartLine() - 1 = c.getLocation().getStartLine() or
    panicCall.asExpr().getEnclosingFunction().getLocation().getStartLine() - 1 =
      c.getLocation().getStartLine()
  |
    c.getAComment().getText().matches("%SAFE:%")
  )
select sourceCall, sourceCall, panicCall, "path flow from Begin/EndBlock to a panic call"
