// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./ERC2771Recipient.sol";

contract GameItems is ERC1155, ERC2771Recipient {
    uint256 public constant GOLD = 0;
    uint256 public constant THORS_HAMMER = 1;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, THORS_HAMMER, 1, "");
    }

    function mint(uint256 tokenId, uint256 amount) external {
        _mint(msg.sender, tokenId, amount, "");
    }

    function setTrustedForwarder(address _forwarder) external {
        _setTrustedForwarder(_forwarder);
    }

    function msgSender() external view returns(address) {
        return _msgSender();
    }

    function _msgSender() internal override(Context, ERC2771Recipient) view returns (address ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            ret = msg.sender;
        }
    }

    function _msgData() internal override(Context, ERC2771Recipient) view returns (bytes calldata ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length-20];
        } else {
            return msg.data;
        }
    }

}