pragma solidity >=0.4.21 <0.6.0;

contract Crowdfunding {
    string public name = "A Decentralized Crowdfunding Site";
    address public contractAddress = address(this);
    mapping(address => uint) balances;

    struct Funder {
        address payable identity;
        uint amount;
        address fundedProject;
    }

    struct Project {
        address payable creator;
        string name;
        uint goal;
        string desc;
        uint donatedAmount;
    }

    Funder[] public funderArray;
    Project[] public projectArray;

    event ProjectCreated(
        address creator,
        uint amount,
        string name,
        string desc
    );

    event ProjectFunded(
        address backer,
        address pOwner,
        uint amount
    );
      
    // This function is called when the msg.sender provides the necessarry details and proceeds to make a fundraiser.
    function createProject(string memory _name, uint _goal,  string memory _desc) public {
        projectArray.push(Project(msg.sender, _name, _goal, _desc, 0));
        emit ProjectCreated(msg.sender, _goal, _name, _desc);
    }

    // This function is called when the project's owner decides to delete their fundraiser.
    // If people have donated to it, the backers receive their Ether back.
    function deleteProject() public {
        for(uint i=0; i < projectArray.length; i++) {
            if(projectArray[i].creator == msg.sender) {
                if(projectArray[i].donatedAmount > 0) {
                    returnFunds();
                    delete projectArray[i];
                } else {
                    delete projectArray[i];
                }
            }
        }
    }

    // This function is called when a backer donates to the fundraiser. The amount gets
    // transfered to the smart contract until the donation goal is not met. After that, a button shows
    // up for withdrawal.
    function fundProject(address _pOwner) external payable {
        uint ethBalance = msg.sender.balance;
        require(ethBalance >= msg.value);
        
        balances[address(this)] += msg.value; 
        funderArray.push(Funder(msg.sender, msg.value));

        for(uint i=0; i < projectArray.length; i++) {
            if(projectArray[i].creator == _pOwner) {
                projectArray[i].donatedAmount += msg.value;
                break;
            }
        }

        emit ProjectFunded(msg.sender,projectArray[0].creator,msg.value);
    }

    // This function is the handler of returning funds. It's called once a fundraiser is deleted manually by its owner.
    function returnFunds() public payable {
        require(funderArray.length >= 1);
        for(uint i=0; i < funderArray.length; i++) {
            uint transferAmount = funderArray[i].amount;
            address payable backer = funderArray[i].identity;
            if(funderArray[i].fundedProject == msg.sender) {
                backer.transfer(transferAmount);
                delete funderArray[i];
            }
        }
    }

    // This function is called whenever the fundraiser's owner decides to withdraw the raised amount.
    // It automatically deletes the fundraiser.
    function payFunds() public payable {
        for(uint i=0; i < projectArray.length; i++) {
            if(projectArray[i].donatedAmount >= projectArray[i].goal) {
                address payable creator = projectArray[i].creator;
                creator.transfer(projectArray[i].donatedAmount);
                delete projectArray[i];
            }
        }
    }
}
