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
     bytes data;
    }
    
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    receive() payable external {
        
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0);
        require(_required > 0);
        require(_required <= _owners.length);
        owners = _owners;
        required = _required;
    }

    function addTransaction(address _destination, uint256 _value, bytes memory _data) internal returns (uint256 transactionId) {
        transactionId = transactionCount;
        transactions[transactionCount] = Transaction(_destination, _value, false, _data);
        transactionCount += 1;
        return transactionCount - 1;
    }

    function confirmTransaction(uint256 _transactionId) public {
        require(Owner(msg.sender), "error");
        confirmations[_transactionId][msg.sender] = true;
        if(isConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    function getConfirmationsCount(uint _transactionId) public view returns(uint) {
        uint count;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[_transactionId][owners[i]]) {
                count++;
            }
        }
        return count;
    }

    function Owner(address _wallet) private view returns(bool) {
        for(uint i = 0; i < owners.length; i++) {
            if(owners[i] == _wallet) {
                return true;
            }
        }
        return false;
    }

    function submitTransaction(address _destination, uint _value, bytes memory _data) external {
        uint transId = addTransaction(_destination, _value, _data);
        confirmTransaction(transId);
    }

    function isConfirmed(uint256 _transactionId) public view returns(bool) {
        return getConfirmationsCount(_transactionId) >= required;
    }

    function executeTransaction(uint256 _transactionId) public {
        require(isConfirmed(_transactionId));
        Transaction storage _tx = transactions[_transactionId];
        (bool success, ) = _tx.destination.call{ value: _tx.value }(_tx.data);
        require(success);
        _tx.executed = true;
    }
}