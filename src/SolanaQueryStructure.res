// Solana HyperSync data model (wire API v0.2.0)
//
// Differences from EVM:
// - the range is from_slot / to_slot, not from_block / to_block
// - there is no join_mode, and there are no per-selection include_* booleans;
//   joins are driven purely by field_selection. Asking for columns of a table
//   pulls the rows of that table related to whatever the filters matched, so
//   "instruction filter + transaction fields" returns the parent transactions
//   of the matched instructions. A table with no selected columns returns no rows.
// - the tables are block, transaction, instruction_call, log, account_activity,
//   reward. account_activity is the unified native SOL + SPL token table that
//   replaced the old balance / token_balance tables.
//
// The query envelope is strict (serde deny_unknown_fields), so an unknown top-level
// key is a hard 400. Selections themselves are lenient: unknown keys inside one are
// ignored. Legacy aliases are still accepted on input but never emitted here:
// `instructions` for `instruction_calls`, `instruction` for `instruction_call`,
// `program_id` for `executing_account`, `accounts` for `account_arguments`,
// `is_committed` for `tx_success`.

// Selection (filter) types

type instructionSelection = {
  executingAccount: option<array<string>>,
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
  txSuccess: option<bool>,
}

let emptyInstructionSelection: instructionSelection = {
  executingAccount: None,
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
  txSuccess: None,
}

type transactionSelection = {
  feePayer: option<array<string>>,
  transactionId: option<array<string>>,
  transactionIndex: option<array<int>>,
  success: option<bool>,
}

let emptyTransactionSelection: transactionSelection = {
  feePayer: None,
  transactionId: None,
  transactionIndex: None,
  success: None,
}

type logSelection = {
  programId: option<array<string>>,
  kind: option<array<string>>,
}

let emptyLogSelection: logSelection = {
  programId: None,
  kind: None,
}

// account_activity merges the native SOL side and the SPL token side into one row.
// `account` is the wallet on a native row but the token account on a token row, so
// "everything for wallet W" is two selections: [{account: [W]}, {owner: [W]}].
type accountActivitySelection = {
  kind: option<array<string>>,
  account: option<array<string>>,
  transactionId: option<array<string>>,
  mint: option<array<string>>,
  owner: option<array<string>>,
  programId: option<array<string>>,
  isSigner: option<bool>,
  isWritable: option<bool>,
  isFeePayer: option<bool>,
  fromLookupTable: option<bool>,
}

let emptyAccountActivitySelection: accountActivitySelection = {
  kind: None,
  account: None,
  transactionId: None,
  mint: None,
  owner: None,
  programId: None,
  isSigner: None,
  isWritable: None,
  isFeePayer: None,
  fromLookupTable: None,
}

let activityKinds: array<string> = ["native", "token"]
let logKinds: array<string> = ["invoke", "success", "failed", "consumed", "log", "data", "other"]

// Endpoints. solana-near-head-test.hypersync.xyz is gone; these two are live and
// both answer CORS preflights, so the browser can call them directly.
// Below an endpoint's history floor the server does not error: it fast-forwards
// next_slot to the floor, so a too-early from_slot silently skips history.
type endpoint = {
  label: string,
  host: string,
  note: string,
}

let endpoints: array<endpoint> = [
  {
    label: "Solana Mainnet",
    host: "https://solana.hypersync.xyz",
    note: "near head, history from about slot 403,000,000",
  },
  {
    label: "Solana Mainnet (history)",
    host: "https://solana-mainnet-history.hypersync.xyz",
    note: "deeper history, from about slot 403,000,000",
  },
]

let defaultEndpoint = "https://solana.hypersync.xyz"

// Measured history floor. Anything below this is fast-forwarded by the server.
let historyFloorSlot = 403_000_000

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
  | @as("transaction_id") TransactionId
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
  | @as("has_dropped_log_messages") HasDroppedLogMessages

let allTransactionFields: array<transactionField> = [
  Slot,
  TransactionIndex,
  TransactionId,
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
  HasDroppedLogMessages,
]

type instructionField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("instruction_address") InstructionAddress
  | @as("executing_account") ExecutingAccount
  | @as("executing_account_index") ExecutingAccountIndex
  | @as("account_arguments") AccountArguments
  | @as("account_index_arguments") AccountIndexArguments
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
  | @as("tx_success") TxSuccess
  | @as("error") Error
  | @as("compute_units_consumed") ComputeUnitsConsumed

let allInstructionFields: array<instructionField> = [
  Slot,
  TransactionIndex,
  InstructionAddress,
  ExecutingAccount,
  ExecutingAccountIndex,
  AccountArguments,
  AccountIndexArguments,
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
  TxSuccess,
  Error,
  ComputeUnitsConsumed,
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

type accountActivityField =
  | @as("slot") Slot
  | @as("transaction_index") TransactionIndex
  | @as("transaction_id") TransactionId
  | @as("account_index") AccountIndex
  | @as("account") Account
  | @as("pre_balance") PreBalance
  | @as("post_balance") PostBalance
  | @as("is_signer") IsSigner
  | @as("is_writable") IsWritable
  | @as("is_fee_payer") IsFeePayer
  | @as("from_lookup_table") FromLookupTable
  | @as("mint") Mint
  | @as("pre_owner") PreOwner
  | @as("post_owner") PostOwner
  | @as("token_decimals") TokenDecimals
  | @as("pre_token_balance") PreTokenBalance
  | @as("post_token_balance") PostTokenBalance
  | @as("pre_program_id") PreProgramId
  | @as("post_program_id") PostProgramId
  | @as("token_state") TokenState

let allAccountActivityFields: array<accountActivityField> = [
  Slot,
  TransactionIndex,
  TransactionId,
  AccountIndex,
  Account,
  PreBalance,
  PostBalance,
  IsSigner,
  IsWritable,
  IsFeePayer,
  FromLookupTable,
  Mint,
  PreOwner,
  PostOwner,
  TokenDecimals,
  PreTokenBalance,
  PostTokenBalance,
  PreProgramId,
  PostProgramId,
  TokenState,
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
  instructionCall: array<instructionField>,
  log: array<logField>,
  accountActivity: array<accountActivityField>,
  reward: array<rewardField>,
}

let emptyFieldSelection: fieldSelection = {
  block: [],
  transaction: [],
  instructionCall: [],
  log: [],
  accountActivity: [],
  reward: [],
}

type query = {
  fromSlot: int,
  toSlot: option<int>,
  instructionCalls: option<array<instructionSelection>>,
  transactions: option<array<transactionSelection>>,
  logs: option<array<logSelection>>,
  accountActivity: option<array<accountActivitySelection>>,
  includeAllBlocks: option<bool>,
  fieldSelection: fieldSelection,
  maxNumBlocks: option<int>,
  maxNumTransactions: option<int>,
  maxNumInstructions: option<int>,
  maxNumLogs: option<int>,
  maxNumAccountActivity: option<int>,
}

// Snake-case stringifiers (relies on @as mapping; Obj.magic returns the wire string)
let blockFieldToSnake = (f: blockField): string => Obj.magic(f)
let transactionFieldToSnake = (f: transactionField): string => Obj.magic(f)
let instructionFieldToSnake = (f: instructionField): string => Obj.magic(f)
let logFieldToSnake = (f: logField): string => Obj.magic(f)
let accountActivityFieldToSnake = (f: accountActivityField): string => Obj.magic(f)
let rewardFieldToSnake = (f: rewardField): string => Obj.magic(f)

let snakeToTitle = (input: string): string =>
  Js.String.split("_", input)
  ->Belt.Array.keep(s => s != "")
  ->Belt.Array.map(s =>
    String.toUpperCase(Js.String.slice(~from=0, ~to_=1, s)) ++
    Js.String.slice(~from=1, ~to_=String.length(s), s)
  )
  ->Array.join(" ")

// Which tables the current field selection asks for. Joins follow this list:
// a table with no selected columns returns no rows, whatever the filters matched.
let selectedTables = (fs: fieldSelection): array<string> => {
  let out: array<string> = []
  if Array.length(fs.block) > 0 {
    out->Array.push("block")
  }
  if Array.length(fs.transaction) > 0 {
    out->Array.push("transaction")
  }
  if Array.length(fs.instructionCall) > 0 {
    out->Array.push("instruction_call")
  }
  if Array.length(fs.log) > 0 {
    out->Array.push("log")
  }
  if Array.length(fs.accountActivity) > 0 {
    out->Array.push("account_activity")
  }
  if Array.length(fs.reward) > 0 {
    out->Array.push("reward")
  }
  out
}

// Sensible default columns per table, used by the "also return X" join shortcuts.
let defaultBlockFields: array<blockField> = [Slot, Blockhash, BlockTime]
let defaultTransactionFields: array<transactionField> = [
  Slot,
  TransactionIndex,
  TransactionId,
  FeePayer,
  Success,
  Fee,
]
let defaultInstructionFields: array<instructionField> = [
  Slot,
  TransactionIndex,
  InstructionAddress,
  ExecutingAccount,
  AccountArguments,
  Data,
  IsInner,
]
let defaultLogFields: array<logField> = [Slot, TransactionIndex, ProgramId, Kind, Message]
let defaultAccountActivityFields: array<accountActivityField> = [
  Slot,
  TransactionIndex,
  Account,
  PreBalance,
  PostBalance,
  Mint,
  PreTokenBalance,
  PostTokenBalance,
]

// ---------------------------------------------------------------------------
// Query serialization (wire JSON). Lives here so it can be unit tested without React.
// ---------------------------------------------------------------------------

let strList = (arr: array<string>): string => arr->Array.map(s => `"${s}"`)->Array.join(", ")
let intList = (arr: array<int>): string => arr->Array.map(n => Int.toString(n))->Array.join(", ")

let strField = (name: string, v: option<array<string>>): option<string> =>
  switch v {
  | Some(arr) if Array.length(arr) > 0 => Some(`"${name}": [${strList(arr)}]`)
  | _ => None
  }

let boolField = (name: string, v: option<bool>): option<string> =>
  switch v {
  | Some(true) => Some(`"${name}": true`)
  | Some(false) => Some(`"${name}": false`)
  | None => None
  }

let joinParts = (parts: array<option<string>>): string =>
  `{${parts->Array.filterMap(x => x)->Array.join(", ")}}`

let serializeInstructionFilter = (sel: instructionSelection): string =>
  joinParts([
    strField("executing_account", sel.executingAccount),
    strField("d1", sel.d1),
    strField("d2", sel.d2),
    strField("d4", sel.d4),
    strField("d8", sel.d8),
    strField("a0", sel.a0),
    strField("a1", sel.a1),
    strField("a2", sel.a2),
    strField("a3", sel.a3),
    strField("a4", sel.a4),
    strField("a5", sel.a5),
    strField("a6", sel.a6),
    strField("a7", sel.a7),
    strField("a8", sel.a8),
    strField("a9", sel.a9),
    boolField("is_inner", sel.isInner),
    boolField("tx_success", sel.txSuccess),
  ])

let serializeTransactionFilter = (sel: transactionSelection): string =>
  joinParts([
    strField("fee_payer", sel.feePayer),
    strField("transaction_id", sel.transactionId),
    switch sel.transactionIndex {
    | Some(arr) if Array.length(arr) > 0 => Some(`"transaction_index": [${intList(arr)}]`)
    | _ => None
    },
    boolField("success", sel.success),
  ])

let serializeLogFilter = (sel: logSelection): string =>
  joinParts([strField("program_id", sel.programId), strField("kind", sel.kind)])

let serializeAccountActivityFilter = (sel: accountActivitySelection): string =>
  joinParts([
    strField("kind", sel.kind),
    strField("account", sel.account),
    strField("transaction_id", sel.transactionId),
    strField("mint", sel.mint),
    strField("owner", sel.owner),
    strField("program_id", sel.programId),
    boolField("is_signer", sel.isSigner),
    boolField("is_writable", sel.isWritable),
    boolField("is_fee_payer", sel.isFeePayer),
    boolField("from_lookup_table", sel.fromLookupTable),
  ])

// Only non-empty tables are emitted: an empty column list returns no rows anyway,
// and leaving them out keeps the join model visible in the generated JSON.
let serializeFieldSelection = (fs: fieldSelection): string => {
  let table = (name, values) =>
    Array.length(values) > 0 ? Some(`"${name}": [${values->Array.join(", ")}]`) : None
  let tables =
    [
      table("block", fs.block->Array.map(f => `"${blockFieldToSnake(f)}"`)),
      table("transaction", fs.transaction->Array.map(f => `"${transactionFieldToSnake(f)}"`)),
      table(
        "instruction_call",
        fs.instructionCall->Array.map(f => `"${instructionFieldToSnake(f)}"`),
      ),
      table("log", fs.log->Array.map(f => `"${logFieldToSnake(f)}"`)),
      table(
        "account_activity",
        fs.accountActivity->Array.map(f => `"${accountActivityFieldToSnake(f)}"`),
      ),
      table("reward", fs.reward->Array.map(f => `"${rewardFieldToSnake(f)}"`)),
    ]->Array.filterMap(x => x)
  if Array.length(tables) === 0 {
    `"field_selection": {}`
  } else {
    `"field_selection": {
    ${tables->Array.join(",\n    ")}
  }`
  }
}

let serializeQuery = (q: query): string => {
  let selectionArray = (name, values, serializer) =>
    switch values {
    | Some(arr) if Array.length(arr) > 0 =>
      let body = arr->Array.map(serializer)->Array.join(",\n    ")
      Some(
        `"${name}": [
    ${body}
  ]`,
      )
    | _ => None
    }
  let intOpt = (name, v) =>
    switch v {
    | Some(n) => Some(`"${name}": ${Int.toString(n)}`)
    | None => None
    }
  let parts: array<option<string>> = [
    Some(`"from_slot": ${Int.toString(q.fromSlot)}`),
    intOpt("to_slot", q.toSlot),
    selectionArray("instruction_calls", q.instructionCalls, serializeInstructionFilter),
    selectionArray("transactions", q.transactions, serializeTransactionFilter),
    selectionArray("logs", q.logs, serializeLogFilter),
    selectionArray("account_activity", q.accountActivity, serializeAccountActivityFilter),
    boolField("include_all_blocks", q.includeAllBlocks),
    Some(serializeFieldSelection(q.fieldSelection)),
    intOpt("max_num_blocks", q.maxNumBlocks),
    intOpt("max_num_transactions", q.maxNumTransactions),
    intOpt("max_num_instructions", q.maxNumInstructions),
    intOpt("max_num_logs", q.maxNumLogs),
    intOpt("max_num_account_activity", q.maxNumAccountActivity),
  ]
  let active = parts->Array.filterMap(x => x)
  `{
  ${Array.join(active, ",\n  ")}
}`
}
