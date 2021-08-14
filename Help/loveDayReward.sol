// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}



contract loveDay{
    IERC20 SGR = IERC20(0x56231D55391bd6382bc2a0761a644ea188B007cc);
    address admin = 0x63eC3629B7c86FDF0e8c3B9d276a60F7DDf0050F;

    address buyContract;
    uint256 gifRate;
    uint256 startTime;


    struct userInfo{
        uint256 userbuy;
        uint256 hasGetReward;
    }
    mapping(address => userInfo) public users;
    address[] public userlist;


    function addUserbuy(address _addr, uint256 _value) public {
        if(block.timestamp > startTime){
            require(msg.sender == buyContract,"cant call this func");
            userInfo storage _user = users[_addr];

            if(_user.userbuy == 0){
                userlist.push(_addr);
            }

            _user.userbuy = _user.userbuy + _value;
        }
    }


    function getGif() public {
        userInfo storage _user = users[msg.sender];

        uint256 canGetReward = (_user.userbuy * gifRate / 10000) - _user.hasGetReward;//精度10000

        require(canGetReward > 0,"you have no reward");

        SGR.transfer(msg.sender, canGetReward);

        _user.hasGetReward = _user.hasGetReward + canGetReward;
    }


    //admin func
    function endOut(uint256 _value) public {
        require(msg.sender == admin);
        SGR.transfer(admin, _value);
    }

    function init(address _buyContract, uint256 _gifRate, uint256 _startTime) public{
        require(msg.sender == admin);
        buyContract = _buyContract;
        gifRate = _gifRate;
        startTime = _startTime;
    }


}