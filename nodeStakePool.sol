// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract Ownable {
    address internal _owner = 0x63eC3629B7c86FDF0e8c3B9d276a60F7DDf0050F;// TODO 0x63eC3629B7c86FDF0e8c3B9d276a60F7DDf0050F
    address public impContrat;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
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
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface relationship{
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}

contract nodeStakePoolV2 is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 hasReward;
        uint256 rewardDebt;
    }

    struct Node{
        string name;
        string introduction;
        bool enabled;//
        address nodeOwner;
        uint256 depositAmount;
        uint256 lastWeekDeposit;//
        uint256 currentWeekDeposit;//
    }

    IERC20 public LPToken; //  = IERC20(0x5cF01B9519AF45D4e6eb17b668F11ca182290E10)
    IERC20 public SGR; // = IERC20(0x56231D55391bd6382bc2a0761a644ea188B007cc);
    relationship public RP; // = relationship(0x58C006016C6557CD29CAA681f9D14b2b840323fc)
    address public dev; //unused


    uint256 public nodeMinDepositLP; // = 50000 * (10**18) 
    uint256 public burnSGR; // = 5000 * (10**18) 
    uint256 public lastUpdateWeekTime; //
    uint256 public fatherFee; //  = 1000
    uint256 public grandFatherFee; // = 500


    uint256 public SGRPerBlock; // = 2777777777777777777
    uint256 public supplyDeposit;
    uint256 public lastRewardBlock;
    uint256 public accSGRPerShare;

    Node[] public node;
    
    mapping (uint256 => mapping (address => UserInfo)) public userInfoMap;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 reward);
    event AddNode(string indexed node, uint256 indexed nodeNumber, address indexed nodeOwner);

    constructor() public {}
    

    function addNode(string memory _name, string memory _introduction) public {
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    function pendingSGR(uint256 _pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfoMap[_pid][_user];
        if (user.amount == 0) return 0;
        uint256 teampAccSGRPerShare;
        if (block.timestamp > lastRewardBlock && supplyDeposit != 0) {
            uint256 multiplier = getMultiplier(lastRewardBlock, block.timestamp);
            uint256 SGRReward = multiplier.mul(SGRPerBlock);
            teampAccSGRPerShare = accSGRPerShare.add(SGRReward.mul(1e12).div(supplyDeposit));
        }
        return user.amount.mul(teampAccSGRPerShare).div(1e12).sub(user.rewardDebt);  
    }

    function updatePool() public {
        updateAllPoolAWeek();
        if (block.timestamp <= lastRewardBlock) {
            return;
        }
        if (supplyDeposit == 0) {
            lastRewardBlock = block.timestamp;
            return;
        }

        uint256 multiplier = getMultiplier(lastRewardBlock, block.timestamp);
        uint256 SGRReward = multiplier.mul(SGRPerBlock);
        accSGRPerShare = accSGRPerShare.add(SGRReward.mul(1e12).div(supplyDeposit));
        lastRewardBlock = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount) public virtual {
    }

    function withdraw(uint256 _pid, uint256 _Amount) public virtual {
    }
    
    function nodeLength() public view returns (uint256){
        return node.length;
    }

    function sendNodeReward(uint256 _pid, uint256 _pending) internal {
        Node storage _node = node[_pid];
        uint256 _reward = _pending.mul(nodeFee(_pid)).div(10000);

        if (_reward > 0){
            safeSGRTransfer(_node.nodeOwner, _reward);
        }
    }

    function safeSGRTransfer(address _to, uint256 _amount) internal {
            SGR.transfer(_to, _amount);
    }
    
    //admin function
    function setSGRPerBlock(uint256 _SGRPerBlock) public onlyOwner {
        updatePool();
        SGRPerBlock = _SGRPerBlock;
    }

    function setFee(uint256 _fatherFee, uint256 _granderFatherFee) public onlyOwner() {
        fatherFee = _fatherFee;
        grandFatherFee = _granderFatherFee;
    }
    
    function setNodeFee(uint256 _nodeMinDepositLP, uint256 _burnSGR) public onlyOwner() {
        burnSGR = _burnSGR;
        nodeMinDepositLP = _nodeMinDepositLP;
    }
    
    function setNode(uint256 _pid, string memory _name, string  memory _introduction, bool _YorN) public onlyOwner() {
        Node storage _node = node[_pid];

        _node.enabled = _YorN;
        _node.name = _name;
        _node.introduction = _introduction;
    }

    // for v2
    function init2(uint256 _startTime, uint256 _startPid, uint256 _endPid) public onlyOwner{
        lastUpdateWeekTime = _startTime;


        for (uint256 i = _startPid; i < _endPid; i++){
            Node storage _node = node[i];
            
            _node.lastWeekDeposit = 0;
            _node.currentWeekDeposit = 10 *(10**30);
            
        }

    }

    //update pool
    function updatePoolAWeek(uint256 _pid) internal {

        Node storage _node = node[_pid];
        uint256 _lastWeekDeposit = _node.lastWeekDeposit;
        uint256 _addFee;

        _addFee = (_node.depositAmount >= 300000 * (10**18)) ? 125 : 150;

        if (_node.currentWeekDeposit > 10 *(10**30)){
            if(_node.currentWeekDeposit - 10 *(10**30) >= _lastWeekDeposit * _addFee / 100){
                _node.enabled = true;
            }else{
                _node.enabled = false;
            }
            _node.lastWeekDeposit = _node.currentWeekDeposit - 10 *(10**30);
        } else{
            _node.lastWeekDeposit = 0;
            _node.enabled = false;
        }
        
        _node.currentWeekDeposit = 10 *(10**30);
    }

    function updateAllPoolAWeek() public {
        if(block.timestamp < lastUpdateWeekTime){
            return;
        }
        if (block.timestamp - lastUpdateWeekTime >= (86400 * 7)){
            for (uint256 i = 0; i < node.length; i++){
                updatePoolAWeek(i);
            }

            lastUpdateWeekTime = block.timestamp;
        }
    }

    // return nodefee of now//
    function nodeFee(uint256 _pid) public view returns(uint256){
        Node storage _node = node[_pid];
        UserInfo memory _user = userInfoMap[_pid][_node.nodeOwner];
        if (_user.amount < nodeMinDepositLP){
            return 0;
        }

        if (_node.depositAmount >= 300000 * (10 **18)){
            return _node.enabled ? 5000 : 1000;
        }
        else{
            return _node.enabled ? 5000 : 500;
        }
    }
}

contract superNode is nodeStakePoolV2 {
    mapping(uint256 => bool) public supperNode;
    mapping(uint256 => uint256) public nodeRP;

    function addSuperNode(uint256 _pid) public {
        Node memory _node = node[_pid];

        require(_node.nodeOwner == msg.sender, "Sorry, you dont have authority");
        require(!supperNode[_pid], "node has be supper node!");
        require(_node.depositAmount >= 800000 * (10 **18), "node dont have enough depositAmount!");
        supperNode[_pid] = true;
    }

    function isEnabled(uint256 _pid) public view returns(bool){
        Node memory _node = node[_pid];
        return (supperNode[_pid] && _node.depositAmount >= 800000 * (10 **18));
    }

    function addRP(uint256 _normalNodePid, uint256 _supperNodePid) public {
        Node memory _node = node[_normalNodePid];

        require(_node.nodeOwner == msg.sender, "Sorry, you dont have authority");
        require(nodeRP[_normalNodePid] == 0, "You had supperNode!");
        require(supperNode[_supperNodePid], "node not supper node!");
        require(_normalNodePid != _supperNodePid);

        nodeRP[_normalNodePid] = _supperNodePid;
    }

    function sendSuperNodeReward(uint256 _pid, uint256 _pending) internal {
        if(nodeRP[_pid] != 0 && isEnabled(nodeRP[_pid])){
            Node memory _node = node[nodeRP[_pid]];
            safeSGRTransfer(_node.nodeOwner, _pending.mul(2000).div(10000));
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public override {
        UserInfo storage user = userInfoMap[_pid][msg.sender];
        Node storage _node = node[_pid];
        address _father = RP.getFather(msg.sender);
        address _granderFather = RP.getGrandFather(msg.sender);

        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accSGRPerShare).div(1e12).sub(user.rewardDebt);
            safeSGRTransfer(msg.sender, pending);
            safeSGRTransfer(_father, pending.mul(fatherFee).div(10000));
            safeSGRTransfer(_granderFather, pending.mul(grandFatherFee).div(10000));
            
            sendNodeReward(_pid, pending);
            sendSuperNodeReward(_pid, pending);
            user.hasReward = user.hasReward.add(pending);
        }
        LPToken.transferFrom(address(msg.sender), address(this), _amount);

        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(accSGRPerShare).div(1e12);

        _node.depositAmount = _node.depositAmount.add(_amount);
        _node.currentWeekDeposit =_node.currentWeekDeposit.add(_amount);
        supplyDeposit = supplyDeposit.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _Amount) public override {
        UserInfo storage user = userInfoMap[_pid][msg.sender];
        Node storage _node = node[_pid];
        address _father = RP.getFather(msg.sender);
        address _granderFather = RP.getGrandFather(msg.sender);
        
        require(user.amount >= _Amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(accSGRPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeSGRTransfer(msg.sender, pending);
            safeSGRTransfer(_father, pending.mul(fatherFee).div(10000));
            safeSGRTransfer(_granderFather, pending.mul(grandFatherFee).div(10000));
            
            sendNodeReward(_pid, pending);
            sendSuperNodeReward(_pid, pending);
            user.hasReward = user.hasReward.add(pending);
        }
        if (_Amount > 0) {
            user.amount = user.amount.sub(_Amount);
            LPToken.transfer(address(msg.sender), _Amount);  
        }
        user.rewardDebt = user.amount.mul(accSGRPerShare).div(1e12);

        _node.depositAmount = _node.depositAmount.sub(_Amount);
        //uint256 _weekAmount = _node.currentWeekDeposit > _Amount ? _Amount : _node.currentWeekDeposit;
        _node.currentWeekDeposit =_node.currentWeekDeposit.sub(_Amount);
        supplyDeposit = supplyDeposit.sub(_Amount);
        emit Withdraw(msg.sender, _pid, _Amount, pending);
    }

    function addNode(string memory _name, string memory _introduction, uint256 _superNodePid) public {
        SGR.transferFrom(msg.sender, address(this), burnSGR);
        SGR.burn(burnSGR);
        node.push(Node({ 
            name : _name,
            introduction : _introduction,
            enabled: true,
            nodeOwner : msg.sender,
            depositAmount : 0,
            lastWeekDeposit : 0,
            currentWeekDeposit : 0
        }));
        uint256 _pid = node.length;
        deposit(_pid-1, nodeMinDepositLP);
        addRP(_pid-1, _superNodePid);
        emit AddNode(_name, _pid-1, msg.sender);
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> a8860d500e074f61a5b9d04b5387c0ea67a24a2f
