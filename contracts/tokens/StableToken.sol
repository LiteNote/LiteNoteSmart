pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "./ERC223/ERC223.sol";

contract StableToken is MintableToken, BurnableToken, ERC223 {

    string public name = "Stable token";
    string public symbol = "STT";
    uint public decimals = 18;

    function StableToken() public {
        owner = msg.sender;
    }
}
