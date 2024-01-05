// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { UniversalPermit2Adapter, IPermit2, Token, ISwapPermit2Adapter } from "../../src/UniversalPermit2Adapter.sol";
import { Utils } from "../Utils.sol";

/// @dev The calldatas to send to 0x in these tests where generated by calling their API
contract SwapPermit2AdapterTest is PRBTest, StdCheats {
  IPermit2 internal constant PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);
  IERC20 internal constant USDC = IERC20(0x7F5c764cBc14f9669B88837ca1490cCa17c31607);
  IERC20 internal constant DAI = IERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
  uint256 internal constant NONCE = 0;
  uint256 internal constant DEADLINE = type(uint256).max;
  address internal constant ZRX = 0xDEF1ABE32c034e558Cdd535791643C58a13aCC10;
  UniversalPermit2Adapter internal adapter;
  address internal alice = 0x9baA1c73dA6EaDE1D9Cd299b380181EFDDD38D0f;
  address internal feeRecipient = address(10);
  uint256 internal aliceKey = 0x3b226dfc360dd6c280a1e10cf039309949f0e1144cb24a233fd9512cd5c6edcd;

  function setUp() public virtual {
    vm.createSelectFork({ urlOrAlias: "optimism", blockNumber: 106_308_565 });

    // Alice gives full approval to Permit2
    vm.startPrank(alice);
    USDC.approve(address(PERMIT2), type(uint256).max);
    DAI.approve(address(PERMIT2), type(uint256).max);
    vm.stopPrank();

    // We are using the universal adapter to test arbitrary execution so that we can verify the full integration
    adapter = new UniversalPermit2Adapter(PERMIT2);
  }

  function testFork_sellOrderSwap_ERC20ToNativeWith0x() public {
    uint256 _amountToSwap = 10_000e6; // 10k USDC

    bytes memory _swapData = abi.encodePacked(
      // solhint-disable max-line-length
      hex"415565b00000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000002540be4000000000000000000000000000000000000000000000000004751e930cdd32e7300000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000005a00000000000000000000000000000000000000000000000000000000000000640000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000004e0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000004200000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000004a0000000000000000000000000000000000000000000000000000000000000044000000000000000000000000000000000000000000000000000000002540be400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000012556e69737761705633000000000000000000000000000000000000000000000000000000000000000000000218711a000000000000000000000000000000000000000000000000004030174e4bfde97e000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000e592427a0aece92de3edee1f18e0157c058615640000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002b7f5c764cbc14f9669b88837ca1490cca17c316070001f4420000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000012556e6973776170563300000000000000000000000000000000000000000000000000000000000000000000003b9aca000000000000000000000000000000000000000000000000000721d1e281d544f5000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000e592427a0aece92de3edee1f18e0157c05861564000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000427f5c764cbc14f9669b88837ca1490cca17c3160700006494b008aa00579c1307b0ef2c499ad98a8ce58e580001f4420000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000400000000000000000000000004200000000000000000000000000000000000006ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000010000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000000000000000000000000000000000000000000000869584cd0000000000000000000000001000000000000000000000000000000000000011000000000000000000000000000000000000000000000056162c9cf464a02163"
    );
    uint256 _minAmountOut = 5e18; // 5 ETH

    // Prepare
    deal(address(USDC), alice, _amountToSwap);
    bytes memory _signature = Utils.signPermit(
      address(USDC), _amountToSwap, NONCE, DEADLINE, address(adapter), aliceKey, PERMIT2.DOMAIN_SEPARATOR()
    );

    // Execute
    vm.prank(alice);
    (uint256 _returnedAmountIn, uint256 _returnedAmountOut) = adapter.sellOrderSwap(
      ISwapPermit2Adapter.SellOrderSwapParams({
        deadline: DEADLINE,
        tokenIn: address(USDC),
        amountIn: _amountToSwap,
        nonce: NONCE,
        signature: _signature,
        allowanceTarget: ZRX,
        swapper: ZRX,
        swapData: _swapData,
        tokenOut: Token.NATIVE_TOKEN,
        minAmountOut: _minAmountOut,
        transferOut: Utils.buildDistribution(feeRecipient, 100, alice), // 1% for fee recipient, rest for alice
        misc: ""
      })
    );

    // Assertions
    assertEq(_returnedAmountIn, _amountToSwap);
    assertGt(_returnedAmountOut, _minAmountOut);
    assertEq(USDC.balanceOf(alice), 0);
    assertEq(USDC.balanceOf(address(adapter)), 0);
    assertEq(address(adapter).balance, 0);
    assertEq(feeRecipient.balance, _returnedAmountOut / 100);
    assertEq(alice.balance, _returnedAmountOut - _returnedAmountOut / 100);
  }

  function testFork_sellOrderSwap_NativeToERC20With0x() public {
    uint256 _amountToSwap = 5e18; // 5 ETH

    bytes memory _swapData = abi.encodePacked(
      // solhint-disable max-line-length
      hex"415565b0000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000000000000000000000000000004563918244f40000000000000000000000000000000000000000000000000000000000023793ee7300000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000760000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000040000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000004563918244f40000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042000000000000000000000000000000000000060000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000005c000000000000000000000000000000000000000000000000000000000000005c000000000000000000000000000000000000000000000000000000000000005400000000000000000000000000000000000000000000000004563918244f40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c00000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000012556e69737761705633000000000000000000000000000000000000000000000000000000000000003e7336287142000000000000000000000000000000000000000000000000000000000001fed328f9000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000e592427a0aece92de3edee1f18e0157c058615640000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002b42000000000000000000000000000000000000060001f47f5c764cbc14f9669b88837ca1490cca17c3160700000000000000000000000000000000000000000000000000000000000000000000000012556e6973776170563300000000000000000000000000000000000000000000000000000000000000053444835ec58000000000000000000000000000000000000000000000000000000000002a9073f7000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000e592427a0aece92de3edee1f18e0157c058615640000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000004242000000000000000000000000000000000000060001f494b008aa00579c1307b0ef2c499ad98a8ce58e580000647f5c764cbc14f9669b88837ca1490cca17c316070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d56656c6f64726f6d650000000000000000000000000000000000000000000000000000000000000001bc16d674ec8000000000000000000000000000000000000000000000000000000000000e30518200000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000040000000000000000000000000a132dab612db5cb9fc9ac426a0cc215a3423f9c9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000020000000000000000000000004200000000000000000000000000000000000006000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd0000000000000000000000001000000000000000000000000000000000000011000000000000000000000000000000000000000000000071f7f8cd6364a02162"
    );
    uint256 _minAmountOut = 9000e6; // 9k USDC

    // Prepare
    deal(alice, _amountToSwap);

    // Execute
    vm.prank(alice);
    (uint256 _returnedAmountIn, uint256 _returnedAmountOut) = adapter.sellOrderSwap{ value: _amountToSwap }(
      ISwapPermit2Adapter.SellOrderSwapParams({
        deadline: DEADLINE,
        tokenIn: address(0),
        amountIn: _amountToSwap,
        nonce: 0,
        signature: "",
        allowanceTarget: address(0),
        swapper: ZRX,
        swapData: _swapData,
        tokenOut: address(USDC),
        minAmountOut: _minAmountOut,
        transferOut: Utils.buildDistribution(feeRecipient, 100, alice), // 1% for fee recipient, rest for alice
        misc: ""
      })
    );

    // Assertions
    assertEq(_returnedAmountIn, _amountToSwap);
    assertGt(_returnedAmountOut, _minAmountOut);
    assertEq(alice.balance, 0);
    assertEq(address(adapter).balance, 0);
    assertEq(USDC.balanceOf(address(adapter)), 0);
    assertEq(USDC.balanceOf(feeRecipient), _returnedAmountOut / 100);
    assertEq(USDC.balanceOf(alice), _returnedAmountOut - _returnedAmountOut / 100);
  }

  function testFork_buyOrderSwap_ERC20ToERC20With0x() public {
    uint256 _maxAmountIn = 15_000e18; // 15k DAI

    bytes memory _swapData = abi.encodePacked(
      // solhint-disable max-line-length
      hex"415565b0000000000000000000000000da10009cbd5d07dd0cecc66161fc93d7c9000da10000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000000000000000000000000223eb2a0c9772b6afde00000000000000000000000000000000000000000000000000000002540be40000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003e0000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001000000000000000000000000da10009cbd5d07dd0cecc66161fc93d7c9000da10000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c3160700000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000002540be400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000012556e6973776170563300000000000000000000000000000000000000000000000000000000000223eb2a0c9772b6afde00000000000000000000000000000000000000000000000000000002540be400000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000e592427a0aece92de3edee1f18e0157c058615640000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002bda10009cbd5d07dd0cecc66161fc93d7c9000da10000647f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000da10009cbd5d07dd0cecc66161fc93d7c9000da1000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd0000000000000000000000001000000000000000000000000000000000000011000000000000000000000000000000000000000000000057997885a364a02161"
    );
    uint256 _amountOut = 10_000e6; // 10k USDC

    // Prepare
    deal(address(DAI), alice, _maxAmountIn);
    bytes memory _signature = Utils.signPermit(
      address(DAI), _maxAmountIn, NONCE, DEADLINE, address(adapter), aliceKey, PERMIT2.DOMAIN_SEPARATOR()
    );

    // Execute
    vm.prank(alice);
    (uint256 _returnedAmountIn, uint256 _returnedAmountOut) = adapter.buyOrderSwap(
      ISwapPermit2Adapter.BuyOrderSwapParams({
        deadline: DEADLINE,
        tokenIn: address(DAI),
        maxAmountIn: _maxAmountIn,
        nonce: NONCE,
        signature: _signature,
        allowanceTarget: ZRX,
        swapper: ZRX,
        swapData: _swapData,
        tokenOut: address(USDC),
        amountOut: _amountOut,
        transferOut: Utils.buildDistribution(feeRecipient, 100, alice), // 1% for fee recipient, rest for alice
        unspentTokenInRecipient: address(0), // Return to caller (in this case alice)
        misc: ""
      })
    );

    // Assertions
    assertLte(_returnedAmountIn, _maxAmountIn);
    assertGt(_returnedAmountOut, _amountOut);
    assertEq(DAI.balanceOf(alice), _maxAmountIn - _returnedAmountIn);
    assertEq(DAI.balanceOf(address(adapter)), 0);
    assertEq(USDC.balanceOf(address(adapter)), 0);
    assertEq(USDC.balanceOf(feeRecipient), _returnedAmountOut / 100);
    assertEq(USDC.balanceOf(alice), _returnedAmountOut - _returnedAmountOut / 100);
  }
}
