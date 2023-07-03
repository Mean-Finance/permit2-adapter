// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import { IPermit2 } from "../interfaces/external/IPermit2.sol";
import { Token } from "./Token.sol";

/**
 * @title Permit2 Transfers Library
 * @author Sam Bugs
 * @notice A small library to call Permit2's transfer from methods
 */
library Permit2Transfers {
  /**
   * @notice Executes a transfer from using Permit2
   * @param _permit2 The Permit2 contract
   * @param _token The token to transfer
   * @param _amount The amount to transfer
   * @param _nonce The owner's nonce
   * @param _deadline The signature's expiration deadline
   * @param _signature The signature that allows the transfer
   */
  function takeFromCaller(
    IPermit2 _permit2,
    address _token,
    uint256 _amount,
    uint256 _nonce,
    uint256 _deadline,
    bytes calldata _signature
  )
    internal
  {
    if (address(_token) != Token.NATIVE_TOKEN) {
      _permit2.permitTransferFrom(
        // The permit message.
        IPermit2.PermitTransferFrom({
          permitted: IPermit2.TokenPermissions({ token: _token, amount: _amount }),
          nonce: _nonce,
          deadline: _deadline
        }),
        // The transfer recipient and amount.
        IPermit2.SignatureTransferDetails({ to: address(this), requestedAmount: _amount }),
        // The owner of the tokens, which must also be
        // the signer of the message, otherwise this call
        // will fail.
        msg.sender,
        // The packed signature that was the result of signing
        // the EIP712 hash of `permit`.
        _signature
      );
    }
  }
}