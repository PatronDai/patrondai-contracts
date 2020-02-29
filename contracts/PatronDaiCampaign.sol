pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "../node_modules/compound-protocol/contracts/CErc20.sol";

contract PatronDaiCampaign is Exponential {
    event PatronDeposit(address indexed patron, uint256 amount);
    event PatronWithdraw(address indexed patron, uint256 amount);
    event OwnerWithdraw(uint256 amount);
    event Closed(uint256 raisedDai);

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "PatronDaiCampaign::onlyOwner: You're not the owner"
        );
        _;
    }

    address _daiAddress;
    IERC20 _DAI;

    address _cdaiAddress;
    CErc20 _CDAI;

    address _owner;
    uint256 _daiRaised;

    struct Patron {
        uint256 daiBalance;
        uint256 collateralBalance;
        uint256 lastCapitalization;
        uint256 capitalized;
    }

    mapping(address => Patron) public _patrons;

    bool public isClosed;

    constructor(address daiAddress, address cdaiAddress, address owner) public {
        _DAI = IERC20(daiAddress);
        _daiAddress = daiAddress;

        _CDAI = CErc20(cdaiAddress);
        _cdaiAddress = cdaiAddress;

        _owner = owner;
        _DAI.approve(_cdaiAddress, (2**256 - 1));
    }

    function capitalizeInternal(address addr) internal {
        uint256 cRate = _CDAI.exchangeRateCurrent();
        uint256 cRateDiff = cRate - _patrons[addr].lastCapitalization;
        _patrons[addr].capitalized +=
            (cRateDiff * _patrons[addr].collateralBalance) /
            (10**18);
        _patrons[addr].lastCapitalization = cRate;
    }

    function support(uint256 amount) external {
        require(!isClosed, "PatronDaiCampaign::support: Campaign is closed");
        require(
            msg.sender != _owner,
            "PatronDaiCampaign::support: The fund owner is not allowed to deposit"
        );
        require(
            _DAI.transferFrom(msg.sender, address(this), amount),
            "PatronDaiCampaign::support DAI transfer failed"
        );

        capitalizeInternal(msg.sender);

        _patrons[msg.sender].daiBalance += amount;
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
        _patrons[msg.sender].collateralBalance += mintTokens;
        emit PatronDeposit(msg.sender, amount);
    }

    function stopSupporting(uint256 withdrawnSupportingDaiAmount) external {
        require(
            _patrons[msg.sender].daiBalance >= withdrawnSupportingDaiAmount,
            "PatronDaiCampaign::stopSupporting you can't withdraw more than you putted in"
        );

        capitalizeInternal(msg.sender);
        uint256 cRate = _CDAI.exchangeRateCurrent();

        _CDAI.redeemUnderlying(withdrawnSupportingDaiAmount);
        _DAI.transfer(msg.sender, withdrawnSupportingDaiAmount);
        _patrons[msg.sender].daiBalance -= withdrawnSupportingDaiAmount;

        MathError err;
        uint256 mintTokens;

        (err, mintTokens) = divScalarByExpTruncate(
            withdrawnSupportingDaiAmount,
            Exp({mantissa: cRate})
        );
        _patrons[msg.sender].collateralBalance -= mintTokens;

        _daiRaised -= withdrawnSupportingDaiAmount;
        emit PatronWithdraw(msg.sender, withdrawnSupportingDaiAmount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        uint256 cRate = _CDAI.exchangeRateCurrent();
        uint256 cDaiAmount = _CDAI.balanceOf(address(this));
        uint256 daiAmount = (cRate * cDaiAmount) / (10**18);
        uint256 available = daiAmount - _daiRaised;
        require(
            amount <= available,
            "PatronDaiCampaign::withdraw you greedy bastard"
        );
        _CDAI.redeemUnderlying(amount);
        _DAI.transfer(_owner, amount);
        emit OwnerWithdraw(amount);
    }

    function close() external onlyOwner {
        emit Closed(_daiRaised);
    }

    // Getters

    function getOwner() external view returns (address) {
        return _owner;
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

    function getPatronDaiBalance(address patron)
        external
        view
        returns (uint256)
    {
        return _patrons[patron].daiBalance;
    }

    function getPatronCollateralBalance(address patron)
        external
        view
        returns (uint256)
    {
        return _patrons[patron].collateralBalance;
    }

}
