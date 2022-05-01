//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "./ERC721Handler.sol";

contract SnowBridge {
    uint256 public _expiry;
    uint8 public _domainId;
    uint256 public _relayerThreshold;
    address[] public _relayers;
    address public _owner;
    ERC721Handler _handler;
    mapping(address => bool) _isRelayerMap;
    mapping(bytes32 => Proposal) _proposals;
    mapping(bytes32 => mapping(address => bool)) _hasVoted;

    enum ProposalStatus {
        Inactive,
        Active,
        Passed,
        Executed,
        Cancelled
    }

    event ProposalEvent(ProposalStatus, bytes32);
    event ProposalVote(ProposalStatus, bytes32);

    struct Proposal {
        ProposalStatus _status;
        uint8 _yesVotesTotal;
        uint256 _proposedBlock;
    }

    constructor(
        uint8 domainID,
        address[] memory initialRelayers,
        uint256 initialRelayerThreshold,
        address handler,
        uint256 expiry,
        address owner
    ) {
        _handler = ERC721Handler(handler);
        _domainId = domainID;
        _relayerThreshold = initialRelayerThreshold;
        _expiry = expiry;
        _owner = owner;

        _relayers = initialRelayers;
        for (uint256 i = 0; i < _relayers.length; i++) {
            _isRelayerMap[_relayers[i]] = true;
        }
    }

    function getProposal(bytes32 dataHash)
        public
        view
        returns (Proposal memory)
    {
        Proposal memory proposal = _proposals[dataHash];
        return proposal;
    }

    function executeProposal(
        address userAddress,
        string memory key,
        bytes32 dataHash
    ) public {
        require(_isRelayerMap[msg.sender] == true, "not a valid relayer");
        Proposal memory proposal = _proposals[dataHash];
        require(
            proposal._status == ProposalStatus.Passed,
            "Proposal must have Passed status"
        );
        _handler.executeProposal(userAddress, key);
        proposal._status = ProposalStatus.Executed;
    }

    function voteProposal(address userAddress, string memory key) public {
        require(_isRelayerMap[msg.sender] == true, "not a valid relayer");
        bytes32 dataHash = keccak256(abi.encodePacked(userAddress, key));
        Proposal memory proposal = _proposals[dataHash];

        if (proposal._status == ProposalStatus.Passed) {
            executeProposal(userAddress, key, dataHash);
            return;
        }

        require(
            uint256(proposal._status) <= 1,
            "proposal already executed/cancelled"
        );

        _hasVoted[dataHash][msg.sender] = true;
        if (proposal._status == ProposalStatus.Inactive) {
            proposal = Proposal({
                _status: ProposalStatus.Active,
                _yesVotesTotal: 0,
                _proposedBlock: block.number // Overflow is desired.
            });

            emit ProposalEvent(ProposalStatus.Active, dataHash);
        } else if (block.number - proposal._proposedBlock > _expiry) {
            proposal._status = ProposalStatus.Cancelled;

            emit ProposalEvent(ProposalStatus.Cancelled, dataHash);
        }

        if (proposal._status != ProposalStatus.Cancelled) {
            proposal._yesVotesTotal++;

            emit ProposalVote(proposal._status, dataHash);

            if (proposal._yesVotesTotal >= _relayerThreshold) {
                proposal._status = ProposalStatus.Passed;
                emit ProposalEvent(ProposalStatus.Passed, dataHash);
            }
        }
        _proposals[dataHash] = proposal;

        if (proposal._status == ProposalStatus.Passed) {
            executeProposal(userAddress, key, dataHash);
        }
    }

    function hasVotedOnProposal(bytes32 dataHash, address relayer)
        public
        returns (bool)
    {
        return _hasVoted[dataHash][relayer] == true;
    }

    function cancelProposal(bytes32 dataHash) public {
        require(_isRelayerMap[msg.sender] == true, "not a valid relayer");
        Proposal memory proposal = _proposals[dataHash];
        ProposalStatus currentStatus = proposal._status;

        require(
            currentStatus == ProposalStatus.Active ||
                currentStatus == ProposalStatus.Passed,
            "Proposal cannot be cancelled"
        );
        require(
            (block.number - proposal._proposedBlock) > _expiry,
            "Proposal not at expiry threshold"
        );

        proposal._status = ProposalStatus.Cancelled;
        _proposals[dataHash] = proposal;

        emit ProposalEvent(ProposalStatus.Cancelled, dataHash);
    }
}
