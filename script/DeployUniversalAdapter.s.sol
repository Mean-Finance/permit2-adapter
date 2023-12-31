// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { console2 } from "forge-std/console2.sol";
import { UniversalPermit2Adapter, IPermit2 } from "../src/UniversalPermit2Adapter.sol";
import { BaseScript } from "./Base.s.sol";

IPermit2 constant PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

contract DeployUniversalAdapter is BaseScript {
  function run() public broadcaster returns (UniversalPermit2Adapter _adapter) {
    _adapter = new UniversalPermit2Adapter{ salt: ZERO_SALT }(PERMIT2);
    console2.log("Permit2 Deployed:", address(_adapter));
  }
}
