pragma solidity ^0.5.0;

import {PatronDaiCampaign} from "./PatronDaiCampaign.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract PatronDaiCampaignsRegistry is Initializable {
    event CampaignRegistration(uint256 campaignId, address campaignContract);

    mapping(uint256 => address) campaigns;
    uint256 campaignsCount;

    address daiAddress;
    address cDaiAddress;

    function initialize(address _daiAddress, address _cDaiAddress)
        public
        initializer
    {
        daiAddress = _daiAddress;
        cDaiAddress = _cDaiAddress;
    }

    function registerCampaign() external {
        PatronDaiCampaign campaign = new PatronDaiCampaign(
            daiAddress,
            cDaiAddress,
            msg.sender
        );
        campaigns[campaignsCount] = address(campaign);
        emit CampaignRegistration(campaignsCount++, address(campaign));
    }

    function getCampaign(uint256 id) external view returns (address) {
        return campaigns[id];
    }

    function getCampaignsCount() external view returns (uint256) {
        return campaignsCount;
    }

}
