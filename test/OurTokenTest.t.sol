// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    uint256 public constant STARTING_BALANCE = 100 ether;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    // Codeium extension with GPT-4:
    uint256 public constant transferAmount = 50 * 10 ** 18;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
        // Codeium extension with GPT-4:
        vm.prank(msg.sender);
        ourToken.transfer(alice, transferAmount); // Assuming the deployer can do this based on `test/OurTokenTest.t.sol`
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testBobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmountPhind = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmountPhind);

        // assertEq(ourToken.balanceOf(alice), transferAmountPhind);
        assertEq(ourToken.balanceOf(alice), transferAmount + transferAmountPhind); // update for Codeium
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmountPhind);
    }

    /////////////////////////////////////////////////////////
    // Phind Web: no vm.prank() + strange {from} syntax
    /////////////////////////////////////////////////////////
    function testAllowancePhindWeb() public {
        uint256 initialAllowance = ourToken.allowance(bob, alice);
        assertEq(initialAllowance, 0, "Initial allowance should be 0");

        // ourToken.approve(alice, 500, {from: bob}); // ???
        vm.prank(bob);
        ourToken.approve(alice, 500);
        uint256 updatedAllowance = ourToken.allowance(bob, alice);
        assertEq(updatedAllowance, 500, "Allowance should be updated");
    }

    function testTransferPhindWeb() public {
        uint256 initialBalanceUser1 = ourToken.balanceOf(bob);
        uint256 initialBalanceUser2 = ourToken.balanceOf(alice);

        // ourToken.transfer(alice, 200, {from: bob}); // ???
        vm.prank(bob);
        ourToken.transfer(alice, 200);

        uint256 finalBalanceUser1 = ourToken.balanceOf(bob);
        uint256 finalBalanceUser2 = ourToken.balanceOf(alice);

        assertEq(finalBalanceUser1, initialBalanceUser1 - 200, "Bob's balance should decrease");
        assertEq(finalBalanceUser2, initialBalanceUser2 + 200, "Alice's balance should increase");
    }

    function testTransferFromPhindWeb() public {
        // ourToken.approve(alice, 300, {from: bob}); // ???
        vm.prank(bob);
        ourToken.approve(alice, 300);
        uint256 initialBalanceUser1 = ourToken.balanceOf(bob);
        uint256 initialBalanceUser2 = ourToken.balanceOf(alice);

        // ourToken.transferFrom(user1, user2, 100, {from: user2}); // ???
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, 100);

        uint256 finalBalanceUser1 = ourToken.balanceOf(bob);
        uint256 finalBalanceUser2 = ourToken.balanceOf(alice);

        assertEq(finalBalanceUser1, initialBalanceUser1 - 100, "Bob's balance should decrease");
        assertEq(finalBalanceUser2, initialBalanceUser2 + 100, "Alice's balance should increase");
    }

    /////////////////////////////////////////////////////////
    // Phind extension with context: no vm.prank()
    /////////////////////////////////////////////////////////
    // Test for setting allowances
    function testSetAllowancePhindExt() public {
        uint256 amount = 50 ether;
        // vm.prank(bob);
        vm.prank(msg.sender);
        ourToken.approve(alice, amount);
        assertEq(ourToken.allowance(msg.sender, alice), amount); // ???
        // assertEq(ourToken.allowance(bob, alice), amount);
    }

    // Test for transferring tokens
    function testTransferPhindExt() public {
        uint256 amount = 10 ether;
        // vm.prank(bob);
        vm.prank(msg.sender);
        ourToken.transfer(alice, amount);
        // assertEq(ourToken.balanceOf(alice), amount);
        assertEq(ourToken.balanceOf(alice), transferAmount + amount);  // update for Codeium
    }

    // Test for checking allowances
    function testCheckAllowancePhindExt() public {
        uint256 amount = 50 ether;
        // vm.prank(bob);
        vm.prank(msg.sender);
        ourToken.approve(alice, amount);
        assertEq(ourToken.allowance(msg.sender, alice), amount); // ???
        // assertEq(ourToken.allowance(bob, alice), amount);
    }

    // Test for transferring from another address
    function testTransferFromPhindExt() public {
        uint256 amount = 20 ether;
        // vm.prank(bob);
        vm.prank(msg.sender);
        ourToken.approve(alice, amount);
        vm.prank(alice);
        ourToken.transferFrom(msg.sender, bob, amount); // ???
        // ourToken.transferFrom(bob, alice, amount);
        // assertEq(ourToken.balanceOf(alice), amount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE + amount);
        // assertEq(ourToken.balanceOf(alice), transferAmount + amount);  // update for Codeium
    }

    // Test for checking allowance after transferFrom
    function testAllowanceAfterTransferFromPhindExt() public {
        uint256 amount = 20 ether;
        // vm.prank(bob);
        vm.prank(msg.sender);
        ourToken.approve(alice, amount);
        vm.prank(alice);
        ourToken.transferFrom(msg.sender, bob, amount); // ???
        assertEq(ourToken.allowance(msg.sender, alice), amount - 20 ether); // ???
        // ourToken.transferFrom(bob, alice, amount);
        // assertEq(ourToken.allowance(bob, alice), amount - 50 ether);
    }

    /////////////////////////////////////////////////////////
    // Codeium extension with GPT-4
    /////////////////////////////////////////////////////////
    function testApproveAndAllowanceCodeium() public {
        uint256 allowance = 100 * 10 ** 18;
        vm.prank(alice);
        ourToken.approve(bob, allowance);

        assertEq(ourToken.allowance(alice, bob), allowance);
    }

    // Mixed up Bob and Alice + insufficient balance
    function testTransferFromCodeium() public {
        uint256 allowance = 100 * 10 ** 18;
        vm.prank(alice);
        ourToken.approve(bob, allowance);

        uint256 bobBalanceBefore = ourToken.balanceOf(bob);

        vm.prank(bob);
        ourToken.transferFrom(alice, bob, transferAmount);

        assertEq(ourToken.balanceOf(bob), bobBalanceBefore + transferAmount);
        assertEq(ourToken.allowance(alice, bob), allowance - transferAmount);
    }

    function testCannotTransferFromWithoutAllowanceCodeium() public {
        vm.expectRevert();
        vm.prank(bob);
        ourToken.transferFrom(alice, bob, transferAmount);
    }

    function testCannotTransferMoreThanBalanceCodeium() public {
        uint256 balance = ourToken.balanceOf(alice);
        uint256 amountToTransfer = balance + 1; // One more than the available balance

        vm.expectRevert();
        vm.prank(alice);
        ourToken.transfer(bob, amountToTransfer);
    }
}
