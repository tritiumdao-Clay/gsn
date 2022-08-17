// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC2771Recipient.sol";

contract MetaCoin is ERC2771Recipient {

   string public symbol = "META";
   string public description = "MetaCoin";
   uint public decimals = 18;


   mapping(address => uint256) public balances;

   event Transfer(address indexed _from, address indexed _to, uint256 _value);

   constructor(address _forwarder) {
       balances[tx.origin] = 10000;
       _setTrustedForwarder(_forwarder);
   }

   function transfer(address receiver, uint256 amount) public returns (bool sufficient) {
       if (balances[_msgSender()] < amount) {
           return false;
       }
       balances[_msgSender()] -= amount;
       balances[receiver] += amount;
       emit Transfer(_msgSender(), receiver, amount);
       return true;
   }

    function setTrustedForwarder(address _forwarder) external {
        _setTrustedForwarder(_forwarder);
    }

    function msgSender() external view returns(address) {
        return _msgSender();
    }
}
