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
  kind: option<array<int>>,
  contractAddress: option<array<string>>,
  authorizationList: option<array<authorizationSelection>>,
}

type traceSelection = {
  from_: option<array<string>>,
  to_: option<array<string>>,
  address: option<array<string>>,
  callType: option<array<string>>,
  rewardType: option<array<string>>,
  kind: option<array<string>>,
  sighash: option<array<string>>,
}

// Field selection enums

type blockField =
  | Number
  | Hash
  | ParentHash
  | Nonce
  | Sha3Uncles
  | LogsBloom
  | TransactionsRoot
  | StateRoot
  | ReceiptsRoot
  | Miner
  | Difficulty
  | TotalDifficulty
  | ExtraData
  | Size
  | GasLimit
  | GasUsed
  | Timestamp
  | Uncles
  | BaseFeePerGas
  | BlobGasUsed
  | ExcessBlobGas
  | ParentBeaconBlockRoot
  | WithdrawalsRoot
  | Withdrawals
  | L1BlockNumber
  | SendCount
  | SendRoot
  | MixHash

type transactionField =
  | BlockHash
  | BlockNumber
  | From
  | Gas
  | GasPrice
  | Hash
  | Input
  | Nonce
  | To
  | TransactionIndex
  | Value
  | V
  | R
  | S
  | YParity
  | MaxPriorityFeePerGas
  | MaxFeePerGas
  | ChainId
  | AccessList
  | AuthorizationList
  | MaxFeePerBlobGas
  | BlobVersionedHashes
  | CumulativeGasUsed
  | EffectiveGasPrice
  | GasUsed
  | ContractAddress
  | LogsBloom
  | Kind
  | Root
  | Status
  | L1Fee
  | L1GasPrice
  | L1GasUsed
  | L1FeeScalar
  | GasUsedForL1

type logField =
  | Removed
  | LogIndex
  | TransactionIndex
  | TransactionHash
  | BlockHash
  | BlockNumber
  | Address
  | Data
  | Topic0
  | Topic1
  | Topic2
  | Topic3

type traceField =
  | From
  | To
  | CallType
  | Gas
  | Input
  | Init
  | Value
  | Author
  | RewardType
  | BlockHash
  | BlockNumber
  | Address
  | Code
  | GasUsed
  | Output
  | Subtraces
  | TraceAddress
  | TransactionHash
  | TransactionPosition
  | Kind
  | Error

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
