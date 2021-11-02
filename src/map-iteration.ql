/**
 * @name Iteration over map 
 * @description Iteration over map is non-deterministic and could cause issues in consensus-critical code.
 * @kind problem
 * @problem.severity warning
 * @id crypto-com/cosmos-sdk-codeql/map-iteration
 * @tags correctness
 */

import go

from RangeStmt loop
where loop.getDomain().getType() instanceof MapType
select loop, "Iteration over map"