// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

contract Registry is ERC2771Context {
    event Registered(address indexed who, string name);

    mapping(address => string) public names;
    mapping(string => address) public owners;

    address public latestAddress;
    string public name;

    constructor(MinimalForwarder forwarder) // Initialize trusted forwarder
    ERC2771Context(address(forwarder)) {
    }

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