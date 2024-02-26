contract BaseMintShares {
    mapping(address => mapping(address => uint256)) public keyIndex;
    mapping(address => mapping(address => uint256[])) public purchaseTimes;
    mapping(address => mapping(address => uint256[])) public expirationTimes;
    mapping(address => mapping(address => uint256[])) public startTimes; // Mapping to store start times for each share subject
    mapping(address => uint256) public keyDurationDays; // Mapping to store key duration days for each share subject

    event SubscriptionPurchased(address indexed purchaser, address indexed shareSubject, uint256 numberOfKeys, uint256 startTime, uint256 expirationTime);
    event SubscriptionSold(address indexed seller, uint256 numberOfKeysSold);
    event SubscriptionExpired(address indexed purchaser, uint256 expiredKeys);

    modifier subscriptionNotExpired(address user, address shareSubject) {
        require(!isSubscriptionExpired(user, shareSubject), "Subscription has expired");
        _;
    }

function purchaseSubscription(address shareSubject, uint256 numberOfKeys) external subscriptionNotExpired(msg.sender, shareSubject) {
    require(numberOfKeys > 0, "Number of keys must be greater than zero");
    require(keyDurationDays[shareSubject] > 0, "Key duration not set for share subject");
    
    uint256 purchaseTime = block.timestamp;
    uint256 startTime = getStartTime(msg.sender, shareSubject);
    uint256 nextStartTime = startTime;

    for (uint256 i = 0; i < numberOfKeys; i++) {
        uint256 nextExpirationTime = nextStartTime + (keyDurationDays[shareSubject] * 1 days);
        
        purchaseTimes[shareSubject][msg.sender].push(purchaseTime);
        expirationTimes[shareSubject][msg.sender].push(nextExpirationTime);
        startTimes[shareSubject][msg.sender].push(nextStartTime); // Store start time for each key
        
        nextStartTime = nextExpirationTime; // Update start time for the next key
        keyIndex[shareSubject][msg.sender]++;
    }
    
    emit SubscriptionPurchased(msg.sender, shareSubject, numberOfKeys, startTime, nextStartTime);
    
    // Additional logic for handling the subscription purchase
}

    function getStartTime(address purchaser, address shareSubject) internal view returns (uint256) {
        uint256 lastExpirationTime = expirationTimes[shareSubject][purchaser].length > 0 ? expirationTimes[shareSubject][purchaser][expirationTimes[shareSubject][purchaser].length - 1] : block.timestamp;
        return lastExpirationTime > block.timestamp ? lastExpirationTime : block.timestamp;
    }

    function isSubscriptionExpired(address user, address shareSubject) public view returns (bool) {
        uint256[] storage expirations = expirationTimes[shareSubject][user];
        if (expirations.length == 0) {
            return false;
        }
        return expirations[expirations.length - 1] < block.timestamp;
    }

    // Other functions and logic
}


