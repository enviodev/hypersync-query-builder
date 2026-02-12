// Selection types

type blockSelection = {
  hash: option<array<string>>,
  miner: option<array<string>>,
}

type logSelection = {
  address: option<array<string>>,
  topics: option<array<array<string>>>,
}

type authorizationSelection = {
  chainId: option<array<int>>,
  address: option<array<string>>,
}

type transactionSelection = {
  from_: option<array<string>>,
  to_: option<array<string>>,
  sighash: option<array<string>>,
  status: option<int>,
  type_: option<array<int>>,
  contractAddress: option<array<string>>,
  authorizationList: option<array<authorizationSelection>>,
}

type traceSelection = {
  from_: option<array<string>>,
  to_: option<array<string>>,
  address: option<array<string>>,
  callType: option<array<string>>,
  rewardType: option<array<string>>,
  type_: option<array<string>>,
  sighash: option<array<string>>,
}

// Field selection enums

type blockField =
  | @as("number") Number
  | @as("hash") Hash
  | @as("parent_hash") ParentHash
  | @as("nonce") Nonce
  | @as("sha3_uncles") Sha3Uncles
  | @as("logs_bloom") LogsBloom
  | @as("transactions_root") TransactionsRoot
  | @as("state_root") StateRoot
  | @as("receipts_root") ReceiptsRoot
  | @as("miner") Miner
  | @as("difficulty") Difficulty
  | @as("total_difficulty") TotalDifficulty
  | @as("extra_data") ExtraData
  | @as("size") Size
  | @as("gas_limit") GasLimit
  | @as("gas_used") GasUsed
  | @as("timestamp") Timestamp
  | @as("uncles") Uncles
  | @as("base_fee_per_gas") BaseFeePerGas
  | @as("blob_gas_used") BlobGasUsed
  | @as("excess_blob_gas") ExcessBlobGas
  | @as("parent_beacon_block_root") ParentBeaconBlockRoot
  | @as("withdrawals_root") WithdrawalsRoot
  | @as("withdrawals") Withdrawals
  | @as("l1_block_number") L1BlockNumber
  | @as("send_count") SendCount
  | @as("send_root") SendRoot
  | @as("mix_hash") MixHash

let allBlockFields: array<blockField> = [
  Number,
  Hash,
  ParentHash,
  Nonce,
  Sha3Uncles,
  LogsBloom,
  TransactionsRoot,
  StateRoot,
  ReceiptsRoot,
  Miner,
  Difficulty,
  TotalDifficulty,
  ExtraData,
  Size,
  GasLimit,
  GasUsed,
  Timestamp,
  Uncles,
  BaseFeePerGas,
  BlobGasUsed,
  ExcessBlobGas,
  ParentBeaconBlockRoot,
  WithdrawalsRoot,
  Withdrawals,
  L1BlockNumber,
  SendCount,
  SendRoot,
  MixHash,
]

type transactionField =
  | @as("block_hash") BlockHash
  | @as("block_number") BlockNumber
  | @as("from") From
  | @as("gas") Gas
  | @as("gas_price") GasPrice
  | @as("hash") Hash
  | @as("input") Input
  | @as("nonce") Nonce
  | @as("to") To
  | @as("transaction_index") TransactionIndex
  | @as("value") Value
  | @as("v") V
  | @as("r") R
  | @as("s") S
  | @as("y_parity") YParity
  | @as("max_priority_fee_per_gas") MaxPriorityFeePerGas
  | @as("max_fee_per_gas") MaxFeePerGas
  | @as("chain_id") ChainId
  | @as("access_list") AccessList
  | @as("authorization_list") AuthorizationList
  | @as("max_fee_per_blob_gas") MaxFeePerBlobGas
  | @as("blob_versioned_hashes") BlobVersionedHashes
  | @as("cumulative_gas_used") CumulativeGasUsed
  | @as("effective_gas_price") EffectiveGasPrice
  | @as("gas_used") GasUsed
  | @as("contract_address") ContractAddress
  | @as("logs_bloom") LogsBloom
  | @as("type") Type_
  | @as("root") Root
  | @as("status") Status
  | @as("sighash") Sighash
  | @as("l1_fee") L1Fee
  | @as("l1_gas_price") L1GasPrice
  | @as("l1_gas_used") L1GasUsed
  | @as("l1_fee_scalar") L1FeeScalar
  | @as("gas_used_for_l1") GasUsedForL1
  | @as("blob_gas_price") BlobGasPrice
  | @as("blob_gas_used") BlobGasUsed
  | @as("deposit_nonce") DepositNonce
  | @as("deposit_receipt_version") DepositReceiptVersion
  | @as("l1_base_fee_scalar") L1BaseFeeScalar
  | @as("l1_blob_base_fee") L1BlobBaseFee
  | @as("l1_blob_base_fee_scalar") L1BlobBaseFeeScalar
  | @as("l1_block_number") L1BlockNumber
  | @as("mint") Mint
  | @as("source_hash") SourceHash

let allTransactionFields: array<transactionField> = [
  BlockHash,
  BlockNumber,
  From,
  Gas,
  GasPrice,
  Hash,
  Input,
  Nonce,
  To,
  TransactionIndex,
  Value,
  V,
  R,
  S,
  YParity,
  MaxPriorityFeePerGas,
  MaxFeePerGas,
  ChainId,
  AccessList,
  AuthorizationList,
  MaxFeePerBlobGas,
  BlobVersionedHashes,
  CumulativeGasUsed,
  EffectiveGasPrice,
  GasUsed,
  ContractAddress,
  LogsBloom,
  Type_,
  Root,
  Status,
  Sighash,
  L1Fee,
  L1GasPrice,
  L1GasUsed,
  L1FeeScalar,
  GasUsedForL1,
  BlobGasPrice,
  BlobGasUsed,
  DepositNonce,
  DepositReceiptVersion,
  L1BaseFeeScalar,
  L1BlobBaseFee,
  L1BlobBaseFeeScalar,
  L1BlockNumber,
  Mint,
  SourceHash,
]

type logField =
  | @as("removed") Removed
  | @as("log_index") LogIndex
  | @as("transaction_index") TransactionIndex
  | @as("transaction_hash") TransactionHash
  | @as("block_hash") BlockHash
  | @as("block_number") BlockNumber
  | @as("address") Address
  | @as("data") Data
  | @as("topic0") Topic0
  | @as("topic1") Topic1
  | @as("topic2") Topic2
  | @as("topic3") Topic3

let allLogFields: array<logField> = [
  Removed,
  LogIndex,
  TransactionIndex,
  TransactionHash,
  BlockHash,
  BlockNumber,
  Address,
  Data,
  Topic0,
  Topic1,
  Topic2,
  Topic3,
]
type traceField =
  | @as("from") From
  | @as("to") To
  | @as("call_type") CallType
  | @as("gas") Gas
  | @as("input") Input
  | @as("init") Init
  | @as("value") Value
  | @as("author") Author
  | @as("reward_type") RewardType
  | @as("block_hash") BlockHash
  | @as("block_number") BlockNumber
  | @as("address") Address
  | @as("code") Code
  | @as("gas_used") GasUsed
  | @as("output") Output
  | @as("subtraces") Subtraces
  | @as("trace_address") TraceAddress
  | @as("transaction_hash") TransactionHash
  | @as("transaction_position") TransactionPosition
  | @as("type") Type_
  | @as("error") Trace_Error
  | @as("sighash") Sighash
  | @as("action_address") ActionAddress
  | @as("balance") Balance
  | @as("refund_address") RefundAddress

let allTraceFields: array<traceField> = [
  From,
  To,
  CallType,
  Gas,
  Input,
  Init,
  Value,
  Author,
  RewardType,
  BlockHash,
  BlockNumber,
  Address,
  Code,
  GasUsed,
  Output,
  Subtraces,
  TraceAddress,
  TransactionHash,
  TransactionPosition,
  Type_,
  Trace_Error,
  Sighash,
  ActionAddress,
  Balance,
  RefundAddress,
]
type fieldSelection = {
  block: array<blockField>,
  transaction: array<transactionField>,
  log: array<logField>,
  trace: array<traceField>, // Not used for now.
}

// Join mode enum

type joinMode =
  | Default
  | JoinAll
  | JoinNothing

// Main Query type

type query = {
  fromBlock: int,
  toBlock: option<int>,
  logs: option<array<logSelection>>,
  transactions: option<array<transactionSelection>>,
  traces: option<array<traceSelection>>, // Won't implement.
  blocks: option<array<blockSelection>>,
  includeAllBlocks: option<bool>,
  fieldSelection: fieldSelection,
  maxNumBlocks: option<int>,
  maxNumTransactions: option<int>,
  maxNumLogs: option<int>,
  maxNumTraces: option<int>,
  joinMode: option<joinMode>,
}
