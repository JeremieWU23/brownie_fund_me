// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// // import Interface
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// interface AggregatorV3Interface {
//     function decimals() external view returns (uint8);

//     function description() external view returns (string memory);

//     function version() external view returns (uint256);

//     function getRoundData(
//         uint80 _roundId
//     )
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );

//     function latestRoundData()
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );
// }

contract FundMe {
    // The value senders
    mapping(address => uint256) public addToAmount;
    // Reset balance after withdraw
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        // Set threshold($5)
        uint256 minimumUSD = 5 * 10 ** 18;
        // Need to know ETH -> USD rate
        // require(getConversionRate(msg.value) >= minimumUSD, "Need more ETH!");
        if (getConversionRate(msg.value) < minimumUSD) {
            revert("Need more ETH!!!!!!!!");
        }

        // msg.sender，msg.value
        addToAmount[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        return priceFeed.version();
    }

    function getPrice() public view returns (int256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (
            ,
            /*uint80 roundId*/ int256 answer /*uint256 startedAt*/ /*uint256 updatedAt*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return answer;
    }

    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = uint256(getPrice());
        uint256 ethAmountInUsd = (ethPrice * ethAmount);
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 pricefeed_precision = 10 ** 8;
        // get number of 1Eth = ?USD * 10**8
        uint256 price = uint256(getPrice());
        // minimumUSD number
        uint256 minimumUSD = 50;
        uint256 precision = 1 * 10 ** 18;
        return (minimumUSD * pricefeed_precision * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        // Only owner can withdraw
        // require(msg.sender == owner);
        // Only payable address can transfer value
        payable(msg.sender).transfer(address(this).balance);
        // reset balance
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funderAdd = funders[funderIndex];
            addToAmount[funderAdd] = 0;
        }
        funders = new address[](0);
    }
}
