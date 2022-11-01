// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "./../../src/sbt/Sbt.sol";
import "./../../src/sbt/SbtImp.sol";
import "./../../src/skinnft/SkinNft.sol";

contract SbtTest is Test {
    address admin = address(0xad000);
    Sbt internal sbt;
    SbtImp internal imp;
    SkinNft internal skinNft;

    function setUp() public {
        sbt = new Sbt();
        imp = new SbtImp();
        skinNft = new SkinNft("https://thechaininsight.github.io/skinnft/");

        sbt.init(
            admin,
            "ChainInsight",
            "SBT",
            "https://thechaininsight.github.io/sbt/",
            address(skinNft)
        );
        skinNft.init(address(sbt));
        bytes4[] memory sigs = new bytes4[](5);
        address[] memory impAddress = new address[](5);
        sigs[0] = bytes4(keccak256("mint()"));
        sigs[1] = bytes4(keccak256("mintWithReferral(address)"));
        sigs[2] = bytes4(keccak256("refer(address)"));
        sigs[3] = bytes4(keccak256("monthInit()"));
        sigs[4] = bytes4(keccak256("addFavos(address,uint8)"));
        impAddress[0] = address(imp);
        impAddress[1] = address(imp);
        impAddress[2] = address(imp);
        impAddress[3] = address(imp);
        impAddress[4] = address(imp);
        vm.prank(admin);
        sbt.setImplementation(sigs, impAddress);
    }

    function testInit() public {
        assertEq(sbt.name(), "ChainInsight");
        assertEq(sbt.symbol(), "SBT");
        assertEq(sbt.admin(), admin);
    }

    function testSupportsInterface() public {
        assertEq(sbt.supportsInterface(0x01ffc9a7), true);
        assertEq(sbt.supportsInterface(0x5b5e139f), true);
    }

    function testMint() public {
        address manA = address(0xa);
        payable(manA).call{value: 40 ether}("");

        address manB = address(0xb);
        payable(manB).call{value: 40 ether}("");

        address manC = address(0xc);
        payable(manC).call{value: 40 ether}("");

        address manD = address(0xd);
        payable(manD).call{value: 40 ether}("");

        address manE = address(0xe);
        payable(manE).call{value: 40 ether}("");

        address manF = address(0xf);
        payable(manF).call{value: 40 ether}("");

        address beef = address(0xbeef);
        payable(beef).call{value: 40 ether}("");

        vm.prank(manA);
        address(sbt).call{value: 26 ether}(abi.encodeWithSignature("mint()"));
        assertEq(sbt.ownerOf(1), manA);
        assertEq(20 ether, manA.balance);
        assertEq(20 ether, address(sbt).balance);

        vm.prank(manB);
        address(sbt).call{value: 26 ether}(abi.encodeWithSignature("mint()"));
        assertEq(sbt.ownerOf(2), manB);

        vm.prank(manC);
        address(sbt).call{value: 26 ether}(abi.encodeWithSignature("mint()"));
        vm.prank(manD);
        address(sbt).call{value: 26 ether}(abi.encodeWithSignature("mint()"));
        vm.prank(manE);
        bool zero;
        bytes memory retData;
        (zero, retData) = address(sbt).call{value: 20 ether}(
            abi.encodeWithSignature("mint()")
        );
        assertEq(abi.decode(retData, (uint256)), 5);
        assertEq(sbt.mintedTokenNumber(), 5);

        // test add favo
        vm.prank(manA);
        address(sbt).call(
            abi.encodeWithSignature("addFavos(address,uint8)", manB, 10)
        );
        assertEq(sbt.favoOf(manA), 10);
        assertEq(sbt.makiMemoryOf(manB), 50);

        vm.prank(manA);
        address(sbt).call(
            abi.encodeWithSignature("addFavos(address,uint8)", manC, 9)
        );
        assertEq(sbt.favoOf(manA), 19);
        assertEq(sbt.makiMemoryOf(manC), 45);

        vm.prank(manA);
        address(sbt).call(
            abi.encodeWithSignature("addFavos(address,uint8)", manD, 3)
        );
        assertEq(sbt.favoOf(manA), 20);
        assertEq(sbt.makiMemoryOf(manD), 5);

        vm.expectRevert(bytes("favo num must be bigger than 0"));
        vm.prank(manA);
        address(sbt).call(
            abi.encodeWithSignature("addFavos(address,uint8)", manC, 0)
        );

        //month init
        address(sbt).call(abi.encodeWithSignature("monthInit()"));
        assertEq(sbt.makiOf(manA), 1);
        assertEq(sbt.gradeOf(manA), 2);
        assertEq(sbt.gradeOf(manB), 4);
        assertEq(sbt.gradeOf(manC), 3);
        assertEq(sbt.gradeOf(manD), 2);
        assertEq(sbt.gradeOf(manE), 1);

        // // test referral mint

        vm.prank(manB);
        address(sbt).call(abi.encodeWithSignature("refer(address)", beef));
        vm.prank(beef);
        address(sbt).call{value: 20 ether}(
            abi.encodeWithSignature("mintWithReferral(address)", manB)
        );

        assertEq(address(manB).balance, 30 ether);
        assertEq(address(beef).balance, 25 ether);
    }

    // function testSetadmin() public {
    //     address newOwner = address(3);
    //     vm.prank(owner);
    //     (, bytes memory result) = address(sbt).call(
    //         abi.encodeWithSignature("setadmin(address)", newOwner)
    //     );
    //     assertEq(sbt.admin(), newOwner);

    //     vm.expectRevert(bytes("OWNER ONLY"));
    //     address(sbt).call(
    //         abi.encodeWithSignature("setadmin(address)", newOwner)
    //     );
    // }
    receive() external payable {}
}
