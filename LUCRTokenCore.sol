// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LUCRTokenCore {
    string public constant name = "LUCR Token";
    string public constant symbol = "LUCR";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public mintEngine;
    address public burnEngine;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyMintEngine() {
        require(msg.sender == mintEngine, "Not mint engine");
        _;
    }

    modifier onlyBurnEngine() {
        require(msg.sender == burnEngine, "Not burn engine");
        _;
    }

    function setEngines(address _mintEngine, address _burnEngine) external {
        require(_mintEngine != address(0) && _burnEngine != address(0), "Invalid engine");
        mintEngine = _mintEngine;
        burnEngine = _burnEngine;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "Insufficient balance");
        unchecked {
            balanceOf[from] -= value;
            balanceOf[to] += value;
        }
        emit Transfer(from, to, value);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= value, "Not allowed");
        unchecked {
            allowance[from][msg.sender] = allowed - value;
        }
        _transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) external onlyMintEngine {
        require(to != address(0), "Invalid recipient");
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function burn(address from, uint256 value) external onlyBurnEngine {
        require(balanceOf[from] >= value, "Insufficient balance");
        unchecked {
            balanceOf[from] -= value;
            totalSupply -= value;
        }
        emit Transfer(from, address(0), value);
    }
}
