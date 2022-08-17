// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../forward/IForwarder.sol";

contract RelayHub {

    bytes32 constant RELAY_REQUEST_TYPEHASH = "relay";

    address public forwarder; //no need this state-variable, just demo use

    uint256 public gasLimit;
    function updateGasLimit(uint256 _gasLimit) public {
        gasLimit = _gasLimit;
    }

    function updateForwarder(address _forwarder) external {
        forwarder = _forwarder;
    }

    function relayCall(ForwardRequest calldata relayRequest, bytes calldata signature)
        external returns(bytes memory relayedCallReturnValue) {
        //preRelay
        {
            bool forwarderSuccess;
            bool relayedCallSuccess;
            //bytes memory relayedCallReturnValue;
            (forwarderSuccess, relayedCallSuccess, relayedCallReturnValue) = execute(relayRequest, signature);
            if ( !forwarderSuccess ) {
                revert("forward fail");
                //revertWithStatus(RelayCallStatus.RejectedByForwarder, vars.relayedCallReturnValue);
            }
            if (!relayedCallSuccess) {
                revert("relayedSuccess");
            }
        }
        //postRelay
    }

    function execute(ForwardRequest calldata relayRequest, bytes calldata signature)
        public returns (bool forwarderSuccess, bool callSuccess, bytes memory ret) {

        (forwarderSuccess, ret) = forwarder.call{gas:gasLimit}(
            abi.encodeWithSelector(IForwarder.execute.selector,
                relayRequest, RELAY_REQUEST_TYPEHASH, bytes(""), signature
            ));
        if ( forwarderSuccess ) {
            //decode return value of execute:
            (callSuccess, ret) = abi.decode(ret, (bool, bytes));
        }
        //truncateInPlace(ret); //need research
    }
}