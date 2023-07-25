// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
     address destination;
     uint256 value;
     bool executed;   
    }
    
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0);
        require(_required > 0);
        require(_required <= _owners.length);
        owners = _owners;
        required = _required;
    }

    function addTransaction(address _destination, uint256 _value) public returns (uint256 transactionId) {
        transactionId = transactionCount;
        transactions[transactionCount] = Transaction(_destination, _value, false);
        transactionCount += 1;
    }

    function confirmTransaction(uint256 transactionId) public {
        confirmations[transactionId][msg.sender] = true;
    }

    function getConfirmationsCount(uint transactionId) public view returns(uint) {
        uint count;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[transactionId][owners[i]]) {
                count++;
            }
        }
        return count;
    }
}