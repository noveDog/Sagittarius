// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // add for SGR
    function burn(uint256 _amount) external;
}

contract Proxy {

    address owner = 0x63eC3629B7c86FDF0e8c3B9d276a60F7DDf0050F;
    address public impContrat;
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address){
        return impContrat;
    }

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    //admin function
    function setImpContract(address _newImpContract) public {
        require(msg.sender == owner);
        impContrat = _newImpContract;
    }
}

contract DAOMain is Proxy{

    struct proposal{
        uint256 ID;
        address OWNER;
        string TITLE;
        uint256 YES;
        uint256 NO;
        uint256 STARTTIME;
        uint256 ENDTIME;
    }

    proposal[] public proposalList;
    mapping(uint256 => mapping(address => uint256)) public userVotes;

    IERC20 public voteToken;
    uint256 public minAddToken;
    uint256 public deadline;

    event AddProposal(address OWNER, uint256 ID, uint256 ENDTIME);
    event Vote(address OWNER, bool YoN, uint256 VOTES);


    function init(address _voteToken, uint256 _minAddToken, uint256 _deadline) public {
        require(voteToken == IERC20(address(0)), "has init");

        voteToken = IERC20(_voteToken);
        minAddToken = _minAddToken;
        deadline = _deadline;
    }


    //add
    function addProposal(string memory _title) public {
        require(voteToken.balanceOf(msg.sender) >= minAddToken, "Sorry, you don't have enough SGRv2!");
        voteToken.transferFrom(msg.sender, address(this), minAddToken);
        uint256 _proposalID = proposalList.length;

        proposalList.push(proposal({
            ID: _proposalID,
            OWNER: msg.sender,
            TITLE: _title,
            YES: 0,
            NO: 0,
            STARTTIME: block.timestamp,
            ENDTIME: block.timestamp + deadline
        }));

        emit AddProposal(msg.sender, _proposalID, block.timestamp + deadline);
    }

    //votes
    function vote(uint256 _proposalID, bool _YoN, uint256 _votes) public {
        require(voteToken.balanceOf(msg.sender) - userVotes[_proposalID][msg.sender] >= _votes,"Sorry, you don't have enough SGRv2 for votes!");
        
        proposal storage _proposal =  proposalList[_proposalID];

        if (_YoN){
            _proposal.YES = _proposal.YES + _votes;
        } else{
            _proposal.NO = _proposal.NO + _votes;
        }
        userVotes[_proposalID][msg.sender] = userVotes[_proposalID][msg.sender] + _votes;

        emit Vote(msg.sender, _YoN, _votes);
    }


    function voteResult(uint256 _proposalID) public view returns (bool) {
        proposal memory _proposal =  proposalList[_proposalID];
        require(_proposal.ENDTIME < block.timestamp, "proposal not end!");

        return _proposal.YES > _proposal.NO;
    }

    //admin
    function setMinAddToken(uint256 _MinAddToken) public {
        require(msg.sender == owner);
        minAddToken = _MinAddToken;
    }
    
    function setDeadline(uint256 _deadline) public {
        require(msg.sender == owner);
        deadline = _deadline;
    }
    
    function proposalLength() public view returns (uint256){
        return proposalList.length;
    }
}