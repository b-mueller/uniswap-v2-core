pragma solidity =0.5.16;

import './UniswapV2Pair.sol';
import './MythXVerificationHelper.sol';

contract VerifyUniswapV2Pair is UniswapV2Pair, MythXVerificationHelper {

    function _mythx_init() internal {
    }

    function _mythx_ContractInvariant_snapshot() internal {
    }

    function _mythx_ContractInvariant_check() internal {

         if (!(unlocked == 1)) {
            emit AssertionFailed("[P1] All functions should revert if unlocked == 0.");             
             
         }

         if (!(totalSupply == 0 || totalSupply >= MINIMUM_LIQUIDITY)) {
            emit AssertionFailed("[P1] If totalSupply > 0 it must be equal toor greater than minimum liquidity");
         }

    }

    function initialize(address _token0, address _token1) public {
        super.initialize(_token0, _token1);
    }

    function mint(address to) public returns (uint liquidity) {
        super.mint(to);
    }

    function burn(address to) public returns (uint amount0, uint amount1) {
        super.burn(to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes memory data) public {
        super.swap(amount0Out, amount1Out, to, data);
    }

    // force balances to match reserves
    function skim(address to) public {
        super.skim(to);
    }

    // force reserves to match balances
    function sync() public {
        super.sync();
    }
}
