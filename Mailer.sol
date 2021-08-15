// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.6;


contract Mailer {
    struct Mail {
        address from;
        address to;
        string  contents;
    }
    
    bytes32 constant ADMIN_GROUP = keccak256("admin");
    address private _owner;
    mapping (address => string) private groups;
    
    modifier isOwner() {
        require(msg.sender == _owner, "not authorized");
        _;
    }

    constructor () {
        _owner = msg.sender;
        groups[_owner] = "admin";
    }
    
    function addToGroup(address person, string calldata group) isOwner external returns (bool) {
        groups[person] = group;
        return true;
    }
    
    function removeFromGroup(address person) isOwner external returns (bool) {
        delete groups[person];
        return true;
    }
    
    function groupOf(address person) external view returns (string memory) {
        return groups[person];
    }
    
    function validateMail(Mail calldata mail) external view returns (bool isValidated, string memory reason) {
        bytes32 from_group = keccak256(bytes(groups[mail.from]));
        bytes32 to_group = keccak256(bytes(groups[mail.to]));
        
        require(from_group == ADMIN_GROUP || msg.sender == mail.from, "from should be sender or admin");
        require(from_group == ADMIN_GROUP || from_group == to_group, "cross group mail not allowed");
        
        if (bytes(mail.contents).length == 0) {
            isValidated = false;
            reason = "empty mail not allowed";
        }
        
        isValidated = true;
        reason = "Accepted";
    }
}
