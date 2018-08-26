const StableToken = artifacts.require("StableToken");

contract('StableToken test', async (accounts) => {

    let owner = accounts[0];
    let admin1 = accounts[1];
    let admin2 = accounts[2];
    let admin3 = accounts[3];
    let recipient1 = accounts[4];
    let recipient2 = accounts[5];

    let tokenInstance;

    let _tmpProposalHash;

    before(async () => {
        tokenInstance = await StableToken.new.apply(this);
    });

    // ---=== FIRST ADMIN ===---

    it("should check initial params", async () => {
        let owner = await tokenInstance.owner();
        let name = await tokenInstance.name();
        let symbol = await tokenInstance.symbol();
        let decimals = await tokenInstance.decimals();

        let totalSupply = await tokenInstance.totalSupply();

        let minimumQuorum = await tokenInstance.minimumQuorum();
        let numAdmins = await tokenInstance.numAdmins();
        let numProposals = await tokenInstance.numProposals();

        assert.equal(owner, owner);
        assert.equal(name, "Stable token");
        assert.equal(symbol, "STT");
        assert.equal(decimals, 18);
        assert.equal(totalSupply, 0);
        assert.equal(minimumQuorum, 1);
        assert.equal(numAdmins, 0);
        assert.equal(numProposals, 0);
    });

    it("should not mint token from non admin account", async () => {
        let error1;
        let error2;

        try {
            await tokenInstance.createMintProposal(recipient1, 1000, {from: admin1});
        } catch (e) {
            error1 = e;
        }

        try {
            let proposalHash = await tokenInstance.proposalsHash(0);
        } catch (e) {
            error2 = e;
        }

        let balanceRecipient = await tokenInstance.balanceOf(recipient1);

        assert.isDefined(error1);
        assert.isDefined(error2);
        assert.equal(balanceRecipient.valueOf(), 0);
    });

    it("should set first admin", async () => {
        await tokenInstance.addAdmin(admin1);

        let numAdmins = await tokenInstance.numAdmins();
        let adminAddress = await tokenInstance.adminsAddr(0);
        let adminObject = await tokenInstance.admins.call(admin1);

        assert.equal(numAdmins.valueOf(), 1);
        assert.equal(adminAddress, admin1);
        assert.equal(adminObject[0], admin1);
        assert.equal(adminObject[1], true);
        assert.equal(adminObject[2].valueOf(), 0);
    });

    it("should mint token with first admin for recipient", async () => {
        await tokenInstance.createMintProposal(recipient1, 1000, {from: admin1});

        let balanceRecipient = await tokenInstance.balanceOf(recipient1);
        assert.equal(balanceRecipient.valueOf(), 1000);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 1000);
    });

    it("should not burn tokens with zero admin balance", async () => {
        let error1;
        let error2;

        try {
            await tokenInstance.createBurnProposal(200, {from: admin1});
        } catch (e) {
            error1 = e;
        }

        try {
            let proposalHash = await tokenInstance.proposalsHash(0);
        } catch (e) {
            error2 = e;
        }

        assert.isDefined(error1);
        assert.isDefined(error1);
    });

    it("should mint token with first admin for admin", async () => {
        await tokenInstance.createMintProposal(admin1, 2000, {from: admin1});

        let balance = await tokenInstance.balanceOf(admin1);
        assert.equal(balance.valueOf(), 2000);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 3000);
    });

    it("should burn tokens from first admin", async () => {
        let error1;

        await tokenInstance.createBurnProposal(300, {from: admin1});

        try {
            let proposalHash = await tokenInstance.proposalsHash(0);
        } catch (e) {
            error1 = e;
        }
        let balance = await tokenInstance.balanceOf(admin1);

        assert.isDefined(error1);
        assert.equal(balance.valueOf(), 1700);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 2700);
    });

    it("should change voting rules", async () => {
        await tokenInstance.changeVotingRules(2);

        let minimumQuorum = await tokenInstance.minimumQuorum();
        assert.equal(minimumQuorum, 2);
    });

    it("should set second admin", async () => {
        await tokenInstance.addAdmin(admin2);

        let numAdmins = await tokenInstance.numAdmins();
        let adminAddress = await tokenInstance.adminsAddr(1);
        let adminObject = await tokenInstance.admins.call(admin2);

        assert.equal(numAdmins.valueOf(), 2);
        assert.equal(adminAddress, admin2);
        assert.equal(adminObject[0], admin2);
        assert.equal(adminObject[1], true);
        assert.equal(adminObject[2].valueOf(), 1);
    });

    it("should create proposal for mint from first admin", async () => {
        await tokenInstance.createMintProposal(recipient2, 500, {from: admin1});

        let balance = await tokenInstance.balanceOf(recipient2);
        assert.equal(balance.valueOf(), 0);

        let proposalHash = await tokenInstance.proposalsHash(0);

        let proposal = await tokenInstance.proposals(proposalHash);

        assert.equal(proposal[0].valueOf(), 0);
        assert.equal(proposal[2].valueOf(), 0);
        assert.equal(proposal[3], admin1);
        assert.equal(proposal[4], recipient2);
        assert.equal(proposal[5].valueOf(), 500);
        assert.equal(proposal[6], false);
        assert.equal(proposal[7].valueOf(), 1);

        let proposalVoteAddr = await tokenInstance.getProposalVotesAddr(proposalHash, 0);
        let proposalVoted = await tokenInstance.getProposalVoted(proposalHash, admin1);

        assert.equal(proposalVoteAddr, admin1);
        assert.equal(proposalVoted, true);
    });

    it("should not sign proposal for mint from first admin", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);

        let error1;

        try {
            await tokenInstance.signMintProposal(proposalHash, {from: admin1});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should not sign proposal for mint from non admin", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);

        let error1;

        try {
            await tokenInstance.signMintProposal(proposalHash, {from: recipient1});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should not sign as burn proposal for mint from second admin", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);

        let error1;

        try {
            await tokenInstance.signBurnProposal(proposalHash, {from: admin2});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should sign proposal from second admin and mint tokens", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);
        _tmpProposalHash = proposalHash;

        await tokenInstance.signMintProposal(proposalHash, {from: admin2});

        let proposal = await tokenInstance.proposals(proposalHash);

        assert.equal(proposal[0].valueOf(), 0);
        assert.equal(proposal[2].valueOf(), 0);
        assert.equal(proposal[3], admin1);
        assert.equal(proposal[4], recipient2);
        assert.equal(proposal[5].valueOf(), 500);
        assert.equal(proposal[6], true);
        assert.equal(proposal[7].valueOf(), 2);

        let proposalVoteAddr = await tokenInstance.getProposalVotesAddr(proposalHash, 1);
        let proposalVoted = await tokenInstance.getProposalVoted(proposalHash, admin2);

        assert.equal(proposalVoteAddr, admin2);
        assert.equal(proposalVoted, true);

        let balanceRecipient = await tokenInstance.balanceOf(recipient2);
        assert.equal(balanceRecipient.valueOf(), 500);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 3200);
    });

    it("should not sign proposal from second admin again", async () => {
        let error1;

        try {
            await tokenInstance.signMintProposal(_tmpProposalHash, {from: admin2});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should set third admin", async () => {
        await tokenInstance.addAdmin(admin3);

        let numAdmins = await tokenInstance.numAdmins();
        let adminAddress = await tokenInstance.adminsAddr(2);
        let adminObject = await tokenInstance.admins.call(admin3);

        assert.equal(numAdmins.valueOf(), 3);
        assert.equal(adminAddress, admin3);
        assert.equal(adminObject[0], admin3);
        assert.equal(adminObject[1], true);
        assert.equal(adminObject[2].valueOf(), 2);
    });

    it("should not sign proposal from third admin after proposal passed", async () => {
        let error1;

        try {
            await tokenInstance.signMintProposal(_tmpProposalHash, {from: admin3});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should create proposal for burn from first admin", async () => {
        await tokenInstance.createBurnProposal(400, {from: admin1});

        let balance = await tokenInstance.balanceOf(admin1);
        assert.equal(balance.valueOf(), 1700);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 3200);

        let proposalHash = await tokenInstance.proposalsHash(0);

        let proposal = await tokenInstance.proposals(proposalHash);

        assert.equal(proposal[0].valueOf(), 0);
        assert.equal(proposal[2].valueOf(), 1);
        assert.equal(proposal[3], admin1);
        assert.equal(proposal[4], admin1);
        assert.equal(proposal[5].valueOf(), 400);
        assert.equal(proposal[6], false);
        assert.equal(proposal[7].valueOf(), 1);

        let proposalVoteAddr = await tokenInstance.getProposalVotesAddr(proposalHash, 0);
        let proposalVoted = await tokenInstance.getProposalVoted(proposalHash, admin1);

        assert.equal(proposalVoteAddr, admin1);
        assert.equal(proposalVoted, true);
    });

    it("should not sign proposal for burn from first admin", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);
        let error1;

        try {
            await tokenInstance.signBurnProposal(proposalHash, {from: admin1});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should not sign proposal for burn from non admin", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);
        let error1;

        try {
            await tokenInstance.signBurnProposal(proposalHash, {from: recipient1});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should sign proposal from third admin and burn tokens", async () => {
        let proposalHash = await tokenInstance.proposalsHash(0);
        _tmpProposalHash = proposalHash;

        await tokenInstance.signBurnProposal(proposalHash, {from: admin3});

        let proposal = await tokenInstance.proposals(proposalHash);

        assert.equal(proposal[0].valueOf(), 0);
        assert.equal(proposal[2].valueOf(), 1);
        assert.equal(proposal[3], admin1);
        assert.equal(proposal[4], admin1);
        assert.equal(proposal[5].valueOf(), 400);
        assert.equal(proposal[6], true);
        assert.equal(proposal[7].valueOf(), 2);

        let proposalVoteAddr = await tokenInstance.getProposalVotesAddr(proposalHash, 1);
        let proposalVoted3 = await tokenInstance.getProposalVoted(proposalHash, admin3);
        let proposalVoted2 = await tokenInstance.getProposalVoted(proposalHash, admin2);

        assert.equal(proposalVoteAddr, admin3);
        assert.equal(proposalVoted3, true);
        assert.equal(proposalVoted2, false);

        let balance = await tokenInstance.balanceOf(admin1);
        assert.equal(balance.valueOf(), 1300);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 2800);
    });

    it("should not sign proposal from third admin again", async () => {
        let error1;

        try {
            await tokenInstance.signMintProposal(_tmpProposalHash, {from: admin3});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should not sign proposal from second admin after proposal passed", async () => {
        let error1;

        try {
            await tokenInstance.signMintProposal(_tmpProposalHash, {from: admin2});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should remove admin", async () => {
        await tokenInstance.removeAdmin(admin2);

        let numAdmins = await tokenInstance.numAdmins();
        assert.equal(numAdmins.valueOf(), 2);

        let error1;
        try {
            let adminAddress = await tokenInstance.adminsAddr(2);
        } catch (e) {
            error1 = e;
        }
        assert.isDefined(error1);

        let adminObject = await tokenInstance.admins.call(admin2);

        assert.equal(adminObject[0], admin2);
        assert.equal(adminObject[1], false);
        assert.equal(adminObject[2].valueOf(), 0);
    });

    it("should not create proposal from removed admin", async () => {
        let error1;

        try {
            await tokenInstance.createMintProposal(recipient1, 1000, {from: admin2});
            await tokenInstance.createBurnProposal(200, {from: admin2});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should not sign proposal from removed admin", async () => {
        await tokenInstance.createMintProposal(recipient1, 100, {from: admin1});

        let error1;
        let proposalHash = await tokenInstance.proposalsHash(0);

        try {
            await tokenInstance.signMintProposal(proposalHash, {from: admin2});
        } catch (e) {
            error1 = e;
        }

        assert.isDefined(error1);
    });

    it("should transfer tokens", async () => {
        await tokenInstance.transfer(recipient2, 200, {from: admin1});

        let balance1 = await tokenInstance.balanceOf(admin1);
        assert.equal(balance1.valueOf(), 1100);

        let balance2 = await tokenInstance.balanceOf(recipient2);
        assert.equal(balance2.valueOf(), 700);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 2800);
    });

    it("should transfer tokens", async () => {
        await tokenInstance.transfer(recipient1, 300, {from: recipient2});

        let balance1 = await tokenInstance.balanceOf(recipient1);
        assert.equal(balance1.valueOf(), 1300);

        let balance2 = await tokenInstance.balanceOf(recipient2);
        assert.equal(balance2.valueOf(), 400);

        let totalSupply = await tokenInstance.totalSupply();
        assert.equal(totalSupply, 2800);
    });

    // it("should send tokens", async () => {
    //     await tokenInstance.transfer(recipient, 1000);
    //     let balanceOwner = await tokenInstance.balanceOf(owner);
    //     let balanceRecipient = await tokenInstance.balanceOf(recipient);
    //
    //     assert.equal(balanceOwner.valueOf(), 9000);
    //     assert.equal(balanceRecipient.valueOf(), 1000);
    // });

    // it("should transfer 1000 tokens to the second account", async () => {
    //     await tokenInstance.transfer(recipient, 1000);
    //     let balanceOwner = await tokenInstance.balanceOf(owner);
    //     let balanceRecipient = await tokenInstance.balanceOf(recipient);
    //
    //     assert.equal(balanceOwner.valueOf(), 9000);
    //     assert.equal(balanceRecipient.valueOf(), 1000);
    // });

    // it("should send 1000 tokens to the safe box account", async () => {
    //     await tokenInstance.transfer(safeBoxInstance.address, 1000);
    //     let balanceOwner = await tokenInstance.balanceOf(owner);
    //     let balanceSafeBox = await tokenInstance.balanceOf(safeBoxInstance.address);
    //
    //     assert.equal(balanceOwner.valueOf(), 8000);
    //     assert.equal(balanceSafeBox.valueOf(), 1000);
    // });
    //
    // it("should not withdraw now", async () => {
    //     let error;
    //
    //     try {
    //         await safeBoxInstance.withdrawToken(tokenInstance.address);
    //     } catch (e) {
    //         error = e;
    //     }
    //
    //     let balanceRecipient = await tokenInstance.balanceOf(recipient);
    //
    //     assert.isDefined(error);
    //     assert.equal(balanceRecipient.valueOf(), 1000);
    // });
    //
    // it("should withdraw after " + SAFE_BOX_FREEZE_IN_SECONDS*1000 + "ms", async () => {
    //     await new Promise(resolve => setTimeout(resolve, SAFE_BOX_FREEZE_IN_SECONDS*1000));
    //
    //     let error;
    //
    //     try {
    //         await safeBoxInstance.withdrawToken(tokenInstance.address);
    //     } catch (e) {
    //         error = e;
    //     }
    //
    //     let balanceRecipient = await tokenInstance.balanceOf(recipient);
    //
    //     assert.isUndefined(error);
    //     assert.equal(balanceRecipient.valueOf(), 2000);
    // });
});