/**
 * @name Panic in BeginBock or EndBlock consensus methods
 * @description Panics in BeginBlocker and EndBlocker could cause a chain halt: https://docs.cosmos.network/master/building-modules/beginblock-endblock.html
 * @kind problem
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


class CallNodeWithFamily extends DataFlow::CallNode, DataFlow::Node  {

  CallNodeWithFamily() {
    this instanceof DataFlow::CallNode
  }
 
  DataFlow::CallNode getParentCallNode (){
    result.getACallee() = this.getRoot()
  }  
}


/* This query looks for all calls to panic that originated from EndBlock or BeginBlock
(as defined by the isBeginOrEndBlock predicate).
It excludes potential false-positives (as defined by isLikelyFalsePositive predicate) 
and those stemming from irrelevant packages (as defined by isIrrelevantPackage predicate).
It also exludes panics which are preceded by a comment containing the string "SAFE:".
*/
from CallNodeWithFamily panicCall, CallNodeWithFamily sourceCall
where
  panicCall.getTarget().mustPanic() and
  sourceCall = panicCall.getParentCallNode*() and

  isBeginOrEndBlock(sourceCall.getEnclosingCallable().getName()) and
  not isIrrelevantPackage(panicCall.getFile().getPackageName()) and
  // explicit comment explaining why it is safe
  // TODO: extract to a common predicate or a class
  not exists(CommentGroup c |
    panicCall.asExpr().getLocation().getStartLine() - 1 = c.getLocation().getStartLine() or
    panicCall.asExpr().getEnclosingFunction().getLocation().getStartLine() - 1 =
      c.getLocation().getStartLine()
  |
    c.getAComment().getText().matches("%SAFE:%")
  )
select panicCall,
  "Possible panics in BeginBock- or EndBlock-related consensus methods could cause a chain halt"
  
