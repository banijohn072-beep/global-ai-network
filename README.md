# Global AI Network - Decentralized AI Marketplace

A Clarity smart contract implementation for a decentralized AI marketplace on the Stacks blockchain, enabling AI model registration, computation task management, and reward distribution.

## 🌟 Overview

The Global AI Network is a decentralized platform that connects AI model providers with users who need AI computations. It creates a trustless marketplace where:

- **AI Providers** can register their models and earn rewards for computations
- **Users** can request AI computations and pay for services
- **The Platform** maintains quality through reputation systems and fair fee distribution

## 🏗️ Architecture

### Core Components

1. **AI Model Registry**: Store and manage AI model metadata
2. **Task Management**: Handle computation requests and assignments
3. **Reward System**: Distribute payments and maintain reputation scores
4. **Admin Functions**: Platform governance and fee management

### Key Features

- ✅ **Decentralized AI Model Marketplace**
- ✅ **Trustless Computation Task Management**
- ✅ **Reputation-based Provider Scoring**
- ✅ **Escrow-based Payment System**
- ✅ **Platform Fee Management**
- ✅ **Multi-category Model Support**

## 📋 Smart Contract Functions

### Public Functions

#### Model Management
- `register-ai-model` - Register a new AI model
- `update-model-status` - Activate/deactivate models

#### Task Management
- `create-computation-task` - Request AI computation
- `assign-task` - Assign task to model provider
- `complete-task` - Submit computation results

#### Financial Operations
- `deposit-funds` - Add funds to user balance
- `withdraw-funds` - Withdraw available funds

#### Admin Functions
- `update-platform-fee` - Update platform fee percentage
- `withdraw-platform-fees` - Withdraw collected fees

### Read-Only Functions

- `get-model` - Retrieve model information
- `get-task` - Get task details
- `get-user-balance` - Check user balance
- `get-user-reputation` - View reputation score
- `get-user-models` - List user's registered models

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v16+
- Basic understanding of Clarity language

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/global-ai-network.git
cd global-ai-network
```

2. Initialize Clarinet project (if not already done):
```bash
clarinet new global-ai-network
```

3. Add the contract to your `Clarinet.toml`:
```toml
[contracts.global-ai-network]
path = "contracts/global-ai-network.clar"
```

### Local Development

1. Check contract syntax:
```bash
clarinet check
```

2. Run tests:
```bash
clarinet test
```

3. Open Clarinet console for interactive testing:
```bash
clarinet console
```

## 💡 Usage Examples

### Register an AI Model

```clarity
(contract-call? .global-ai-network register-ai-model 
    "Image Classification Model" 
    "Advanced CNN for image recognition with 95% accuracy"
    "Computer Vision"
    u1000)
```

### Create a Computation Task

```clarity
;; First deposit funds
(contract-call? .global-ai-network deposit-funds u5000)

;; Create task
(contract-call? .global-ai-network create-computation-task 
    u1 
    "sha256hashofyourinputdata..." 
    u2000)
```

### Complete a Task (as model owner)

```clarity
(contract-call? .global-ai-network assign-task u1)
(contract-call? .global-ai-network complete-task 
    u1 
    "sha256hashofoutputresults...")
```

## 📊 Data Structures

### AI Model
```clarity
{
    owner: principal,
    name: (string-ascii 50),
    description: (string-ascii 200),
    category: (string-ascii 30),
    price-per-computation: uint,
    total-computations: uint,
    reputation-score: uint,
    is-active: bool,
    created-at: uint
}
```

### Computation Task
```clarity
{
    requester: principal,
    model-id: uint,
    input-data-hash: (string-ascii 64),
    output-data-hash: (optional (string-ascii 64)),
    reward-amount: uint,
    status: (string-ascii 20),
    assigned-provider: (optional principal),
    created-at: uint,
    completed-at: (optional uint)
}
```

## 🔐 Security Features

- **Access Control**: Function-level authorization checks
- **Input Validation**: Comprehensive parameter validation
- **Error Handling**: Detailed error codes and messages
- **Escrow System**: Funds held in contract until task completion
- **Reputation System**: Quality control through provider scoring

## 💰 Economic Model

### Fee Structure
- Default platform fee: **5%** (configurable by admin)
- Maximum platform fee: **20%** (hard-coded limit)
- Fees collected from completed computations

### Reward Distribution
1. User pays reward amount (held in escrow)
2. Provider completes computation
3. Platform fee deducted from reward
4. Remaining amount paid to provider
5. Provider reputation increased

## 🧪 Testing

### Test Categories

1. **Model Registration Tests**
   - Valid model registration
   - Invalid input handling
   - Authorization checks

2. **Task Management Tests**
   - Task creation and assignment
   - Status transitions
   - Completion workflow

3. **Financial Tests**
   - Balance management
   - Fee calculations
   - Escrow operations

### Running Tests

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/global-ai-network_test.ts
```

## 🛣️ Roadmap

### Phase 1: MVP (Current)
- ✅ Basic model registration
- ✅ Simple task management
- ✅ Payment system
- ✅ Reputation tracking

### Phase 2: Enhancement
- [ ] Multi-token support (SIP-010)
- [ ] Dispute resolution system
- [ ] Advanced reputation algorithms
- [ ] Model categorization and search

### Phase 3: Advanced Features
- [ ] Staking mechanisms
- [ ] Governance token integration
- [ ] Cross-chain compatibility
- [ ] AI model versioning

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Stacks Foundation for the Clarity language
- Hiro Systems for development tools
- The decentralized AI community for inspiration

## 📞 Support

- **Documentation**: [Clarity Language Reference](https://docs.stacks.co/clarity/)
- **Issues**: [GitHub Issues](https://github.com/your-username/global-ai-network/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/global-ai-network/discussions)

---

**Built with ❤️ for the decentralized future of AI**