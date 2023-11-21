// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingPool {
    address public owner;
    IERC20 public stakingToken;
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public lastStakeTime;

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address _stakingToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
    }
function stake(uint256 _amount) external {
        require(_amount > 0, "Stake amount must be greater than 0");
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        stakedBalances[msg.sender] += _amount;
        totalStaked += _amount;
        lastStakeTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(_amount > 0, "Unstake amount must be greater than 0");
        require(stakedBalances[msg.sender] >= _amount, "Insufficient staked balance");
        
        // Calculate the rewards based on the staking duration (example: simple linear rewards)
        uint256 rewards = calculateRewards(msg.sender, _amount);

        stakedBalances[msg.sender] -= _amount;
        totalStaked -= _amount;
        lastStakeTime[msg.sender] = block.timestamp;

        // Transfer staked amount and rewards back to the staker
        require(stakingToken.transfer(msg.sender, _amount + rewards), "Token transfer failed");

        emit Unstaked(msg.sender, _amount);
    }
function calculateRewards(address _staker, uint256 _amount) internal view returns (uint256) {
        // Example: Simple linear rewards based on the staking duration
        uint256 duration = block.timestamp - lastStakeTime[_staker];
        return (_amount * duration) / 1 days;
    }

    function getStakingDetails(address _staker) external view returns (uint256, uint256, uint256) {
        return (stakedBalances[_staker], totalStaked, lastStakeTime[_staker]);
    }
}
