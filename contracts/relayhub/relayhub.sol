// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../forward/IForwarder.sol";

contract RelayHub {
    bool[10] public debug;
    bytes32 public debugSelector;

    bytes32 constant RELAY_REQUEST_TYPEHASH = "relay";

    address public forwarder; //no need this state-variable, just demo use

    uint256 public gasLimit;
    function updateGasLimit(uint256 _gasLimit) public {
        gasLimit = _gasLimit;
    }

    struct RelayRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }

    function updateForwarder(address _forwarder) external {
        forwarder = _forwarder;
    }

    function relayCall(ForwardRequest calldata relayRequest, bytes calldata signature)
        external returns(bytes memory relayedCallReturnValue) {
        //preRelay
        debug[0] = true;
        {
            debug[1] = true;
            bool forwarderSuccess;
            bool relayedCallSuccess;
            //bytes memory relayedCallReturnValue;
            (forwarderSuccess, relayedCallSuccess, relayedCallReturnValue) = execute(relayRequest, signature);
            debug[2] = true;
            if ( !forwarderSuccess ) {
                revert("forward fail");
                //revertWithStatus(RelayCallStatus.RejectedByForwarder, vars.relayedCallReturnValue);
            }
            debug[3] = true;
            if (!relayedCallSuccess) {
                revert("relayedSuccess");
            }
        }
        debug[4] = true;
        //postRelay
    }

    function execute(ForwardRequest calldata relayRequest, bytes calldata signature)
        public returns (bool forwarderSuccess, bool callSuccess, bytes memory ret) {
        debugSelector = IForwarder.execute.selector;

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

    function execute2() external returns(bool callSuccess, bytes memory ret){
        bool forwarderSuccess;
        //bytes ret;
        (forwarderSuccess, ret) = forwarder.call(abi.encodeWithSelector(IForwarder.execute2.selector));
        if ( forwarderSuccess ) {
            //decode return value of execute:
            (callSuccess, ret) = abi.decode(ret, (bool, bytes));
        }
    }

    function execute3(ForwardRequest calldata relayRequest, bytes calldata signature) external returns(bool callSuccess, bytes memory ret){
        bool forwarderSuccess;
        (forwarderSuccess, ret) = forwarder.call(
            abi.encodeWithSelector(IForwarder.execute3.selector,
            relayRequest, signature
            ));
        if ( forwarderSuccess ) {
            //decode return value of execute:
            (callSuccess, ret) = abi.decode(ret, (bool, bytes));
        }
    }
}