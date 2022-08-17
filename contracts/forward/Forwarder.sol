// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./IForwarder.sol";

contract Forwarder is IForwarder {
    bool[10] public debug;
    bool public debugExecute2;
    bool public debugExecute3;
    bytes public debugData;
    bytes public debugCallData;
    bytes public debugFrom;
    bytes public debugTo;
    using ECDSA for bytes32;

    mapping(bytes32 => bool) public typeHashes;
    mapping(address => uint256) public nonces;


    //struct ForwardRequest {
    //    address from;
    //    address to;
    //    uint256 value;
    //    uint256 gas;
    //    uint256 nonce;
    //    bytes data;
    //    uint256 validUntil;
    //}


    function execute(
        ForwardRequest calldata req,
        bytes32 requestTypeHash,
        bytes calldata suffixData,
        bytes calldata sig
    )
    external override payable
    returns (bool success, bytes memory ret) {
        //_verifySig(req, requestTypeHash, suffixData, sig);
        debug[0]=true;
        _verifyAndUpdateNonce(req);

        require(req.validUntil == 0 || req.validUntil > block.number, "FWD: request expired");
        debug[1]=true;

        uint gasForTransfer = 0;
        if ( req.value != 0 ) {
            gasForTransfer = 40000; //buffer in case we need to move eth after the transaction.
        }
        debug[2]=true;

        bytes memory callData = abi.encodePacked(req.data, req.from);
        debug[3]=true;
        debugData = req.data;
        debugCallData = callData;
        //require(gasleft()*63/64 >= req.gas + gasForTransfer, "FWD: insufficient gas");
        (success,ret) = req.to.call{gas : req.gas, value : req.value}(callData);
        if ( req.value != 0 && address(this).balance>0 ) {
            // can't fail: req.from signed (off-chain) the request, so it must be an EOA...
            debug[5]=true;
            //payable(req.from).transfer(address(this).balance);
        }
        debug[7]=true;
        debug[8]=success;

        return (success,ret);
    }

    function execute2() external override payable returns(bool success, bytes memory ret) {
        success = true;
        ret = "0x12";
        debugExecute2 = true;
    }

    function execute4(bytes calldata req, address to)
        external payable returns (bool success, bytes memory ret) {

        (success,ret) = to.call(req);
        debugExecute3 = success;
    }

    function execute3(
        ForwardRequest calldata req,
        bytes calldata signature
    ) external override payable returns (bool success, bytes memory ret) {
        bytes memory callData = abi.encodePacked(req.data, req.from);
        (success,ret) = req.to.call{gas : req.gas, value : req.value}(callData);
        debugExecute3 = success;
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