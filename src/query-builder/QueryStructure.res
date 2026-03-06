// Solana HyperSync Query Structure

// Selection types for Solana

type instructionSelection = {
  program_id: option<array<string>>,
  d1: option<array<string>>,
  d8: option<array<string>>,
  a0: option<array<string>>,
  is_inner: option<bool>,
}

type transactionSelection = {
  fee_payer: option<array<string>>,
  success: option<bool>,
}

type blockSelection = {
  // Solana blocks don't have meaningful filter fields beyond slot range
  // This is kept for structural compatibility
  placeholder: option<bool>,
}

// Field selection enums - Solana specific

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

type fieldSelection = {
  block: array<blockField>,
  transaction: array<transactionField>,
  instruction: array<instructionField>,
}

// Main Query type for Solana

type query = {
  fromSlot: int,
  toSlot: option<int>,
  instructions: option<array<instructionSelection>>,
  transactions: option<array<transactionSelection>>,
  includeAllBlocks: option<bool>,
  fieldSelection: fieldSelection,
  maxNumInstructions: option<int>,
  maxNumTransactions: option<int>,
  maxNumBlocks: option<int>,
}
