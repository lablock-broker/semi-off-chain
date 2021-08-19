// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.6;


contract Mailer {
    struct Person {
        string name;
        address wallet;
    }
    
    struct Mail {
        Person from;
        Person to;
        string contents;
    }
    
    bytes32 private constant ADMIN_GROUP = keccak256("admin");
    address private _owner;
    mapping (address => string) private groups;
    
    event PersonAdded(address indexed person, string group);
    event PersonRemoved(address indexed person);
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "not authorized");
        _;
    }

    constructor () {
        _owner = msg.sender;
        groups[_owner] = "admin";
    }
    
    function addToGroup(address person, string calldata group) onlyOwner external returns (bool) {
        groups[person] = group;
        emit PersonAdded(person, group);
        return true;
    }
    
    function removeFromGroup(address person) onlyOwner external returns (bool) {
        delete groups[person];
        emit PersonRemoved(person);
        return true;
    }
    
    function groupOf(address person) external view returns (string memory) {
        return groups[person];
    }
    
    function validateMail(Mail calldata mail) external view returns (bool isValidated, string memory reason) {
        bytes32 sender_group = keccak256(bytes(groups[msg.sender]));
        bytes32 from_group = keccak256(bytes(groups[mail.from.wallet]));
        bytes32 to_group = keccak256(bytes(groups[mail.to.wallet]));
        
        require(sender_group == ADMIN_GROUP || msg.sender == mail.from.wallet, "from should be sender or admin");
        require(sender_group == ADMIN_GROUP || from_group == to_group, "cross group mail not allowed");
        
        if (bytes(mail.contents).length == 0) {
            isValidated = false;
            reason = "empty mail not allowed";
        }
        
        isValidated = true;
        reason = "Accepted";
    }
}
