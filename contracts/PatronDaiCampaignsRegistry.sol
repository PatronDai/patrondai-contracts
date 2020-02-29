pragma solidity ^0.5.0;

import {PatronDaiCampaign} from "./PatronDaiCampaign.sol";

contract PatronDaiCampaignsRegistry {
    event CampaignRegistration(uint256 campaignId, address campaignContract);

    mapping(uint256 => address) campaigns;
    uint256 campaignsCount;

    address daiAddress;
    address cDaiAddress;

    constructor(address _daiAddress, address _cDaiAddress) public {
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
