pragma solidity ^0.5.0;

import {
    IERC20
} from "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

import {CErc20} from "../node_modules/compound-protocol/contracts/CErc20.sol";

contract PatronDaiCampaign {
    event SupporterDeposit(address indexed investor, uint256 amount);
    event SupporterWithdraw(address indexed investor, uint256 amount);

    event Announcement(bytes32 mediumPostUUID, bytes32 bodyHash);
    event RaiserWithdraw(uint256 amount);
    event Closed(uint256 raisedDai);

    modifier onlyRaiser() {
        require(
            msg.sender == _raiser,
            "PatronDaiCampaign::onlyRaiser you're not the raiser, u squirvel"
        );
        _;
    }

    address _daiAddress;
    IERC20 _DAI;

    address _cdaiAddress;
    CErc20 _CDAI;

    address _raiser;
    uint256 _daiRaised;

    mapping(address => uint256) public _supportersSubmissions;
    mapping(address => uint256) public _supportersCollateralBalance;

    bool public isClosed;

    constructor(address daiAddress, address cdaiAddress, address raiser)
        public
    {
        _DAI = IERC20(daiAddress);
        _daiAddress = daiAddress;

        _CDAI = CErc20(cdaiAddress);
        _cdaiAddress = cdaiAddress;

        _raiser = raiser;
    }

    function support(uint256 amount) external {
        require(
            !isClosed,
            "PatronDaiCampaign::support campaign already closed"
        );
        require(
            msg.sender != _raiser,
            "PatronDaiCampaign::support the founds raiser is not allowed to deposit"
        );
        require(
            _DAI.transferFrom(msg.sender, address(this), amount),
            "PatronDaiCampaign::support DAI transfer failed"
        );

        uint256 collateralBalanceBeforeMint = _CDAI.balanceOf(address(this));

        _supportersSubmissions[msg.sender] += amount;
        _daiRaised += amount;

        _CDAI.mint(amount);

        uint256 collateralBalanceAfterMint = _CDAI.balanceOf(address(this));
        _supportersCollateralBalance[msg
            .sender] += (collateralBalanceAfterMint -
            collateralBalanceBeforeMint);
        emit SupporterDeposit(msg.sender, amount);
    }

    function stopSupporting(uint256 withdrawnSupportingDaiAmount) external {
        require(
            _supportersSubmissions[msg.sender] >= withdrawnSupportingDaiAmount,
            "PatronDaiCampaign::stopSupporting you can't withdraw more than you putted in"
        );

        _CDAI.redeemUnderlying(withdrawnSupportingDaiAmount);
        _DAI.transfer(msg.sender, withdrawnSupportingDaiAmount);
        _supportersSubmissions[msg.sender] -= withdrawnSupportingDaiAmount;
        _daiRaised -= withdrawnSupportingDaiAmount;
        emit SupporterWithdraw(msg.sender, withdrawnSupportingDaiAmount);
    }

    function withdraw(uint256 amount) external {
        uint256 cRate = _CDAI.exchangeRateCurrent();
        uint256 cDaiAmount = _CDAI.balanceOf(address(this));
        uint256 daiAmount = cRate * cDaiAmount;
        uint256 available = daiAmount - _daiRaised;
        require(
            amount <= available,
            "PatronDaiCampaign::withdraw you greedy bastard"
        );
        _CDAI.redeemUnderlying(amount);
        _DAI.transfer(_raiser, amount);
        emit RaiserWithdraw(amount);
    }

    function announce(bytes32 mediumPostUUID, bytes32 bodyHash)
        external
        onlyRaiser
    {
        emit Announcement(mediumPostUUID, bodyHash);
    }

    function close() external onlyRaiser {
        emit Closed(_daiRaised);
    }

    // Getters

    function getRaiser() external view returns (address) {
        return _raiser;
    }

    function getDaiRaised() external view returns (uint256) {
        return _daiRaised;
    }

    function getDaiAddress() external view returns (address) {
        return _daiAddress;
    }

    function getCDaiAddress() external view returns (address) {
        return _cdaiAddress;
    }

    function getSupporterSubmission(address supporter)
        external
        view
        returns (uint256)
    {
        return _supportersSubmissions[supporter];
    }

    function getSubmission() external view returns (uint256) {
        return this.getSupporterSubmission(msg.sender);
    }

    function getSupporterCollateralBalance(address supporter)
        external
        view
        returns (uint256)
    {
        return _supportersCollateralBalance[supporter];
    }

    function getCollateralBalance() external view returns (uint256) {
        return this.getSupporterCollateralBalance(msg.sender);
    }

}
