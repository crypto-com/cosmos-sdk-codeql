/**
 * @name Directly using the bech32 constants
 * @description Bech32 constants are hardcoded to Gaia defaults; the external applications would need to use `GetConfig().GetBech32...` functions instead of constants
 * @kind problem
 * @problem.severity warning
 * @id crypto-com/cosmos-sdk-codeql/bech-32-constant
 * @tags correctness
 */

import go

from ConstantName cn
where
  cn.toString().matches("Bech32%") and
  cn.getLocation().getFile().getPackageName() != "types" and
  cn.getLocation().getFile().getPackageName() != "config"
select cn, "Directly using the bech32 constants"
