// SPDX-License-Identifier: ISC
pragma solidity >=0.7.0 <0.9.0;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign (uint minimum) public {
        address newCampaign = address (new Campaign(minimum, msg.sender));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns () public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    uint public approversCount;
    mapping(address => bool) public approvers;
    mapping(address => bool) public approvals; 

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor (uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable{
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string memory description, uint value, address payable recipient) public  restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        //approvals[msg.sender] = true;

        requests.push(newRequest);

    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];

        // Make sure person calling this function has donated
        require(approvers[msg.sender]);
        // Make sure person calling this function hasn't voted before
        require(!approvals[msg.sender]);

        approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest (uint index) public restricted {
        Request storage request = requests[index];

        require(request.approvalCount > (approversCount/2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }

}