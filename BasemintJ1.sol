/**
 *Submitted for verification at basescan.org on 2024-01-18
*/

/**
    *Submitted for verification at basescan.org on 2023-12-19
    */

    // File: contracts/Context.sol
    // SPDX-License-Identifier: MIT
    // OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

    pragma solidity ^0.8.20;

    /**
    * @dev Provides information about the current execution context, including the
    * sender of the transaction and its data. While these are generally available
    * via msg.sender and msg.data, they should not be accessed in such a direct
    * manner, since when dealing with meta-transactions the account sending and
    * paying for execution may not be the actual sender (as far as an application
    * is concerned).
    *
    * This contract is only required for intermediate, library-like contracts.
    */
    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes calldata) {
            return msg.data;
        }

        function _contextSuffixLength() internal view virtual returns (uint256) {
            return 0;
        }
    }
    // OpenZeppelin Contracts (last updated v5.0.1) (metatx/ERC2771Context.sol)
    // A.Chu modified with ERC2771 v5.0.1 msgSender and msgData post multicall fix

    pragma solidity ^0.8.20;

    /**
    * @dev Context variant with ERC2771 support.
    *
    * WARNING: Avoid using this pattern in contracts that rely on a specific calldata length as they'll
    * be affected by any forwarder whose `msg.data` is suffixed with the `from` address according to the ERC2771
    * specification adding the address size in bytes (20) to the calldata size. An example of unexpected
    * behavior could be an unintended fallback (or another function) invocation while trying to invoke the `receive`
    * function only accessible if `msg.data.length == 0`.
    */
    abstract contract ERC2771Context is Context {

        /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
        address[] private _trustedForwarders;

        /**
        * @dev Initializes the contract with multiple trusted forwarders, which will be able to
        * invoke functions on this contract on behalf of other accounts.
        *
        * NOTE: The trusted forwarders can be replaced by overriding {trustedForwarders}.
        */
        /// @custom:oz-upgrades-unsafe-allow constructor
        constructor(address[] memory trustedForwarders_) {
            _trustedForwarders = trustedForwarders_;
        }

        /**
        * @dev Returns the addresses of the trusted forwarders.
        */
        function trustedForwarders() public view virtual returns (address[] memory) {
            return _trustedForwarders;
        }

        /**
        * @dev Indicates whether any particular address is a trusted forwarder.
        */
        function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
            for (uint256 i = 0; i < _trustedForwarders.length; i++) {
                if (forwarder == _trustedForwarders[i]) {
                    return true;
                }
            }
            return false;
        }

        /**
        * @dev Override for `msg.sender`. Defaults to the original `msg.sender` whenever
        * a call is not performed by the trusted forwarder or the calldata length is less than
        * 20 bytes (an address length).
        */
        function _msgSender() internal view virtual override returns (address) {
            uint256 calldataLength = msg.data.length;
            uint256 contextSuffixLength = _contextSuffixLength();

            if (isTrustedForwarder(msg.sender) && calldataLength >= contextSuffixLength) {
                return address(bytes20(msg.data[calldataLength - contextSuffixLength:]));
            } else {
                return super._msgSender();
            }
        }

        /**
        * @dev Override for `msg.data`. Defaults to the original `msg.data` whenever
        * a call is not performed by the trusted forwarder or the calldata length is less than
        * 20 bytes (an address length).
        */
        function _msgData() internal view virtual override returns (bytes calldata) {
            uint256 calldataLength = msg.data.length;
            uint256 contextSuffixLength = _contextSuffixLength();
            if (isTrustedForwarder(msg.sender) && calldataLength >= contextSuffixLength) {
                return msg.data[:calldataLength - contextSuffixLength];
            } else {
                return super._msgData();
            }
        }

        /**
        * @dev ERC-2771 specifies the context as being a single address (20 bytes).
        */
        function _contextSuffixLength() internal view virtual override returns (uint256) {
            return 20;
        }
        
    }



    // File: contracts/Ownable.sol


    // OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

    pragma solidity ^0.8.0;


    /**
    * @dev Contract module which provides a basic access control mechanism, where
    * there is an account (an owner) that can be granted exclusive access to
    * specific functions.
    *
    * By default, the owner account will be the one that deploys the contract. This
    * can later be changed with {transferOwnership}.
    *
    * This module is used through inheritance. It will make available the modifier
    * `onlyOwner`, which can be applied to your functions to restrict their use to
    * the owner.
    */
    abstract contract Ownable is Context {
        address private _owner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
        constructor() {
            _transferOwnership(_msgSender());
        }

        /**
        * @dev Throws if called by any account other than the owner.
        */
        modifier onlyOwner() {
            _checkOwner();
            _;
        }

        /**
        * @dev Returns the address of the current owner.
        */
        function owner() public view virtual returns (address) {
            return _owner;
        }

        /**
        * @dev Throws if the sender is not the owner.
        */
        function _checkOwner() internal view virtual {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
        }

        /**
        * @dev Leaves the contract without owner. It will not be possible to call
        * `onlyOwner` functions anymore. Can only be called by the current owner.
        *
        * NOTE: Renouncing ownership will leave the contract without an owner,
        * thereby removing any functionality that is only available to the owner.
        */
        function renounceOwnership() public virtual onlyOwner {
            _transferOwnership(address(0));
        }

        /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Can only be called by the current owner.
        */

        function transferOwnership(address newOwner) public virtual onlyOwner {
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            _transferOwnership(newOwner);
        }

        /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Internal function without access restriction.
        */
        function _transferOwnership(address newOwner) internal virtual {
            address oldOwner = _owner;
            _owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
        }
    }


    // File: contracts/basemintShare.sol

    pragma solidity >=0.8.2 <0.9.0;

    contract BasemintSharesJ1 is ERC2771Context, Ownable {
        address public protocolFeeDestination;
        uint256 public protocolFeePercent;
        uint256 public subjectFeePercent;
        uint256 public affiliateFeePercent;
        uint256 public defaultInitialPrice;
        uint256 public defaultPriceIncrement;
        address public defaultAffiliate; 

        // Event for logging trades
        event Trade(address indexed buyer, address indexed subject, address indexed affiliate,  uint256 shareAmount, uint256 ethAmount, uint256 shareBalance);

        // Event for debugging trusted forwarders
        event Forwarders(address originalsender, address functionsender, address fromsender);     

        // Event to log the key grant
        event KeysGranted(address indexed sharesSubject, address indexed recipient, uint256 amount);
 
        // SharesSubject => (Holder => Balance)
        mapping(address => mapping(address => uint256)) public sharesBalance;

        // SharesSubject => Supply
        mapping(address => uint256) public sharesSupply;

        // priceIncrement and initialPrice and affiliate functions

        // Mapping to store initialPrice and priceIncrement for each sharesSubject
        mapping(address => uint256) public sharesInitialPrice;
        mapping(address => uint256) public sharesPriceIncrement;

        // Mapping to save initialization state for initialPrice and priceIncrement for each sharesSubject
        mapping(address => bool) public sharesInitialPriceIsSet;
        mapping(address => bool) public sharesPriceIncrementIsSet;

        // SharesSubject => Affiliate
        mapping(address => address) public sharesAffiliate;

        // Mapping to save initialization state for sharesAffiliate for each sharesSubject
        mapping(address => bool) public sharesAffiliateIsSet;
        
        // Minimal forwarder contract address
        address[] public _trustedForwarders;

        constructor(address[] memory trustedForwarders_) ERC2771Context(trustedForwarders_){
            _trustedForwarders = trustedForwarders_;
            protocolFeeDestination = owner();
            defaultAffiliate = owner();
            subjectFeePercent = 80;
            protocolFeePercent = 15;       
            affiliateFeePercent = 5;
            defaultInitialPrice = 0.001 * 1 ether;
            defaultPriceIncrement = 0.001 * 1 ether;
        }

            // ERC-2771 functions

        function _msgSender() internal view override(Context, ERC2771Context) 
            returns (address sender) {    
            sender = ERC2771Context._msgSender();
        }

        function _msgData() internal view override(Context, ERC2771Context)
            returns (bytes calldata) {
            return ERC2771Context._msgData();
        }

        /**
        * @dev ERC-2771 specifies the context as being a single address (20 bytes).
        */
        function _contextSuffixLength() internal view virtual override(Context, ERC2771Context) returns (uint256) {
            return 20;
        }

        // Function to set the trusted forwarders, callable only by the owner
        function setTrustedForwarders(address[] memory trustedForwarders_) external onlyOwner {
            _trustedForwarders = trustedForwarders_;
        }

        // Existing functions

        function setFeeDestination(address _feeDestination) public onlyOwner {
            protocolFeeDestination = _feeDestination;
        }

        function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
            protocolFeePercent = _feePercent;
        }

        function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
            subjectFeePercent = _feePercent;
        }

        // Set Default Price Parameters

        function setDefaultInitialPrice(uint256 _defaultInitialPrice) public onlyOwner {
            defaultInitialPrice = _defaultInitialPrice;
        }

        function setDefaultPriceIncrement(uint256 _defaultPriceIncrement) public onlyOwner {
            defaultPriceIncrement = _defaultPriceIncrement;
        }

        // Modifier to allow only sharesSubject or trusted forwarder to call the function
        modifier onlySharesSubjectOrForwarder(address sharesSubject) {
            require(sharesSubject == _msgSender() || isTrustedForwarder(_msgSender()), "Caller is not the subject or trusted forwarder");
            _;
        }

        // Function to set initialPrice, only callable by sharesSubject or trusted forwarder
        function setInitialPrice(uint256 initialPrice) public onlySharesSubjectOrForwarder(_msgSender()) {
            sharesInitialPrice[_msgSender()] = initialPrice;
            sharesInitialPriceIsSet[_msgSender()] = true;
        }

        // Function to set priceIncrement, only callable by sharesSubject or trusted forwarder
        function setPriceIncrement(uint256 priceIncrement) public onlySharesSubjectOrForwarder(_msgSender()) {
            sharesPriceIncrement[_msgSender()] = priceIncrement;
            sharesPriceIncrementIsSet[_msgSender()] = true;
        }

        // Function to set affiliate, only callable by owner
        function setAffiliate(address sharesSubject, address shareAffiliate) public onlyOwner {
            sharesAffiliate[sharesSubject] = shareAffiliate;
            sharesAffiliateIsSet[sharesSubject] = true;
        }

        // Function to get initialPrice
        function getInitialPrice(address sharesSubject) public view returns (uint256) {
            uint256 initialPrice = defaultInitialPrice;

            if (sharesInitialPriceIsSet[sharesSubject] == true) {
                initialPrice = sharesInitialPrice[sharesSubject];
            }
            
            return initialPrice;
        }

        // Function to get sharesAffiliate
        function getAffiliate(address sharesSubject) public view returns (address) {
            address thisAffiliate = defaultAffiliate;

            if (sharesAffiliateIsSet[sharesSubject] == true) {
                thisAffiliate = sharesAffiliate[sharesSubject];
            }        
            
            return thisAffiliate;
        }

            // Function to get priceIncrement
        function getPriceIncrement(address sharesSubject) public view returns (uint256) {
            uint256 priceIncrement = defaultPriceIncrement;

            if (sharesPriceIncrementIsSet[sharesSubject] == true) {
                priceIncrement = sharesPriceIncrement[sharesSubject];
            }        
            
            return priceIncrement;
        }

        // getPrice Functions

        function getPrice(address sharesSubject, uint256 initialSupply, uint256 buyAmount) public view returns (uint256) {
            // Check if the provided buyAmount is valid
            require(buyAmount > 0, "Invalid buy amount");

            uint256 initialPrice = defaultInitialPrice;
            uint256 priceIncrement = defaultPriceIncrement;

            // Check if either price variable has been set for this sharesSubject
            if (sharesInitialPriceIsSet[sharesSubject] == true){
                initialPrice = sharesInitialPrice[sharesSubject];
            }

            if (sharesPriceIncrementIsSet[sharesSubject] == true){
                priceIncrement = sharesPriceIncrement[sharesSubject];
            }

            // Calculate the adjusted initial term based on the current supply
            uint256 adjustedInitialTerm = initialPrice + initialSupply * priceIncrement;

            // Calculate the total price based on adjustedInitialTerm and cumulative priceIncrement for the specified amount
            uint256 totalPrice = ((2 * adjustedInitialTerm + (buyAmount - 1) * priceIncrement) * buyAmount) / 2;

            return totalPrice;

        }

        function getBuyPrice(address sharesSubject, uint256 buyAmount) public view returns (uint256) {
            // modify + 1 for exclusion of subject
            return getPrice(sharesSubject, sharesSupply[sharesSubject], buyAmount);
        }

        // Modify the buyShares function to store the buyer's purchase price and to set affiliate upon first purchase if provided
        function buyShares(address sharesSubject, uint256 buyAmount, address from) public payable {
            
            // emit Forwarders(msg.sender, _msgSender() , from); // For debugging forwarders

            // Check if the provided buyAmount is valid
            require(buyAmount > 0, "Invalid buy amount");
            
            //Condition 1: check if msg.sender is the from address
            //Condition 2: check if msg.sender is trustedForwarder or null 
            //AND original sender of metatransaction (i.e. _msgSender()) is "from" address
            if (msg.sender != from) {
                require((isTrustedForwarder(msg.sender) || msg.sender == address(0)) && _msgSender() == from, "Caller is not the trusted forwarder or buyer");
            }
            
            // Check if both initial price and price increment have been changed from default and are set to 0
            if (sharesInitialPriceIsSet[sharesSubject] && sharesPriceIncrementIsSet[sharesSubject] &&
                sharesInitialPrice[sharesSubject] == 0 && sharesPriceIncrement[sharesSubject] == 0) {
                // If both are 0 and "isset" is true for both, overwrite buyAmount to 1
                buyAmount = 1;
            }
            
            uint256 supply = sharesSupply[sharesSubject];

            // Calculate the total buying price based on the provided buyAmount
            uint256 totalPrice = getPrice(sharesSubject, supply, buyAmount);

            uint256 protocolFee = totalPrice * protocolFeePercent / 100;
            uint256 subjectFee = totalPrice * subjectFeePercent / 100;
            uint256 affiliateFee = totalPrice * affiliateFeePercent / 100;
            address thisAffiliate = getAffiliate(sharesSubject);

            require(msg.value >= totalPrice, "Insufficient payment");

            // Deduct fees from the purchase price
            uint256 remainingValue = msg.value - subjectFee - affiliateFee - protocolFee;

            // Increment balance and supply by buyAmount
            sharesBalance[sharesSubject][from] = sharesBalance[sharesSubject][from] + buyAmount;
            sharesSupply[sharesSubject] = supply + buyAmount;

            uint256 balance = sharesBalance[sharesSubject][from];

            emit Trade(from, sharesSubject, thisAffiliate, buyAmount, totalPrice, balance);

            (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
            (bool success2, ) = sharesSubject.call{value: subjectFee}("");
            (bool success3, ) = thisAffiliate.call{value: affiliateFee}("");
            require(success1 && success2 && success3, "Unable to send funds");

            // Refund any excess funds to the buyer
            if (remainingValue > 0) {
                (bool success4, ) = from.call{value: remainingValue}("");
                require(success4, "Unable to refund excess funds");
            }
        }

        // Grantkeys function allows sharesSubject to grant keys to one or more recipients
        function grantKeys(address[] memory recipients, uint256[] memory amounts) external onlySharesSubjectOrForwarder(_msgSender()) {
            require(recipients.length == amounts.length, "Array lengths do not match");

            address sharesSubject = _msgSender();

            for (uint256 i = 0; i < recipients.length; i++) {
                // Check if the provided amount is valid
                require(amounts[i] > 0, "Invalid key amount");

                // Increment balance and supply for each recipient
                sharesBalance[sharesSubject][recipients[i]] += amounts[i];
                sharesSupply[sharesSubject] += amounts[i];

                uint256 balance = sharesBalance[sharesSubject][recipients[i]];

                // Emit an event for each grant
                emit Trade(sharesSubject, recipients[i], address(0), amounts[i], 0, balance);
            }
        }


    }