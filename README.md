A transparent, tamper-proof voting and result verification system built on Stacks blockchain using Clarity smart contracts.

## 🌟 Features

- 🆔 **Unique Voter Tokenization** - Secure voter registration with unique token IDs
- ✅ **Wallet-Based Voting** - Cast votes using cryptographic signatures
- 📊 **Real-Time Auditing** - Live vote counting and transparent results
- 🔍 **Vote Verification** - Zero-knowledge proof integration for anonymity
- 🏛️ **DAO Governance** - Post-election proposal system for community decisions
- ⏰ **Election Extension** - Flexible election duration with controlled extensions

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed
- Stacks wallet for testing

### 📥 Installation

```bash
git clone <repository-url>
cd decentralized-election-voting-system
clarinet console
```

## 📋 Usage Guide

### 1️⃣ Voter Registration

Register as a verified voter to participate in elections:

```clarity
(contract-call? .election-system register-voter)
```

### 2️⃣ Create Election

Start a new election with candidates and duration:

```clarity
(contract-call? .election-system create-election 
  "Presidential Election 2024" 
  (list "Alice" "Bob" "Charlie") 
  u1000)  ;; Duration in blocks
```

### 3️⃣ Cast Vote

Vote for your preferred candidate:

```clarity
(contract-call? .election-system cast-vote u1 "Alice")
```

### 4️⃣ View Results

Check election results and winner:

```clarity
(contract-call? .election-system get-election-results u1 "Alice")
(contract-call? .election-system get-election-winner u1)
```

### 5️⃣ Create Proposal

Submit post-election governance proposals:

```clarity
(contract-call? .election-system create-proposal 
  "Increase Voter Turnout" 
  "Implement incentives for voting participation" 
  u1 
  u500)  ;; Duration in blocks
```

### 6️⃣ Vote on Proposals

Participate in DAO governance:

```clarity
(contract-call? .election-system vote-proposal u1 true)  ;; true = yes, false = no
```

### 7️⃣ Extend Election

Extend an active election if needed (up to 3 extensions allowed):

```clarity
(contract-call? .election-system extend-election u1 u500)  ;; Extend election 1 by 500 blocks
```

## 🔧 Available Functions

### 📝 Public Functions

| Function | Description |
|----------|-------------|
| `register-voter` | Register as a verified voter |
| `create-election` | Create new election with candidates |
| `cast-vote` | Cast vote for a candidate |
| `end-election` | End an active election |
| `create-proposal` | Create governance proposal |
| `vote-proposal` | Vote on governance proposal |
| `finalize-proposal` | Finalize proposal voting |
| `extend-election` | Extend active election duration |

### 👀 Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-election` | Get election details |
| `get-election-results` | Get vote count for candidate |
| `get-all-election-results` | Get aggregated vote counts for all candidates in an election |
| `get-voter-info` | Get voter registration info |
| `get-vote-proof` | Get cryptographic vote proof |
| `verify-vote-integrity` | Verify vote authenticity |
| `get-election-winner` | Get election winner |
| `get-election-extensions` | Get number of extensions for an election |

## 🛡️ Security Features

- 🔐 **Cryptographic Vote Hashing** - Each vote generates a unique hash for verification
- 🚫 **Double-Voting Prevention** - Smart contract prevents multiple votes per election
- ⏰ **Time-Bound Elections** - Elections have defined start and end blocks with extension capabilities
- 👤 **Identity Verification** - Only registered voters can participate
- 🔍 **Transparent Auditing** - All votes and results are publicly verifiable

## 🧪 Testing

Run the test suite:

```bash
clarinet test
```

## 📊 Example Workflow

1. **Setup Phase** 🛠️
   - Deploy contract
   - Register voters

2. **Election Phase** 🗳️
   - Create election
   - Voters cast ballots
   - Monitor real-time results

3. **Verification Phase** ✅
   - Verify vote integrity
   - Audit election results
   - Declare winner

4. **Governance Phase** 🏛️
    - Create proposals
    - Community voting
    - Implement decisions

5. **Extension Phase** ⏰ (Optional)
    - Extend election duration if needed
    - Maximum 3 extensions per election
    - Maintain voting integrity

## 🔗 Contract Architecture

```
Election System
├── Voter Registration
├── Election Management
│   ├── Creation & Configuration
│   ├── Duration Management
│   └── Extension Controls
├── Vote Casting & Verification
├── Result Tabulation
└── DAO Governance
```

## 📈 Benefits

- 🌍 **Transparency** - All actions recorded on blockchain
- 🔒 **Security** - Cryptographic protection against fraud
- ⚡ **Efficiency** - Automated counting and verification
- 🌐 **Accessibility** - Global participation capability
- 💰 **Cost-Effective** - Reduced election administration costs

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

For questions or issues, please open a GitHub issue or contact the development team.

---

*Built with ❤️ using Clarity and Stacks blockchain*
