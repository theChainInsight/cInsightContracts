// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface ISkinNft {
    function getIcon(address _address) external view returns (uint256);

    function setFreemintQuantity(address _address, uint256 quantity) external;
}
