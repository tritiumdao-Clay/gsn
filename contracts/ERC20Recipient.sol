// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC2771Recipient.sol";

contract MetaCoin is ERC2771Recipient {

    address public debugAddress;
    uint256 public debugAmount;
    address public debugSender;
    address public debugSender2;

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
       debugAddress = receiver;
       debugAmount = amount;
       debugSender = msg.sender;
       debugSender2 = _msgSender();

       if (balances[_msgSender()] < amount) {
           return false;
       }
       balances[_msgSender()] -= amount;
       balances[receiver] += amount;
       emit Transfer(_msgSender(), receiver, amount);
       return true;
   }
    function clearDebug() public {
delete debugAddress;
delete debugAmount;
delete debugSender;
delete debugSender2;
}
    function mint() public {
        balances[_msgSender()] += 10000;
    }

// function getBalanceInEth(address addr) public view returns (uint){
   //     return ConvertLib.convert(balanceOf(addr), 2);
   // }

   // function balanceOf(address addr) public view returns (uint) {
   //     return balances[addr];
   // }

    function setTrustedForwarder(address _forwarder) external {
        _setTrustedForwarder(_forwarder);
    }

    function msgSender() external view returns(address) {
        return _msgSender();
    }

    //function _msgSender() internal override(ERC2771Recipient) view returns (address ret) {
    //    if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
    //        // At this point we know that the sender is a trusted forwarder,
    //        // so we trust that the last bytes of msg.data are the verified sender address.
    //        // extract sender address from the end of msg.data
    //        assembly {
    //            ret := shr(96,calldataload(sub(calldatasize(),20)))
    //        }
    //    } else {
    //        ret = msg.sender;
    //    }
    //}

    //function _msgData() internal override(ERC2771Recipient) view returns (bytes calldata ret) {
    //    if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
    //        return msg.data[0:msg.data.length-20];
    //    } else {
    //        return msg.data;
    //    }
    //}
    event Registered(address indexed who, string name);

    mapping(address => string) public names;
    mapping(string => address) public owners;
    function register(string memory name) external {
        //require(owners[name] == address(0), "Name taken");
        address owner = _msgSender(); // Changed from msg.sender
        owners[name] = owner;
        names[owner] = name;
        emit Registered(owner, name);
    }

    function abi2(bytes memory data, address from) external view returns(bytes memory ret) {
        ret = abi.encodePacked(data, from);
    }
    function abi3(bytes memory data, address from) external view returns(bytes memory ret) {
        ret = abi.encodeWithSelector(this.register.selector, "2");
    }
}
