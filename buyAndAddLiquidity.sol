pragma solidity ^0.6.12;
// SPDX-License-Identifier: MIT

interface LiquidityManager{
    function addLiquidity(uint256 _amountADesired, uint256 _amountBDesired) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view  returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IdexRouter02{
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] memory path)
        external view
        returns (uint[] memory amounts);
}
interface relationship {
    function father(address _son) external view returns(address);
    function otherCallSetRelationship(address _son, address _father) external;
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}
contract buyAndAddLiquidity is Ownable{

    IERC20 USDT;
    IERC20 SGRv2;
    IERC20 LPToken;
    relationship RP;
    IdexRouter02 router02;
    LiquidityManager liquidityManagerContract;

    event BuyAndAddLiquidityAssert(address user, uint256 LPTokenAmount, uint256 returnUSDT, uint256 returnSGRv2);

    function init(address _USDT, address _SGRv2, address _LPToken, address _RP, address _router02, address _liquidityManager) public onlyOwner() {
        USDT = IERC20(_USDT);
        SGRv2 = IERC20(_SGRv2);
        LPToken = IERC20(_LPToken);
        RP = relationship(_RP);
        router02 = IdexRouter02(_router02);
        liquidityManagerContract = LiquidityManager(_liquidityManager);
    }


    function buyAndAddLiquidityAssert(uint256 amountOfUSDT, address _father) public {
        //把USDT转到本合约进行操作，USDT不会有手续费问题，不需要加白名单
        USDT.transferFrom(msg.sender, address(this), amountOfUSDT);

        //将资金分成两部分
        uint256 balanceOfUSDT = USDT.balanceOf(address(this));
        uint256 halfOfUSDT = balanceOfUSDT / 2;
        uint256 anotherOfUSDT = balanceOfUSDT - halfOfUSDT;

        //将其中一般授权给购买合约，进行购买
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SGRv2);
        if (RP.father(msg.sender) == address(0)){
            RP.otherCallSetRelationship(msg.sender, _father);
        }
        IERC20(USDT).approve(address(router02), anotherOfUSDT);
        uint256 beforeSGRv2 = SGRv2.balanceOf(msg.sender);
        router02.swapExactTokensForTokens(anotherOfUSDT, 0, path, msg.sender, block.timestamp); //发送给调用者 这样才能正常进行奖励分配
        uint256 balanceOfSGRv2 = SGRv2.balanceOf(msg.sender) - beforeSGRv2;
        SGRv2.transferFrom(msg.sender, address(this), balanceOfSGRv2);

        //授权并添加流动性
        SGRv2.approve(address(liquidityManagerContract), balanceOfSGRv2);
        USDT.approve(address(liquidityManagerContract), balanceOfUSDT);
        liquidityManagerContract.addLiquidity(halfOfUSDT, balanceOfSGRv2);
        

        //这里必然是USDT会多出来，因为购买SGR时要扣除手续费，虽然SGR的价格升高了但是不太可能升高11%，所以直接将USDT返还给用户，以防万一，SGR也会返还给用户，但是会扣除手续费
        uint256 balanceOfLP = LPToken.balanceOf(address(this));
        balanceOfUSDT = USDT.balanceOf(address(this));
        balanceOfSGRv2 = SGRv2.balanceOf(address(this));//复用变量
        if(balanceOfLP > 0){
            LPToken.transfer(msg.sender, balanceOfLP);
        }
        if(balanceOfUSDT > 0){
            USDT.transfer(msg.sender, balanceOfUSDT);
        }
        if(balanceOfSGRv2 > 0){
            SGRv2.transfer(msg.sender, balanceOfSGRv2);
        }
        

        emit BuyAndAddLiquidityAssert(msg.sender, balanceOfLP, balanceOfUSDT, balanceOfSGRv2);
    }

    function buyAndAddLiquidityAssert(uint256 amountOfUSDT) public {
        //把USDT转到本合约进行操作，USDT不会有手续费问题，不需要加白名单
        USDT.transferFrom(msg.sender, address(this), amountOfUSDT);

        //将资金分成两部分
        uint256 balanceOfUSDT = USDT.balanceOf(address(this));
        uint256 halfOfUSDT = balanceOfUSDT / 2;
        uint256 anotherOfUSDT = balanceOfUSDT - halfOfUSDT;

        //将其中一般授权给购买合约，进行购买
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(SGRv2);
        IERC20(USDT).approve(address(router02), anotherOfUSDT);
        uint256 beforeSGRv2 = SGRv2.balanceOf(msg.sender);
        router02.swapExactTokensForTokens(anotherOfUSDT, 0, path, msg.sender, block.timestamp); //发送给调用者 这样才能正常进行奖励分配
        uint256 balanceOfSGRv2 = SGRv2.balanceOf(msg.sender) - beforeSGRv2;
        SGRv2.transferFrom(msg.sender, address(this), balanceOfSGRv2);


        //授权并添加流动性
        SGRv2.approve(address(liquidityManagerContract), balanceOfSGRv2);
        USDT.approve(address(liquidityManagerContract), balanceOfUSDT);
        liquidityManagerContract.addLiquidity(halfOfUSDT, balanceOfSGRv2);
        

        //这里必然是USDT会多出来，因为购买SGR时要扣除手续费，虽然SGR的价格升高了但是不太可能升高11%，所以直接将USDT返还给用户，以防万一，SGR也会返还给用户，但是会扣除手续费
        uint256 balanceOfLP = LPToken.balanceOf(address(this));
        balanceOfUSDT = USDT.balanceOf(address(this));
        balanceOfSGRv2 = SGRv2.balanceOf(address(this));//复用变量
        if(balanceOfLP > 0){
            LPToken.transfer(msg.sender, balanceOfLP);
        }
        if(balanceOfUSDT > 0){
            USDT.transfer(msg.sender, balanceOfUSDT);
        }
        if(balanceOfSGRv2 > 0){
            SGRv2.transfer(msg.sender, balanceOfSGRv2);
        }
        

        emit BuyAndAddLiquidityAssert(msg.sender, balanceOfLP, balanceOfUSDT, balanceOfSGRv2);
    }


}