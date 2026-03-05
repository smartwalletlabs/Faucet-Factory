# Faucet Factory — Smart Contracts

> Modular smart account infrastructure for policy-driven testnet token distribution, built on ERC-4337 and ERC-6900.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../../LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.28-363636)](https://soliditylang.org/)
[![Built with Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C)](https://book.getfoundry.sh/)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Contracts](#contracts)
- [User Flows](#user-flows)
- [Development](#development)
- [Status](#status)

---

## Overview

This package contains the core smart contracts for Faucet Factory — a system that enables teams to deploy their own modular smart account as a **programmable faucet vault**.

Each team account supports:

- **Modular validation** — install and swap policy modules (rate limits, eligibility checks, quotas) without redeploying
- **Gas-sponsored UX** — users only sign; gas is covered via paymaster integration
- **Two distribution models** — pull (user-initiated) and push (team-initiated batch)

* Modular execution would be available in the next version

### Key Design Decisions

| Decision | Rationale |
|---|---|
| ERC-6900 modular account standard | Composable validation/execution via installable modules |
| ERC-7201 namespaced storage | Collision-safe storage for modules and account state |
| ERC-1967 minimal proxies (via Solady) | Gas-efficient deterministic deployment per team |
| ERC-4337 `IAccount` compliance | Native account abstraction support via EntryPoint |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   AccountFactory                     │
│  Deploys deterministic ERC-1967 proxies per team     │
└──────────────────────┬──────────────────────────────┘
                       │ creates
                       ▼
┌─────────────────────────────────────────────────────┐
│                  ModularAccount                      │
│  Team-owned account instance (proxy)                 │
│  - owner, ENTRY_POINT                               │
│  - initialize(owner)                                 │
└──────────────────────┬──────────────────────────────┘
                       │ inherits
                       ▼
┌─────────────────────────────────────────────────────┐
│               ModularAccountBase                     │
│  Core ERC-4337 logic                                 │
│  - validateUserOp → _validateUserOp                  │
│  - missingAccountFunds prefunding                    │
└──────────────────────┬──────────────────────────────┘
                       │ uses
                       ▼
┌─────────────────────────────────────────────────────┐
│               AccountStorage                         │
│  ERC-7201 namespaced storage layout                  │
│  - ValidationStorage (module per lookup key)         │
│  - ExecutionStorage (module per selector)            │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                IModule (interface)                    │
│  - onInstall(data) / onUninstall(data)               │
│  - moduleId()                                        │
│  - ERC-165 supportsInterface                         │
└─────────────────────────────────────────────────────┘
```

---

## Contracts

### `src/factory/AccountFactory.sol`

Factory contract for deploying team faucet accounts.

- Deploys deterministic ERC-1967 proxies via [Solady `LibClone`](https://github.com/Vectorized/solady)
- Initializes each account with the team owner address
- Provides `getAddress()` for counterfactual address computation

### `src/ModularAccount.sol`

The concrete account contract deployed per team.

- Stores the immutable `ENTRY_POINT` reference and `owner`
- Inherits all validation and execution logic from `ModularAccountBase`
- Acts as the ERC-1967 implementation behind each proxy

### `src/ModularAccountBase.sol`

Abstract base containing the core ERC-4337 account logic.

- Implements `IAccount.validateUserOp` with EntryPoint prefunding
- Delegates to `_validateUserOp` for modular validation (🚧 WIP)
- Designed to be extended with hook and module dispatch logic

### `src/AccountStorage.sol`

ERC-7201 namespaced storage layout for collision-safe module state.

- `ValidationStorage` — maps validation lookup keys → module addresses
- `ExecutionStorage` — maps function selectors → module addresses
- `getAccountStorage()` — returns the storage pointer via assembly

### `src/interfaces/IModule.sol`

Interface all modules must implement.

- `onInstall(data)` — called when a module is installed on an account
- `onUninstall(data)` — called when a module is removed
- `moduleId()` — returns a unique string identifier
- Extends `IERC-165` for interface detection

---

## User Flows

### For Teams

```
1. Factory deploys a modular account (deterministic proxy)
2. Team installs policy modules (rate limits, eligibility, quotas)
3. Team integrates via SDK or links the hosted claim page
```

### For Users (Pull Model) 

```
1. User signs a message / submits a UserOp
2. Pre-validation hooks validate the request (eligibility, rate limits)
3. EntryPoint calls execute → funds are sent to the user
4. Gas is sponsored via paymaster — user pays nothing
```
* Push Model isnt available in this version
---

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [pnpm](https://pnpm.io/)

### Commands

```bash
# Build contracts
pnpm build

# Run tests
pnpm test

# Run tests with verbose output
pnpm test:verbose

# Format Solidity
pnpm fmt

# Check formatting
pnpm fmt:check

# Clean build artifacts
pnpm clean
```

### Dependencies

| Dependency | Purpose |
|---|---|
| [`eth-infinitism/account-abstraction`](https://github.com/eth-infinitism/account-abstraction) | ERC-4337 EntryPoint and interfaces |
| [`OpenZeppelin/openzeppelin-contracts`](https://github.com/OpenZeppelin/openzeppelin-contracts) | `Initializable`, `IERC165`, and utilities |
| [`foundry-rs/forge-std`](https://github.com/foundry-rs/forge-std) | Foundry testing framework |

---

## Status

> ⚠️ **This project is under active development.** The contracts are not audited and are not ready for production use.

### MVP v0.1 Roadmap

- [x] Account storage layout (ERC-7201)
- [x] Module interface (`IModule`)
- [x] Factory with deterministic deployment
- [x] Base account with `validateUserOp`
- [ ] Module install/uninstall logic on account
- [ ] Validation module dispatch (pre-validation hooks)
- [ ] Pull distribution flow (user-initiated claims)
- [ ] Rate limit module
- [ ] Eligibility / quota module
- [ ] Paymaster integration
- [ ] Comprehensive test suite

---

## License

[MIT](../../LICENSE)