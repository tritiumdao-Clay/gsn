// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./IForwarder.sol";

contract Forwarder is IForwarder {
    using ECDSA for bytes32;

    mapping(bytes32 => bool) public typeHashes;
    mapping(address => uint256) public nonces;

    function execute(
        ForwardRequest calldata req,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig
    )
    external override payable
    returns (bool success, bytes memory ret) {
        //_verifySig(req, requestTypeHash, suffixData, sig);
        _verifyAndUpdateNonce(req);

        require(req.validUntil == 0 || req.validUntil > block.number, "FWD: request expired");

        uint gasForTransfer = 0;
        if ( req.value != 0 ) {
            gasForTransfer = 40000; //buffer in case we need to move eth after the transaction.
        }

        bytes memory callData = abi.encodePacked(req.data, req.from);
        //require(gasleft()*63/64 >= req.gas + gasForTransfer, "FWD: insufficient gas");
        (success,ret) = req.to.call{gas : req.gas, value : req.value}(callData);
        if ( req.value != 0 && address(this).balance>0 ) {
            // can't fail: req.from signed (off-chain) the request, so it must be an EOA...
            //payable(req.from).transfer(address(this).balance);
        }

        return (success,ret);
    }

    function _verifySig(ForwardRequest calldata req, bytes32 requestTypeHash,
        bytes calldata suffixData, bytes calldata sig) internal view {
        require(typeHashes[requestTypeHash], "FWD: unregistered typehash");
        bytes32 digest = keccak256(_getEncoded(req, requestTypeHash, suffixData));
        require(digest.recover(sig) == req.from, "FWD: signature mismatch");
    }

    function verifySig(ForwardRequest calldata req, bytes32 requestTypeHash,
        bytes calldata suffixData, bytes calldata sig) external view returns(bool) {

        require(typeHashes[requestTypeHash], "FWD: unregistered typehash");
        bytes32 digest = keccak256(_getEncoded(req, requestTypeHash, suffixData));
        require(digest.recover(sig) == req.from, "FWD: signature mismatch");
        return true;
    }

    function _getEncoded(
        ForwardRequest calldata req,
        bytes32 requestTypeHash,
        bytes calldata suffixData
    )
    public
    pure
    returns (
        bytes memory
    ) {
        // we use encodePacked since we append suffixData as-is, not as dynamic param.
        // still, we must make sure all first params are encoded as abi.encode()
        // would encode them - as 256-bit-wide params.
        return abi.encodePacked(
            requestTypeHash,
            uint256(uint160(req.from)),
            uint256(uint160(req.to)),
            req.value,
            req.gas,
            req.nonce,
            keccak256(req.data),
            req.validUntil,
            suffixData
        );
    }


    function _verifyAndUpdateNonce(ForwardRequest calldata req) internal {
        require(nonces[req.from]++ == req.nonce, "FWD: nonce mismatch");
    }
}