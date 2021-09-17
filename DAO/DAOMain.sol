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

contract DAOMain{

    struct proposal{
        uint256 ID;
        address owner;
        string TITLE;
        uint256 YES;
        uint256 NO;
        uint256 stratTime;
        uint256 endTime;
    }

    proposal[] public proposalList;
    mapping(uint256 => mapping(address => uint256)) public userVotes;

    IERC20 public voteToken;
    uint256 public minAddToken;
    address public owner;

    event AddProposal(address OWNER, uint256 ID, uint256 ENDTIME);
    event Vote(address OWNER, bool YoN, uint256 VOTES);


    function init(address _voteToken, uint256 _minAddToken, address _owner) public {
        require(voteToken == IERC20(address(0)), "has init");

        voteToken = IERC20(_voteToken);
        minAddToken = _minAddToken;
        owner = _owner;
    }


    //发起提案
    function addProposal(string memory _title) public {
        require(voteToken.balanceOf(msg.sender) >= minAddToken, "Sorry, you don't have enough SGRv2!");//检查用户是否有权限发起投票，即持币数量达到一定量
        //require(!proposalPending(), "proposal pending");//检查当前是否有正在进行中的提案，如果有，暂时不能发起提案

        uint256 _proposalID = proposalList.length;

        proposalList.push(proposal{
            ID: _proposalID,
            owner: msg.sender,
            TITLE: _title,
            YES: 0,
            NO: 0
            startTime: now
            endTime: now + 86400 * 7
        })

        emit AddProposal(msg.sender, _proposalID, now + 86400 * 7);
    }

    //投票
    function vote(uint256 _proposalID, bool YoN, uint256 _votes) public {
        require(voteToken.balanceOf(msg.sender) >= userVotes[_proposalID][msg.sender],"Sorry, you don't have enough SGRv2 for votes!");
        
        proposal storage _proposal =  proposalList[_proposalID];

        if (YoN){
            _proposal.YES = _proposal.YES + _votes;
        } else{
            _proposal.NO = _proposal.NO + _votes;
        }
        userVotes[_proposalID][msg.sender] = userVotes[_proposalID][msg.sender] + _votes;//更新用户已投票的记录

        emit Vote(msg.sender, YoN, _votes);
    }


    // function proposalPending() public view returns (bool){
    //     uint256 _proposalID = proposalList.length;
    //     proposal memory _proposal =  proposalList[_proposalID];

    //     return _proposal.endTime < now;
    // }


    function voteResult(uint256 _proposalID) public view returns (bool) {
        proposal memory _proposal =  proposalList[_proposalID];

        return _proposal.YES > _proosal.NO;
    }

    //admin
    function setMinAddToken(uint256 _MinAddToken) public {
        require(msg.sender == owner);
        minAddToken = _MinAddToken
    }
}