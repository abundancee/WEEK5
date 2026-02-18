// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.20;

contract Aberc {
    address public immutable owner;
    uint256 public totalSupply;
    string public name;
    string public symbol;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    modifier onlyOwner() {
        require(msg.sender == owner, "YOU ARE NOT THE OWNER");
        _;
    }
    constructor(string memory _name, uint256 _initialSupply, uint8 decimals, string memory _symbol) {
        owner = msg.sender;
        uint256 actualDecimals = decimals > 0 ? decimals : 18;
        totalSupply = _initialSupply * 10**actualDecimals;
        name = _name;
        symbol = _symbol;
        balanceOf[address(this)] = totalSupply;
    }

    
    function transfer(address _to, uint256 _amount) external {
        require(_to != address(0), "INVALID ADDRESS");
        require(balanceOf[msg.sender] >= _amount, "YOUR BALANCE IS NOT ENOUGH");

        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
    }

    function approve(address _spender, uint256 _amount) external {
        require(_spender != address(0), "INVALID ADDRESS");

        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) external {
        require(_to != address(0), "INVALID ADDRESS");
        require(balanceOf[_from] >= _amount, "YOUR BALANCE IS NOT ENOUGH");
        require(allowance[_from][msg.sender] >= _amount, "INSUFFICIENT ALLOWANCE");

        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);
    }
    function mint(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "UNAUTHORISED ADDRESS");
        require(balanceOf[address(this)] >= _amount, "INSUFFICIENT CONTRACT BALANCE");

        balanceOf[_to] += _amount;
        balanceOf[address(this)] -= _amount;

        emit Transfer(address(this), _to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner {
        require(_from != address(0), "UNAUTHORISED ADDRESS");
        require(balanceOf[_from] >= _amount, "INSUFFICIENT BALANCE");
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;

        emit Transfer(_from, address(0), _amount);
    }
}