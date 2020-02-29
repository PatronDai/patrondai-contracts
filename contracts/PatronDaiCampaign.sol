pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

import "../node_modules/compound-protocol/contracts/CErc20.sol";

contract PatronDaiCampaign is Exponential {
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

    struct Supporter {
        uint256 daiBalance;
        uint256 collateralBalance;
        uint256 lastCapitalization;
        uint256 capitalized;
    }

    mapping(address => Supporter) public _supporters;

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

    function capitalizeInternal(address addr) internal {
        uint256 cRate = _CDAI.exchangeRateCurrent();
        uint256 cRateDiff = cRate - _supporters[addr].lastCapitalization;
        _supporters[addr].capitalized +=
            cRateDiff *
            _supporters[addr].collateralBalance;
        _supporters[addr].lastCapitalization = cRate;
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

        capitalizeInternal(msg.sender);

        _supporters[msg.sender].daiBalance += amount;
        _daiRaised += amount;

        uint256 cRate = _CDAI.exchangeRateCurrent();

        MathError err;
        uint256 mintTokens;

        (err, mintTokens) = divScalarByExpTruncate(
            amount,
            Exp({mantissa: cRate})
        );

        // todo: do not ignore errors, it's bad

        _CDAI.mint(amount);
        _supporters[msg.sender].collateralBalance = mintTokens;
        emit SupporterDeposit(msg.sender, amount);
    }

    function stopSupporting(uint256 withdrawnSupportingDaiAmount) external {
        require(
            _supporters[msg.sender].daiBalance >= withdrawnSupportingDaiAmount,
            "PatronDaiCampaign::stopSupporting you can't withdraw more than you putted in"
        );

        capitalizeInternal(msg.sender);

        _CDAI.redeemUnderlying(withdrawnSupportingDaiAmount);
        _DAI.transfer(msg.sender, withdrawnSupportingDaiAmount);
        _supporters[msg.sender].daiBalance -= withdrawnSupportingDaiAmount;
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

    function getSupporterDaiBalance(address supporter)
        external
        view
        returns (uint256)
    {
        return _supporters[supporter].daiBalance;
    }

    function getDaiBalance() external view returns (uint256) {
        return this.getSupporterDaiBalance(msg.sender);
    }

    function getSupporterCollateralBalance(address supporter)
        external
        view
        returns (uint256)
    {
        return _supporters[supporter].collateralBalance;
    }

    function getCollateralBalance() external view returns (uint256) {
        return this.getSupporterCollateralBalance(msg.sender);
    }

    function getTotalSupport() external returns (uint256) {
        capitalizeInternal(msg.sender);
        return _supporters[msg.sender].capitalized;
    }

}
