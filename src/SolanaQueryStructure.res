// Solana HyperSync data model
// Schema differs from EVM: uses from_slot/to_slot, "fields" instead of "field_selection",
// no join_mode (joins are per-selection via include_* booleans), and 7 response tables.

// Selection (filter) types

type instructionSelection = {
  programId: option<array<string>>,
  d1: option<array<string>>,
  d2: option<array<string>>,
  d4: option<array<string>>,
  d8: option<array<string>>,
  a0: option<array<string>>,
  a1: option<array<string>>,
  a2: option<array<string>>,
  a3: option<array<string>>,
  a4: option<array<string>>,
  a5: option<array<string>>,
  a6: option<array<string>>,
  a7: option<array<string>>,
  a8: option<array<string>>,
  a9: option<array<string>>,
  isInner: option<bool>,
  includeTransaction: bool,
  includeLogs: bool,
}

let emptyInstructionSelection: instructionSelection = {
  programId: None,
  d1: None,
  d2: None,
  d4: None,
  d8: None,
  a0: None,
  a1: None,
  a2: None,
  a3: None,
  a4: None,
  a5: None,
  a6: None,
  a7: None,
  a8: None,
  a9: None,
  isInner: None,
  includeTransaction: false,
  includeLogs: false,
}

type transactionSelection = {
  feePayer: option<array<string>>,
  success: option<bool>,
  includeInstructions: bool,
}

let emptyTransactionSelection: transactionSelection = {
  feePayer: None,
  success: None,
  includeInstructions: false,
}

type logSelection = {
  programId: option<array<string>>,
  kind: option<array<string>>,
  includeTransaction: bool,
  includeInstruction: bool,
}

let emptyLogSelection: logSelection = {
  programId: None,
  kind: None,
  includeTransaction: false,
  includeInstruction: false,
}

// Field selection enums (snake_case wire names via @as)

type blockField =
  | @as("slot") Slot
  | @as("blockhash") Blockhash
  | @as("parent_slot") ParentSlot
  | @as("parent_blockhash") ParentBlockhash
  | @as("block_time") BlockTime
  | @as("block_height") BlockHeight

let allBlockFields: array<blockField> = [
  Slot,
  Blockhash,
  ParentSlot,
  ParentBlockhash,
  BlockTime,
  BlockHeight,
]

type transactionField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("signatures") Signatures
  | @as("fee_payer") FeePayer
  | @as("success") Success
  | @as("err") Err
  | @as("fee") Fee
  | @as("compute_units_consumed") ComputeUnitsConsumed
  | @as("account_keys") AccountKeys
  | @as("recent_blockhash") RecentBlockhash
  | @as("version") Version
  | @as("loaded_addresses_writable") LoadedAddressesWritable
  | @as("loaded_addresses_readonly") LoadedAddressesReadonly

let allTransactionFields: array<transactionField> = [
  Slot,
  TransactionIndex,
  Signatures,
  FeePayer,
  Success,
  Err,
  Fee,
  ComputeUnitsConsumed,
  AccountKeys,
  RecentBlockhash,
  Version,
  LoadedAddressesWritable,
  LoadedAddressesReadonly,
]

type instructionField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("instruction_address") InstructionAddress
  | @as("program_id") ProgramId
  | @as("accounts") Accounts
  | @as("data") Data
  | @as("d1") D1
  | @as("d2") D2
  | @as("d4") D4
  | @as("d8") D8
  | @as("a0") A0
  | @as("a1") A1
  | @as("a2") A2
  | @as("a3") A3
  | @as("a4") A4
  | @as("a5") A5
  | @as("a6") A6
  | @as("a7") A7
  | @as("a8") A8
  | @as("a9") A9
  | @as("is_inner") IsInner
  | @as("is_committed") IsCommitted

let allInstructionFields: array<instructionField> = [
  Slot,
  TransactionIndex,
  InstructionAddress,
  ProgramId,
  Accounts,
  Data,
  D1,
  D2,
  D4,
  D8,
  A0,
  A1,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  A8,
  A9,
  IsInner,
  IsCommitted,
]

type logField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("instruction_address") InstructionAddress
  | @as("program_id") ProgramId
  | @as("kind") Kind
  | @as("message") Message

let allLogFields: array<logField> = [
  Slot,
  TransactionIndex,
  InstructionAddress,
  ProgramId,
  Kind,
  Message,
]

type balanceField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("account") Account
  | @as("pre") Pre
  | @as("post") Post

let allBalanceFields: array<balanceField> = [Slot, TransactionIndex, Account, Pre, Post]

type tokenBalanceField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("account") Account
  | @as("mint") Mint
  | @as("owner") Owner
  | @as("pre_amount") PreAmount
  | @as("post_amount") PostAmount

let allTokenBalanceFields: array<tokenBalanceField> = [
  Slot,
  TransactionIndex,
  Account,
  Mint,
  Owner,
  PreAmount,
  PostAmount,
]

type rewardField =
  | @as("slot") Slot
  | @as("pubkey") Pubkey
  | @as("lamports") Lamports
  | @as("post_balance") PostBalance
  | @as("reward_type") RewardType
  | @as("commission") Commission

let allRewardFields: array<rewardField> = [
  Slot,
  Pubkey,
  Lamports,
  PostBalance,
  RewardType,
  Commission,
]

type fieldSelection = {
  block: array<blockField>,
  transaction: array<transactionField>,
  instruction: array<instructionField>,
  log: array<logField>,
  balance: array<balanceField>,
  tokenBalance: array<tokenBalanceField>,
  reward: array<rewardField>,
}

let emptyFieldSelection: fieldSelection = {
  block: [],
  transaction: [],
  instruction: [],
  log: [],
  balance: [],
  tokenBalance: [],
  reward: [],
}

type query = {
  fromSlot: int,
  toSlot: option<int>,
  instructions: option<array<instructionSelection>>,
  transactions: option<array<transactionSelection>>,
  logs: option<array<logSelection>>,
  includeAllBlocks: option<bool>,
  fields: fieldSelection,
  maxNumBlocks: option<int>,
  maxNumTransactions: option<int>,
  maxNumInstructions: option<int>,
  maxNumLogs: option<int>,
}

// Snake-case stringifiers (relies on @as mapping; Obj.magic returns the wire string)
let blockFieldToSnake = (f: blockField): string => Obj.magic(f)
let transactionFieldToSnake = (f: transactionField): string => Obj.magic(f)
let instructionFieldToSnake = (f: instructionField): string => Obj.magic(f)
let logFieldToSnake = (f: logField): string => Obj.magic(f)
let balanceFieldToSnake = (f: balanceField): string => Obj.magic(f)
let tokenBalanceFieldToSnake = (f: tokenBalanceField): string => Obj.magic(f)
let rewardFieldToSnake = (f: rewardField): string => Obj.magic(f)

let snakeToTitle = (input: string): string =>
  Js.String.split("_", input)
  ->Belt.Array.keep(s => s != "")
  ->Belt.Array.map(s =>
    String.toUpperCase(Js.String.slice(~from=0, ~to_=1, s)) ++
    Js.String.slice(~from=1, ~to_=String.length(s), s)
  )
  ->Array.join(" ")
