pragma solidity 0.5.16;

import './UniswapV2ERC20.sol';
import './MythXVerificationHelper.sol';

contract VerifyUniswapV2ERC20 is UniswapV2ERC20, MythXVerificationHelper {
    /* BasicToken */

    uint256 private ___mythx_var_prevs_sender_balance;
    uint256 private ___mythx_var_prevs_user0_balance;
    uint256 private ___mythx_var_prevs_this_balance;

    /* ERC20Detailed */

    uint8 private ___mythx_var_const_decimals;
    string private ___mythx_var_const_name;
    string private ___mythx_var_const_symbol;
    uint256 public ___mythx_var_const_totalSupply;

    /**
      * @dev Helpers
    */
    
    address[] private actors; // shadow list for tracking token holders
    mapping(address => bool) private seen;


    /**
      * @dev Add an address to the list of actors if it is encountered for the first time
      * @param _addr Address
    */
    
    function addActor(address _addr) internal {
        
        /* 
        Restrict the number of actors used so we don't introduce an unbounded loop.
        We don't want the symbolic analyzer to go down a rabbit hole. With a bound
        of 4 we account for call sequences that involve:
        
        - creator
        - fixed address _MYTHX_ACCOUNT_0
        - two arbitrary addresses
        
        */
        
        require(actors.length <= 4);
        actors.push(_addr);
    }    

    function addActorIfNew(address _addr) internal {
        if (!seen[_addr]) {
            addActor(_addr);
            seen[_addr] = true;
        }
    }

    function sumBalances() internal returns (uint256) {
        uint256 sum_balances;
    
        for (uint i = 0; i < actors.length; i++) {
            
            uint256 _balance = balanceOf[actors[i]];
        
            if (sum_balances + _balance < sum_balances) {
                emit AssertionFailed("Sum of balances exceeds MAX_UINT256");
            }
        
            sum_balances += _balance;
        }
        
        return sum_balances;
    }

    constructor() public {
        _mythx_init();
    }

    /**
        Initial setup: Snapshot constants and set up a couple of accounts with token balances
     */
    function _mythx_init() internal {
        // Add creator to known accounts
        
        addActor(address(this)); 

        ___mythx_var_const_name = name;
        ___mythx_var_const_symbol = symbol;
        ___mythx_var_const_decimals = decimals;
        ___mythx_var_const_totalSupply = totalSupply;

        // @TODO initialize futher constants

    }

    /**
        this is executed at the beginning of every function to snapshot state variables
     */
    function _mythx_ContractInvariant_snapshot() internal {
        // @TODO this method is called (1) from the constructor to initalize vars and (2) after every _mythx_wrapped_function() to update vars
        
        /* BasicToken */

        ___mythx_var_prevs_sender_balance = balanceOf[msg.sender];
        ___mythx_var_prevs_user0_balance = balanceOf[_MYTHX_ACCOUNT_0];
        ___mythx_var_prevs_this_balance = balanceOf[address(this)];

    }

    function _mythx_ContractInvariant_check() internal {
        // @TODO add check for contract invariants here. This is being called by _mythx_wrapped_function() and proceeded by _mythx_ContractInvariant_snapshot()
        /** checks */
        if ((!((decimals == ___mythx_var_const_decimals)))) {
            emit AssertionFailed('Contract-wide invariant ensures {_decimals == previous(_decimals)} in contract MythXERC20Verification was violated');
        }
        if ((!((_mythx_equals(name, ___mythx_var_const_name))))) {
            emit AssertionFailed('Contract-wide invariant ensures {_name == previous(_name)} in contract MythXERC20Verification was violated');
        }
        if ((!((_mythx_equals(symbol, ___mythx_var_const_symbol))))) {
            emit AssertionFailed('Contract-wide invariant ensures {_symbol == previous(_symbol)} in contract MythXERC20Verification was violated');
        }
        if (!(totalSupply == ___mythx_var_const_totalSupply)) {
            emit AssertionFailed('Contract-wide invariant ensures {totalSupply is constant} in contract MythXERC20Verification was violated');
        }
        if (!(totalSupply == sumBalances())) {
            emit AssertionFailed('Contract-wide invariant ensures {totalSupply matches sum of balances} in contract MythXERC20Verification was violated');
        }
        if (!(balanceOf[address(0)] == 0)) {
            emit AssertionFailed('Contract-wide invariant ensures {invariant balanceOf(address(0)) == 0} in contract MythXERC20Verification was violated');
        }
        if (balanceOf[_MYTHX_ACCOUNT_0] < ___mythx_var_prevs_user0_balance && msg.sender != _MYTHX_ACCOUNT_0) {
                emit AssertionFailed('Contract-wide invariant ensures {only user can lower its own balance} in contract MythXERC20Verification was violated');
        }

    }

    /**
        Method Wrappers
    */
    // @TODO copy the original function signature form the ContractUnderTest and add the _mythx_wrapped_function() modifier.

    function transfer(address to, uint256 value) public _mythx_wrapped_function() returns (bool) {
        uint256 ___mythx_local_balance_from_pre = balanceOf[msg.sender];
        uint256 ___mythx_local_balance_to_pre = balanceOf[to];

        bool ret = super.transfer(to, value);

        if(to == address(0)){
            emit AssertionFailed('transfer(to=address(0), ...) should raise an exception');
        }

        if(!(value<=___mythx_local_balance_from_pre)){
            emit AssertionFailed('transfer should raise an exception if amount > balanceOf(from)');
        }

        if(!(balanceOf[msg.sender] <= totalSupply && balanceOf[to] <= totalSupply)){
            emit AssertionFailed('balanceOf(from || to) is <= totalSupply');
        }

        if(!(___mythx_local_balance_from_pre + ___mythx_local_balance_to_pre == balanceOf[msg.sender] + balanceOf[to])){
                emit AssertionFailed('sum of balances of sender and receiver stays constant');
        }
        
        if (ret && value > 0) {
            if (___mythx_local_balance_from_pre == balanceOf[msg.sender] || ___mythx_local_balance_to_pre == balanceOf[to]) {
               emit AssertionFailed('non-zero token transfer returned true but token transfer was not completed');
            }
        }

        if (___mythx_local_balance_from_pre != balanceOf[msg.sender] || ___mythx_local_balance_to_pre != balanceOf[to]) {
            // at least one of the balances of the actors has changed, indicating that a transfer happened
            
            if (!ret) {
                 emit AssertionFailed('tokens transferred but transfer returns false');
            }
            
            if (!(value > 0)) {
                emit AssertionFailed('zero value transfer should not modify balances');
            }
            
            if(!(balanceOf[to] > ___mythx_local_balance_to_pre)) {
                emit AssertionFailed('receiver balance did not increase');
            } 
            
            if(!(___mythx_local_balance_to_pre + value == balanceOf[to])) {
                emit AssertionFailed('receiver balance did not increase by value transferred');
            } 
            
            if(!(balanceOf[msg.sender] < ___mythx_local_balance_from_pre)) {
                emit AssertionFailed('sender balance did not decrease');
            }
    
            if(!(___mythx_local_balance_from_pre - value == balanceOf[msg.sender])) {
                emit AssertionFailed('sender balance did not decrease by value transferred');
            }
        }
        
        addActorIfNew(to);
        addActorIfNew(msg.sender);

        return ret;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public _mythx_wrapped_function() returns (bool) {

        addActorIfNew(sender);
        addActorIfNew(recipient);

        uint256 ___mythx_local_allowance_pre = allowance[sender][recipient];
        uint256 ___mythx_local_balance_from_pre = balanceOf[sender];
        uint256 ___mythx_local_balance_to_pre = balanceOf[recipient];
        
        // call
        bool ret = super.transferFrom(sender, recipient, amount);

        if(sender == address(0)){
            emit AssertionFailed('transferFrom(spender=address(0), ...) should raise an exception');
        }
        if(!(recipient != address(0))){
            emit AssertionFailed('transferFrom(recipient=address(0), ...) should raise an exception');
        }
        if(!(balanceOf[sender] <= totalSupply && balanceOf[recipient] <= totalSupply)){
            emit AssertionFailed('balanceOf(from || to) is <= totalSupply');
        }
        //allowance
        if(!(___mythx_local_allowance_pre >= amount)){
            emit AssertionFailed('transferFrom() - should raise an exception if allowance < amount');
        }
        if(!(___mythx_local_allowance_pre - amount == allowance[sender][recipient])){
            emit AssertionFailed('transferFrom() - old(allowance) - amount == new allowance');
        }
        //balances
        if(!(___mythx_local_balance_from_pre + ___mythx_local_balance_to_pre == balanceOf[sender] + balanceOf[recipient])){
                emit AssertionFailed('sum of balances of sender and receiver stays constant');
        }
        if(!(___mythx_local_balance_from_pre >= amount)){
            emit AssertionFailed('transferFrom() - should raise an exception if allowance < amount');
        }

        if (___mythx_local_balance_from_pre != balanceOf[sender] || ___mythx_local_balance_to_pre != balanceOf[recipient]) {
            // at least one of the balances of the actors has changed, indicating that a transfer happened
            
            if (!ret) {
                 emit AssertionFailed('tokens transferred but transferFrom returns false');
            }
            
            if (!(amount > 0)) {
                emit AssertionFailed('zero value transfer should not modify balances');
            }
            
            if(!(allowance[sender][recipient] < ___mythx_local_allowance_pre)){
                emit AssertionFailed('transferFrom() - allowance should be lower following transfer');
            }            
                
            if(!(balanceOf[recipient] > ___mythx_local_balance_to_pre)) {
                emit AssertionFailed('receiver balance did not increase');
            } 
            
            if(!(___mythx_local_balance_to_pre + amount == balanceOf[recipient])) {
                emit AssertionFailed('receiver balance did not increase by value transferred');
            } 
            
            if(!(balanceOf[msg.sender] < ___mythx_local_balance_from_pre)) {
                emit AssertionFailed('sender balance did not decrease');
            }
    
            if(!(___mythx_local_balance_from_pre - amount == balanceOf[msg.sender])) {
                emit AssertionFailed('sender balance did not decrease by value transferred');
            }
        }
    }

    function approve(address spender, uint256 amount) public _mythx_wrapped_function() returns (bool) {

        bool ret = super.approve(spender, amount);

        if(spender == address(0)){
            emit AssertionFailed('approve(spender=address(0), ...) should raise an exception');
        }

        if(!(allowance[msg.sender][spender]==amount)){
            emit AssertionFailed('approve() allowance is correctly accounted');
        }

        return ret;
    }

}
