// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Receiver {
    mapping(address=>uint256) public debugMap;

    event Received(address caller, uint amount, string message);

    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint _x) public payable returns(uint) {
        debugMap[msg.sender] += 1;
        emit Received(msg.sender, msg.value, _message);
        return _x + 1;
    }
}

contract Receiver2 {
    event Received(address caller, uint amount, string message);

    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint _x) public payable returns(uint) {
        emit Received(msg.sender, msg.value, _message);
        return _x + 1;
    }
}

contract Caller {
    bytes public debugData;
    event Response(bool success, bytes data);

    function testCallFoo(address payable _addr) public payable {
        debugData = abi.encodeWithSignature("foo(string,uint256)", "call foo", 123);
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas:5000}(debugData);
        emit Response(success, data);
    }

    function testCallFoo2(address payable _addr, bytes calldata data) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas:5000}(data);
        emit Response(success, data);
    }

    function testCallFoo3(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas:10000}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
        );
        emit Response(success, data);
    }

    function testCallFoo4(address payable _addr, uint256 gasLimit) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas:gasLimit}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
        );
        emit Response(success, data);
    }
}
