pragma solidity ^0.4.24;

// Import the custom token contract you just wrote.
import "./ALToken.sol";

/** This is an assignment to create a smart contract that allows you to run your own token crowdsale.
 *  Your contract will mint your custom token every time a purchase is made by your or your classmates.
 *  We've provided you with the pseudocode and some hints to guide you in the right direction.
 *  Make sure to implement the best practices you learned during the Solidity Walkthrough segment.
 *  Check for errors by compiling often. Ask your classmates for help - we highly encourage student collaboration.
 *  You should be able to deploy your crowdsale contract onto the Rinkeby testnet and buy/sell your classmates' tokens.
 */
 
// Set up your contract.
contract MintedCrowdsale {
    // Attach SafeMath library functions to the uint256 type.
    using SafeMath for uint256;

    // Define 4 publicly accessible state variables.
    // Your custom token being sold, which refers to the address of contract ALToken.
    ALToken public token;
  
    // Wallet address where funds are collected.
    address public wallet;

    // Rate of how many token units a buyer gets per wei. Note that wei*10^-18 converts to ether.
    uint256 public rate;

    // Amount of wei raised.
    uint256 public weiRaised;

    /** Create event to log token purchase with 4 parameters:
    * 1) Who paid for the tokens
    * 2) Who got the tokens
    * 3) Number of weis paid for purchase
    * 4) Amount of tokens purchased
    */
    event TokenPurchase(address indexed buyer, address indexed beneficiary, uint256 amountPaid, uint256 numTokens);

    /** Create publicly accessible constructor function with 3 parameters:
    * 1) Rate of how many token units a buyer gets per wei
    * 2) Wallet address where funds are collected
    * 3) Address of your custom token being sold
    * Function modifiers are incredibly useful and effective. Make sure to use the right ones for each Solidity function you write.
    */
    // this should not be payable (Remix error)
    constructor(uint256 _rate, address _wallet, ALToken _token) public {
        // Set conditions with require statements to make sure the rate is a positive number and the addresses are non-zero.
        require(_rate > 0);
        require(_wallet != address(0)); // the zero address has a destroyed private key
        require(_token != address(0));

        // Set inputs as defined state variables
        rate = _rate;
        wallet = _wallet;
        token = _token;
    }    

    // THIS PORTION IS FOR THE CONTRACT'S EXTERNAL INTERFACE.
    // We suggest skipping down to fill out the internal interface before coming back to complete the external interface.
    
    // Create the fallback function that is called whenever anyone sends funds to this contract.
    // Fallback functions are functions without a name that serve as a default function.
    // Functions dealing with funds have a special modifier.
    function () external payable {
        // Call buyTokens function with the address defaulting to the address the message originates from.
        buyTokens(msg.sender);
    }

    // Create the function used for token purchase with one parameter for the address receiving the token purchase.
    // Don't forget your modifiers.
    function buyTokens(address _beneficiary) public payable {

        // Define a uint256 variable that is equal to the number of wei sent with the message.
        uint256 amountPaid = msg.value;

        // Call function that validates an incoming purchase with two parameters, receiver and number of wei sent.
        _preValidatePurchase(_beneficiary, amountPaid);

        // Calculate token amount to be created and define it as type uint256.
        uint256 tokensBought = _getTokenAmount(amountPaid);

        // Update amount of funds raised.
        // SafeMath prevents overflow errors.
        weiRaised = weiRaised.add(amountPaid);

        // Call function that processes a purchase with two parameters, receiver and token amount.
        _processPurchase(_beneficiary, tokensBought);

        // Raise the event associated with a token purchase, note that msg.sender pays for the transaction.
        emit TokenPurchase(msg.sender, _beneficiary, amountPaid, tokensBought);
    
        // Call function that stores ETH from purchases into a wallet address.
        _forwardFunds();
    }

    // THIS PORTION IS FOR THE CONTRACT'S INTERNAL INTERFACE.
    // Remember, the following functions are for the contract's internal interface.

    // Create function that validates an incoming purchase with two parameters: beneficiary's address and value of wei.
    function _preValidatePurchase(address _beneficiary, uint256 _amountPaid) internal pure {
        // Set conditions to make sure the beneficiary's address and the value of wei involved in purchase are non-zero.
        require(_beneficiary != address(0));
        require(_amountPaid != 0);
    }

    // Create function that delivers the purchased tokens with two parameters: beneficiary's address and number of tokens.
    function _deliverTokens(address _beneficiary, uint256 _numTokens) internal {
        // Set condition that requires contract to mint your custom token with the mint method inherited from your MintableToken contract.
        require(ALToken(token).mint(_beneficiary, _numTokens));
    }

    // Create function that executes the deliver function when a purchase has been processed with two parameters: beneficiary's address and number of tokens.
    function _processPurchase(address _beneficiary, uint256 _numTokens) internal {
        _deliverTokens(_beneficiary, _numTokens);
    }

    // Create function to convert purchase value in wei into tokens with one parameter: value in wei.
    // Write the function so that it returns the number of tokens (value in wei multiplied by defined rate).
    // Multiplication can be done as a method.
    function _getTokenAmount(uint256 _amountPaid) internal view returns (uint256) {
        return _amountPaid.mul(rate);
    }

    // Create function to store ETH from purchases into a wallet address.
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}
