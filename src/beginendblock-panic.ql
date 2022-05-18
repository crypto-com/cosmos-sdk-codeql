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

predicate isLikelyFalsePositive(Function f) {
  // these could potentially lead to false negatives
  // but otherwise, there are hundreds of findings
  f.getName()
      .regexpMatch("(BeginBlock(er)?|EndBlock(er)?" +
          "|Logger|Now|NewAttribute|Error|Info|With|.*Event" +
          "|GetVotes|String|BlockHeight|NewCoins|MsgTypeURL|Listen" +
          "|CacheContext|ModuleSetGauge|BlockHeader|getMaximumBlockGas" +
          "|Sprintf|ModuleMeasureSince|.*Params|.*Tracing|.*GasMeter).*")
}

predicate isIrrelevantPackage(string packageName) {
  // for normal cases, panics to cause chain halts are desired in crisis or upgrade
  // (but there may be unwanted cases, i.e. false negatives)
  packageName = "crisis" or packageName = "upgrade" or packageName = "mocks"
}

from CallExpr panicCall
where
  panicCall.getTarget().mayPanic() and
  isBeginOrEndBlock(panicCall.getParent*().getEnclosingFunction().getName()) and
  not isLikelyFalsePositive(panicCall.getTarget()) and
  not isIrrelevantPackage(panicCall.getFile().getPackageName()) and
  // explicit comment explaining why it is safe
  // TODO: extract to a common predicate or a class
  not exists(CommentGroup c |
    panicCall.getLocation().getStartLine() - 1 = c.getLocation().getStartLine() or
    panicCall.getEnclosingFunction().getLocation().getStartLine() - 1 =
      c.getLocation().getStartLine()
  |
    c.getAComment().getText().matches("%SAFE:%")
  )
select panicCall,
  "Possible panics in BeginBock- or EndBlock-related consensus methods could cause a chain halt"
