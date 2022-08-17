// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./Forwarder.sol";

    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }

interface IForwarder {
    function execute(
        ForwardRequest calldata forwardRequest,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata signature
    )
    external payable
    returns (bool success, bytes memory ret);
}
