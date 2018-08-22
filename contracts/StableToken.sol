pragma solidity ^0.4.24;

// File: contracts/tokens/ERC223/ERC223_receiving_contract.sol

/**
* @title Contract that will work with ERC223 tokens.
*/

contract ERC223ReceivingContract {
    /**
     * @dev Standard ERC223 function that will handle incoming token transfers.
     *
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return _a / _b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender)
    public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

// File: contracts/tokens/ERC223/ERC223.sol

/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract ERC223 is StandardToken {

    event Transfer(address indexed from, address indexed to, uint value, bytes data);

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public returns (bool) {
        bytes memory empty;
        return transfer(_to, _value, empty);
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @param _data Optional metadata.
    */
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        super.transfer(_to, _value);

        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            emit Transfer(msg.sender, _to, _value, _data);
        }

        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        bytes memory empty;
        return transferFrom(_from, _to, _value, empty);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     * @param _data Optional metadata.
     */
    function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool) {
        super.transferFrom(_from, _to, _value);

        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(_from, _value, _data);
        }

        emit Transfer(_from, _to, _value, _data);
        return true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }
}

// File: zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) internal {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal returns (bool) {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
        return true;
    }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// File: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    //event MintFinished();

    //bool public mintingFinished = false;


    //  modifier canMint() {
    //    require(!mintingFinished);
    //    _;
    //  }
    //
    //  modifier hasMintPermission() {
    //    require(msg.sender == owner);
    //    _;
    //  }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(
        address _to,
        uint256 _amount
    )
    internal
        //    hasMintPermission
        //    canMint
    returns (bool)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    //  function finishMinting() public onlyOwner canMint returns (bool) {
    //    mintingFinished = true;
    //    emit MintFinished();
    //    return true;
    //  }
}

contract MultisigMintBurn is MintableToken, BurnableToken {
    /**
         * @dev Minimal quorum value
         */
    uint256 public minimumQuorum;


    // ---====== ADMINS ======---
    struct Admin {
        address admin;
        bool active;
        uint256 memberSince;
        uint index;
    }

    /**
     * @dev Get delegate object by account address
     */
    mapping(address => Admin) admins;

    /**
     * @dev Congress members addresses list
     */
    address[] public adminsAddr;

    /**
     * @dev Count of members in archive
     */
    function numAdmins() public view returns (uint256) {
        return adminsAddr.length;
    }

    // ---====== PROPOSALS ======---
    /**
     * @dev Get campaign object by campaign hash
     */
    mapping(bytes32 => Proposal) public proposals;

    /**
     * @dev Proposals hashes list
     */
    bytes32[] public proposalsHash;

    /**
     * @dev Count of campaigns in list
     */
    function numProposals() public view returns (uint256) {
        return proposalsHash.length;
    }

    enum ProposalType { Mint, Burn }

    struct Proposal {
        uint indexProposal;
        uint256 proposalDate;
        ProposalType proposalType;

        address creator;
        address wallet;
        uint256 amount;

        uint256 numberOfVotes;

        address[] votesAddr;
        mapping(address => bool) voted;
    }

    /**
     * @dev Modifier that allows only shareholders to vote and create new proposals
     */
    modifier onlyAdmins {
        require (admins[msg.sender].active);
        _;
    }

    /** EVENTS **/

    /**
     * @dev On added admin
     * @param admin Account address
     */
    event AddAdmin(
        address indexed admin
    );

    /**
     * @dev On removed admin
     * @param admin Account address
     */
    event RemoveAdmin(
        address indexed admin
    );

    /**
     * @dev On voting rules changed
     * @param minimumQuorum New minimal count of votes
     */
    event ChangeOfRules(
        uint256 indexed minimumQuorum
    );

    /**
     * @dev On proposal added
     * @param sender Sender address
     * @param hash Proposal hash
     * @param wallet Wallet to send tokens
     * @param amount Amount of tokens in wei
     */
    event ProposalAdded(
        address indexed sender,
        bytes32 indexed hash,
        address wallet,
        uint256 amount
    );

    /**
     * @dev On vote by admin
     * @param sender Proposal sender
     * @param hash Proposal hash
     */
    event Voted(
        address indexed sender,
        bytes32 indexed hash
    );

    /**
     * @dev On proposal passed
     * @param sender Sender address
     * @param hash Proposal hash
     */
    event ProposalPassed(
        address indexed sender,
        bytes32 indexed hash
    );

    /**
     * @dev Add new admin
     * @param _admin Admin account address
     */
    function addAdmin(address _admin) public onlyOwner {
        require(_admin != 0x0);
        require(!admins[_admin].active);

        admins[_admin].index = adminsAddr.push(_admin) - 1;
        admins[_admin].active = true;

        admins[_admin].admin = _admin;

        emit AddAdmin(_admin);
    }

    /**
     * @dev Remove admin
     * @param _admin Admin account address
     */
    function removeAdmin(address _admin) public onlyOwner {
        require(admins[_admin].active);

        admins[_admin].active = false;

        uint rowToDelete = admins[_admin].index;
        address keyToMove   = adminsAddr[adminsAddr.length-1];
        adminsAddr[rowToDelete] = keyToMove;
        admins[keyToMove].index = rowToDelete;
        adminsAddr.length--;

        emit RemoveAdmin(_admin);
    }

    /**
     * @dev Change rules of voting
     * @param _minimumQuorumForProposals Minimal count of votes
     */
    function changeVotingRules(
        uint256 _minimumQuorumForProposals
    )
    public onlyOwner
    {
        minimumQuorum = _minimumQuorumForProposals;

        emit ChangeOfRules(minimumQuorum);
    }

    function generateHash(
        address _wallet
    )
    internal
    returns (bytes32)
    {
        return keccak256(_wallet, block.coinbase, block.number, block.timestamp);
    }

    /**
     * @dev Create a new mint proposal
     * @param _wallet Beneficiary account addresses
     * @param _amount Amount values in wei
     */
    function createMintProposal(
        address _wallet,
        uint256 _amount
    )
    public
    onlyAdmins
    {
        require(_wallet != 0x0);
        require(_amount > 0);

        _createProposal(_wallet, _amount, ProposalType.Mint);
    }

    /**
     * @dev Create a new burn proposal
     * @param _amount Amount values in wei
     */
    function createBurnProposal(
        uint256 _amount
    )
    public
    onlyAdmins
    {
        require(_amount > 0);
        require(_amount <= balances[msg.sender]);

        _createProposal(msg.sender, _amount, ProposalType.Burn);
    }

    /**
     * @dev Proposal passed. Mint or burn tokens
     * @param _wallet Account wallet to mint or to burn
     * @param _amount Amount of tokens
     * @param _proposalType Proposal type (mint or burn)
     */
    function _createProposal(
        address _wallet,
        uint256 _amount,
        ProposalType _proposalType
    )
    internal
    returns (bool)
    {
        bytes32 _hash = generateHash(_wallet);

        proposals[_hash].indexProposal = proposalsHash.push(_hash) - 1;
        proposals[_hash].proposalDate = now;
        proposals[_hash].proposalType = _proposalType;

        proposals[_hash].creator = msg.sender;
        proposals[_hash].wallet = _wallet;
        proposals[_hash].amount = _amount;

        proposals[_hash].numberOfVotes = 1;

        proposals[_hash].voted[msg.sender] = true;
        proposals[_hash].votesAddr.push(msg.sender);

        emit ProposalAdded(msg.sender, _hash, _wallet, _amount);

        if (proposals[_hash].numberOfVotes >= minimumQuorum) {
            proposalPassed(_hash);
        }
    }

    /**
     * @dev Vote for mint proposal
     * @param _hash Proposal hash
     */
    function signMintProposal(
        bytes32 _hash
    )
    public
    onlyAdmins
    returns (bool)
    {
        require(proposals[_hash].proposalDate > 0);

        require(!proposals[_hash].voted[msg.sender]);

        proposals[_hash].voted[msg.sender] = true; // Set this voter as having voted
        proposals[_hash].votesAddr.push(msg.sender);

        proposals[_hash].numberOfVotes++; // Increase the number of votes

        // Create a log of this event
        emit Voted(msg.sender, _hash);

        if (proposals[_hash].numberOfVotes >= minimumQuorum) {
            proposalPassed(_hash);
        }

        return true;
    }

    /**
     * @dev Proposal passed. Mint or burn tokens
     * @param _hash Proposal hash
     * @param _hash Proposal type (mint or burn)
     */
    function proposalPassed(
        bytes32 _hash
    )
    internal
    returns (bool)
    {
        // Proposal passed; remove from proposalsHash and send tokens
        uint rowToDelete = proposals[_hash].indexProposal;
        bytes32 keyToMove   = proposalsHash[proposalsHash.length-1];
        proposalsHash[rowToDelete] = keyToMove;
        proposals[keyToMove].indexProposal = rowToDelete;
        proposalsHash.length--;

        proposals[_hash].indexProposal = 0;

        emit ProposalPassed(msg.sender, _hash);

        if (proposals[_hash].proposalType == ProposalType.Mint) {
            return mint(proposals[_hash].wallet, proposals[_hash].amount);
        }

        if (proposals[_hash].proposalType == ProposalType.Burn) {
            return _burn(proposals[_hash].wallet, proposals[_hash].amount);
        }
    }
}

// File: contracts/tokens/StableToken.sol

contract StableToken is MultisigMintBurn, ERC223 {

    string public name = "Stable token";
    string public symbol = "STT";
    uint public decimals = 18;

    constructor() public {
        owner = msg.sender;
    }
}
