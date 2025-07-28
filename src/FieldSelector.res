open QueryStructure
open TagSelector

// Convert field types to string representations for JSON
let blockFieldToString = (field: blockField) => {
  switch field {
  | Number => "number"
  | Hash => "hash"
  | ParentHash => "parent_hash"
  | Nonce => "nonce"
  | Sha3Uncles => "sha3_uncles"
  | LogsBloom => "logs_bloom"
  | TransactionsRoot => "transactions_root"
  | StateRoot => "state_root"
  | ReceiptsRoot => "receipts_root"
  | Miner => "miner"
  | Difficulty => "difficulty"
  | TotalDifficulty => "total_difficulty"
  | ExtraData => "extra_data"
  | Size => "size"
  | GasLimit => "gas_limit"
  | GasUsed => "gas_used"
  | Timestamp => "timestamp"
  | Uncles => "uncles"
  | BaseFeePerGas => "base_fee_per_gas"
  | BlobGasUsed => "blob_gas_used"
  | ExcessBlobGas => "excess_blob_gas"
  | ParentBeaconBlockRoot => "parent_beacon_block_root"
  | WithdrawalsRoot => "withdrawals_root"
  | Withdrawals => "withdrawals"
  | L1BlockNumber => "l1_block_number"
  | SendCount => "send_count"
  | SendRoot => "send_root"
  | MixHash => "mix_hash"
  }
}

let transactionFieldToString = (field: transactionField) => {
  switch field {
  | BlockHash => "block_hash"
  | BlockNumber => "block_number"
  | From => "from"
  | Gas => "gas"
  | GasPrice => "gas_price"
  | Hash => "hash"
  | Input => "input"
  | Nonce => "nonce"
  | To => "to"
  | TransactionIndex => "transaction_index"
  | Value => "value"
  | V => "v"
  | R => "r"
  | S => "s"
  | YParity => "y_parity"
  | MaxPriorityFeePerGas => "max_priority_fee_per_gas"
  | MaxFeePerGas => "max_fee_per_gas"
  | ChainId => "chain_id"
  | AccessList => "access_list"
  | AuthorizationList => "authorization_list"
  | MaxFeePerBlobGas => "max_fee_per_blob_gas"
  | BlobVersionedHashes => "blob_versioned_hashes"
  | CumulativeGasUsed => "cumulative_gas_used"
  | EffectiveGasPrice => "effective_gas_price"
  | GasUsed => "gas_used"
  | ContractAddress => "contract_address"
  | LogsBloom => "logs_bloom"
  | Kind => "kind"
  | Root => "root"
  | Status => "status"
  | L1Fee => "l1_fee"
  | L1GasPrice => "l1_gas_price"
  | L1GasUsed => "l1_gas_used"
  | L1FeeScalar => "l1_fee_scalar"
  | GasUsedForL1 => "gas_used_for_l1"
  }
}

let logFieldToString = (field: logField) => {
  switch field {
  | Removed => "removed"
  | LogIndex => "log_index"
  | TransactionIndex => "transaction_index"
  | TransactionHash => "transaction_hash"
  | BlockHash => "block_hash"
  | BlockNumber => "block_number"
  | Address => "address"
  | Data => "data"
  | Topic0 => "topic0"
  | Topic1 => "topic1"
  | Topic2 => "topic2"
  | Topic3 => "topic3"
  }
}

let blockFieldOptions: array<(blockField, string)> = [
  (Number, "Number"),
  (Hash, "Hash"),
  (ParentHash, "Parent Hash"),
  (Nonce, "Nonce"),
  (Miner, "Miner"),
  (Difficulty, "Difficulty"),
  (TotalDifficulty, "Total Difficulty"),
  (Size, "Size"),
  (GasLimit, "Gas Limit"),
  (GasUsed, "Gas Used"),
  (Timestamp, "Timestamp"),
  (BaseFeePerGas, "Base Fee Per Gas"),
  (Sha3Uncles, "SHA3 Uncles"),
  (LogsBloom, "Logs Bloom"),
  (TransactionsRoot, "Transactions Root"),
  (StateRoot, "State Root"),
  (ReceiptsRoot, "Receipts Root"),
  (ExtraData, "Extra Data"),
  (Uncles, "Uncles"),
  (BlobGasUsed, "Blob Gas Used"),
  (ExcessBlobGas, "Excess Blob Gas"),
  (ParentBeaconBlockRoot, "Parent Beacon Block Root"),
  (WithdrawalsRoot, "Withdrawals Root"),
  (Withdrawals, "Withdrawals"),
]

let transactionFieldOptions: array<(transactionField, string)> = [
  (BlockHash, "Block Hash"),
  (BlockNumber, "Block Number"),
  (From, "From"),
  (To, "To"),
  (Hash, "Hash"),
  (Input, "Input"),
  (Value, "Value"),
  (Gas, "Gas"),
  (GasPrice, "Gas Price"),
  (Nonce, "Nonce"),
  (TransactionIndex, "Transaction Index"),
  (Status, "Status"),
  (CumulativeGasUsed, "Cumulative Gas Used"),
  (EffectiveGasPrice, "Effective Gas Price"),
  (GasUsed, "Gas Used"),
  (ContractAddress, "Contract Address"),
  (V, "V"),
  (R, "R"),
  (S, "S"),
  (YParity, "Y Parity"),
  (MaxPriorityFeePerGas, "Max Priority Fee Per Gas"),
  (MaxFeePerGas, "Max Fee Per Gas"),
  (ChainId, "Chain ID"),
  (AccessList, "Access List"),
  (AuthorizationList, "Authorization List"),
]

let logFieldOptions: array<(logField, string)> = [
  (Address, "Address"),
  (Data, "Data"),
  (Topic0, "Topic 0"),
  (Topic1, "Topic 1"),
  (Topic2, "Topic 2"),
  (Topic3, "Topic 3"),
  (BlockHash, "Block Hash"),
  (BlockNumber, "Block Number"),
  (TransactionHash, "Transaction Hash"),
  (TransactionIndex, "Transaction Index"),
  (LogIndex, "Log Index"),
  (Removed, "Removed"),
]

@react.component
let make = (~fieldSelection: fieldSelection, ~onFieldSelectionChange: fieldSelection => unit) => {
  let updateBlockFields = newFields => onFieldSelectionChange({...fieldSelection, block: newFields})
  let updateTransactionFields = newFields => onFieldSelectionChange({...fieldSelection, transaction: newFields})
  let updateLogFields = newFields => onFieldSelectionChange({...fieldSelection, log: newFields})

  let selectAllBlockFields = () => {
    let allFields = Array.map(blockFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, block: allFields})
  }

  let clearAllBlockFields = () => {
    onFieldSelectionChange({...fieldSelection, block: []})
  }

  let selectAllTransactionFields = () => {
    let allFields = Array.map(transactionFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, transaction: allFields})
  }

  let clearAllTransactionFields = () => {
    onFieldSelectionChange({...fieldSelection, transaction: []})
  }

  let selectAllLogFields = () => {
    let allFields = Array.map(logFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, log: allFields})
  }

  let clearAllLogFields = () => {
    onFieldSelectionChange({...fieldSelection, log: []})
  }

  <div className="bg-white rounded-lg shadow p-6 mb-8">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-gray-900 mb-2">
        {"Field Selection"->React.string}
      </h3>
      <p className="text-sm text-gray-500">
        {"Choose which fields to include in your query results"->React.string}
      </p>
    </div>

    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      // Block Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-medium text-gray-900">{"Block Fields"->React.string}</h4>
          <div className="flex space-x-2">
            <button
              onClick={_ => selectAllBlockFields()}
              className="text-xs text-blue-600 hover:text-blue-700">
              {"All"->React.string}
            </button>
            <span className="text-xs text-gray-300">{"|"->React.string}</span>
            <button
              onClick={_ => clearAllBlockFields()}
              className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        <TagSelector
          title=""
          placeholder="Add field..."
          options={blockFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.block}
          onSelectionChange={updateBlockFields}
        />
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="text-xs text-gray-500">
            {`${Int.toString(Array.length(fieldSelection.block))} selected`->React.string}
          </div>
        </div>
      </div>

      // Transaction Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-medium text-gray-900">{"Transaction Fields"->React.string}</h4>
          <div className="flex space-x-2">
            <button
              onClick={_ => selectAllTransactionFields()}
              className="text-xs text-blue-600 hover:text-blue-700">
              {"All"->React.string}
            </button>
            <span className="text-xs text-gray-300">{"|"->React.string}</span>
            <button
              onClick={_ => clearAllTransactionFields()}
              className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        <TagSelector
          title=""
          placeholder="Add field..."
          options={transactionFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.transaction}
          onSelectionChange={updateTransactionFields}
        />
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="text-xs text-gray-500">
            {`${Int.toString(Array.length(fieldSelection.transaction))} selected`->React.string}
          </div>
        </div>
      </div>

      // Log Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-medium text-gray-900">{"Log Fields"->React.string}</h4>
          <div className="flex space-x-2">
            <button
              onClick={_ => selectAllLogFields()}
              className="text-xs text-blue-600 hover:text-blue-700">
              {"All"->React.string}
            </button>
            <span className="text-xs text-gray-300">{"|"->React.string}</span>
            <button
              onClick={_ => clearAllLogFields()}
              className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        <TagSelector
          title=""
          placeholder="Add field..."
          options={logFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.log}
          onSelectionChange={updateLogFields}
        />
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="text-xs text-gray-500">
            {`${Int.toString(Array.length(fieldSelection.log))} selected`->React.string}
          </div>
        </div>
      </div>
    </div>
  </div>
} 
