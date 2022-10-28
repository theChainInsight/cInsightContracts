// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library SbtLib {
    bytes32 constant SBT_STRUCT_POSITION = keccak256("chaininsight");

    struct SbtStruct {
        address contractOwner;
        string name;
        string symbol;
        string baseURI;
        bytes32 validator;
        mapping(address => uint16) address2index;
        uint8[] favo_list;
        uint16[] received_favo_list;
        uint16[] maki_list;
        uint8[] grade_list;
        uint32[] rate_list;
        uint8[] referral_list; // リファラルした回数
        mapping(address => mapping (string => uint8)) maxstar_map; // 各ユーザーの各ジャンルタグの最大のスター数
        mapping(bytes4 => bool) interfaces;
    }

    // get struct stored at posititon
    //https://solidity-by-example.org/app/write-to-any-slot/
    function sbtStorage() internal pure returns (SbtStruct storage sbtstruct) {
        /** メモ: @shion
         * slot: storageは32バイトの領域を確保するが，その領域をslotと呼ぶ
         * positionのstrunctを取得する
         */
        bytes32 position = SBT_STRUCT_POSITION;
        assembly {
            sbtstruct.slot := position
        }
    }
}