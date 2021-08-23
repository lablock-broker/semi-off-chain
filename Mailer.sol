// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.7;

// owner can add any person to one group
// person of a group can only send mail to members of his/her group
// person of admin group can send mail to any person
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
    
    // for off-chain DApp messaging first return value should be string and the name of event
    // other return values are optional and may be use in DApp for message passing data
    function validateMail(Mail calldata mail) external view returns (string memory offcahin_event, 
                                                                     string memory from_group,
                                                                     string memory to_group) {
        from_group = groups[mail.from.wallet];
        to_group = groups[mail.to.wallet];
        
        bytes32 sender_group_b = keccak256(bytes(groups[msg.sender]));
        bytes32 from_group_b = keccak256(bytes(from_group));
        bytes32 to_group_b = keccak256(bytes(to_group));
        
        require(sender_group_b == ADMIN_GROUP || msg.sender == mail.from.wallet, "from should be sender or admin");
        require(sender_group_b == ADMIN_GROUP || from_group_b == to_group_b, "cross group mail not allowed");
        require(bytes(mail.contents).length > 0, "empty mail not allowed");
        
        offcahin_event = "MailSent";
    }
}
