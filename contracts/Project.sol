// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    address public owner;
    string public electionName;
    bool public votingActive;
    uint256 public candidateCount;
    uint256 public totalVotes;
    
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    event CandidateAdded(uint256 candidateId, string name);
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint256 candidateId);
    event VotingStarted();
    event VotingEnded();
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not currently active");
        _;
    }
    
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingActive = false;
        candidateCount = 0;
        totalVotes = 0;
    }
    
    /**
     * @dev Add a new candidate to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner {
        require(!votingActive, "Cannot add candidates during active voting");
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Register a voter for the election
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) public onlyOwner {
        require(!voters[_voter].isRegistered, "Voter is already registered");
        require(_voter != address(0), "Invalid voter address");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public onlyRegisteredVoter votingIsActive {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Start the voting process
     */
    function startVoting() public onlyOwner {
        require(!votingActive, "Voting is already active");
        require(candidateCount > 0, "No candidates added yet");
        
        votingActive = true;
        emit VotingStarted();
    }
    
    /**
     * @dev End the voting process
     */
    function endVoting() public onlyOwner {
        require(votingActive, "Voting is not currently active");
        
        votingActive = false;
        emit VotingEnded();
    }
    
    /**
     * @dev Get candidate details
     * @param _candidateId ID of the candidate
     * @return id, name, voteCount
     */
    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get voter details
     * @param _voter Address of the voter
     * @return isRegistered, hasVoted, votedCandidateId
     */
    function getVoter(address _voter) public view returns (bool, bool, uint256) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    /**
     * @dev Get election results
     * @return Array of candidate IDs, names, and vote counts
     */
    function getResults() public view returns (uint256[] memory, string[] memory, uint256[] memory) {
        uint256[] memory ids = new uint256[](candidateCount);
        string[] memory names = new string[](candidateCount);
        uint256[] memory voteCounts = new uint256[](candidateCount);
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            ids[i-1] = candidates[i].id;
            names[i-1] = candidates[i].name;
            voteCounts[i-1] = candidates[i].voteCount;
        }
        
        return (ids, names, voteCounts);
    }
    
    /**
     * @dev Get the winning candidate
     * @return winnerId, winnerName, winnerVoteCount
     */
    function getWinner() public view returns (uint256, string memory, uint256) {
        require(candidateCount > 0, "No candidates in the election");
        
        uint256 winningVoteCount = 0;
        uint256 winnerId = 0;
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerId = i;
            }
        }
        
        require(winnerId > 0, "No winner found");
        return (winnerId, candidates[winnerId].name, winningVoteCount);
    }
}
