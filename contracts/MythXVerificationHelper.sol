pragma solidity >=0.4.19 <0.7.0;

/** verification helper */
contract MythXVerificationHelper {
    address public constant _MYTHX_CREATOR = 0xafFEaFFEAFfeAfFEAffeaFfEAfFEaffeafFeAFfE; // a user account with a very high balance (typically the contract creator)
    address public constant _MYTHX_ATTACKER = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF; // represents the attacker in generic bug checks
    address public constant _MYTHX_ACCOUNT_0 = 0xAaaaAaAAaaaAAaAAaAaaaaAAAAAaAaaaAaAaaAA0; // a user account with non-zero balance
    address public constant _MYTHX_ACCOUNT_1 = 0xAaAAAaaAAAAAAaaAAAaaaaAaAaAAAAaAAaAaAaA1; // a user account with balance 0
    address public constant _MYTHX_ACCOUNT_2 = 0xAaAaaAAAaAaaAaAaAaaAAaAaAAAAAaAAAaaAaAa2; // a user account with a very high balance
    address public constant _MYTHX_ACCOUNT_3 = 0xaaaaAaAaaAAaAaaaaAaAAAAAaAAAaAaaaAAaAaa3; // a contract that just returns normally (non-zero balance)
    address public constant _MYTHX_ACCOUNT_4 = 0xAaaaAaaAaAAaaaAaaAAaaAaaAaAaAaAAAAAaaaa4; // a contract that fails by reverting (non-zero balance)
    address public constant _MYTHX_ACCOUNT_5 = 0xAAaaaaAaaAaaaAAAAAaAAaAAaaaaaAaAAAaAaaA5; // a contract that fails by jumping to destination 0 (non-zero balance)
    address public constant _MYTHX_ACCOUNT_6 = 0xaaAAAAAaaaaaaaaAAaAAaaaAaAaaAAaaaaAaAaa6; // a contract that will selfdestruct when called via delegatecall or callcode (non-zero balance)

    event AssertionFailed(string message);

    uint256 private callDepth = 0;

    modifier _mythx_wrapped_function() {
        _mythx_startCall();
        if (_mythx_isOuterCall()) _mythx_ContractInvariant_snapshot();
        _;
        if (_mythx_isOuterCall()) _mythx_ContractInvariant_check();
        _mythx_endCall();
    }

    function _mythx_init() internal {
        //override
        revert("override this method!");
    }

    function _mythx_ContractInvariant_snapshot() internal {
        //override
        revert("override this method!");
    }

    function _mythx_ContractInvariant_check() internal {
        //override
        // perform checks
        revert("override this method!");
    }

    function _mythx_startCall() internal {
        (callDepth++); // mythx-disable-line SWC-101
    }

    function _mythx_endCall() internal {
        (callDepth--); // mythx-disable-line SWC-101
    }

    function _mythx_isOuterCall() internal view returns (bool) {
        return (callDepth == 1);
    }

    function _mythx_equals(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
