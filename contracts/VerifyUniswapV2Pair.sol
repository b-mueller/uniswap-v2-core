pragma solidity =0.5.16;

import './UniswapV2Pair.sol';
import './MythXVerificationHelper.sol';

contract VerifyUniswapV2Pair is UniswapV2Pair, MythXVerificationHelper {

    uint256 private ___mythx_var_prevs_reserve0;
    uint256 private ___mythx_var_prevs_reserve1;

    function _mythx_init() internal {
    }

    function _mythx_ContractInvariant_snapshot() internal {
        ___mythx_var_prevs_reserve0 = reserve0;
        ___mythx_var_prevs_reserve1 = reserve1;
    }

    function _mythx_ContractInvariant_check() internal {

        if (!((reserve0 == ___mythx_var_prevs_reserve0 && reserve1 == ___mythx_var_prevs_reserve1)) || unlocked == 1) {
            emit AssertionFailed("[P1] Reserves must remain constant unless the contract is unlocked.");
        }

         if (!(reserve0 <= uint112(-1) && reserve0 <= uint112(-1))) {
             emit AssertionFailed("[P2] The value in reserves must be lower than the maximum 112 bit unsigned integer.");            
         }

         if (!(totalSupply == 0 || totalSupply >= MINIMUM_LIQUIDITY)) {
            emit AssertionFailed("[P3] totalSupply must be either zero or greater than minimum liquidity");
         }

    }

    function initialize(address _token0, address _token1) public _mythx_wrapped_function() {
        super.initialize(_token0, _token1);
    }

    function mint(address to) public _mythx_wrapped_function() returns (uint liquidity) {
        super.mint(to);
    }

    function burn(address to) public  _mythx_wrapped_function() returns (uint amount0, uint amount1) {
        super.burn(to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes memory data) public   _mythx_wrapped_function() {
        super.swap(amount0Out, amount1Out, to, data);
    }

    // force balances to match reserves
    function skim(address to) public _mythx_wrapped_function() {
        super.skim(to);
    }

    // force reserves to match balances
    function sync() public _mythx_wrapped_function() {
        super.sync();
    }
}
