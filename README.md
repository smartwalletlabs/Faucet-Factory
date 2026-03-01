# Faucet-Factory
Modular Smart Account Infrastructure for Testnet Token Distribution

## Overview

Faucet Factory is a modular smart account based infrastructure that enables teams to distribute testnet tokens in a controlled, policy driven, and programmable manner.

Distribution supports:

* Push model
* Pull model

The system is built on top of:

* ERC-4337
* ERC-6900
* ERC-7579

It is designed as infra for teams, not a consumer wallet.

---

# Why This Exists

Testnet tokens are frequently abused.

Teams need:

* Distribution control
* Policy enforcement
* Rate limiting
* Monitoring
* Custom eligibility rules

Existing faucets are mostly:

* Static
* Hardcoded
* Non portable
* Not modular

Faucet Factory treats faucet logic as modular policy primitives attached to a smart account.

Each team gets its own modular account instance.

---

# Architectural Model

## Factory Layer

* Standard factory contract
* Uses CREATE2 for deterministic deployments
* Deploys modular smart accounts per team

Each deployed account represents a team controlled faucet vault.

---

## Account Layer

Each team account:

* Is ERC-4337 compatible
* Is upgradable
* Uses modular validation and execution
* Derives module patterns from Alchemy style modular accounts

Validation and execution are not hardcoded.

They are handled by modules.

---

# System Design

## 1. Pull Distribution Model

User initiates the flow.

Flow:

Sign message
→ getToken()
→ Validation module
→ Execution module
→ Token transfer

Validation module responsibilities:

* Check eligibility
* Enforce rate limits
* Enforce quota rules
* Read stored usage data

Execution module responsibilities:

* Transfer native token or ERC20
* Update state
* Emit monitoring events

Pull model requires:

* Persistent per user state
* Policy based validation logic
* Optional paymaster integration

UX goal:
User only signs. Gas sponsored via paymaster.

---

## 2. Push Distribution Model

Team curated list of recipients.

Flow:

Team signs
→ executeBatch()
→ Execution module
→ Batch distribution

Validation is minimal because:
Recipients are pre validated offchain or by the team.

Execution is the primary concern:

* Efficient batching
* Gas optimization
* Safe iteration
* Failure handling

---

# Policy System

Policies are implemented as modules.

Examples:

* Rate limit module
* One time claim module
* Developer tier quota module
* Auditor high allowance module
* Time window restriction module
* Monitoring and logging module

Modules become composable primitives.

Teams can install or remove policies without redeploying the account.

---

# User Classes and System Implications

1. Normal users
   Need small amounts. Rate limited.

2. Developers
   Need larger quotas. More frequent access.

3. Auditors and security engineers
   Need heavy usage capacity and flexible access.

Policy modules allow differentiation without rewriting core logic.

---

