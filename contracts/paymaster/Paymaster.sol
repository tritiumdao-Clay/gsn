// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Paymaster {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function burn(uint256 amount) public payable {
        require(balances[msg.sender] >= amount, "paymaster, not enough balance");
        balances[msg.sender] -=amount;
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}