import { ReactElement } from 'react';

// Query structure types
export interface BlockSelection {
  hash?: string[];
  miner?: string[];
}

export interface LogSelection {
  address?: string[];
  topics?: string[][];
}

export interface AuthorizationSelection {
  chainId?: number[];
  address?: string[];
}

export interface TransactionSelection {
  from_?: string[];
  to_?: string[];
  sighash?: string[];
  status?: number;
  kind?: number[];
  contractAddress?: string[];
  authorizationList?: AuthorizationSelection[];
}

export interface TraceSelection {
  from_?: string[];
  to_?: string[];
  address?: string[];
  callType?: string[];
  rewardType?: string[];
  kind?: string[];
  sighash?: string[];
}

export type BlockField =
  | 'Number' | 'Hash' | 'ParentHash' | 'Nonce' | 'Sha3Uncles'
  | 'LogsBloom' | 'TransactionsRoot' | 'StateRoot' | 'ReceiptsRoot'
  | 'Miner' | 'Difficulty' | 'TotalDifficulty' | 'ExtraData' | 'Size'
  | 'GasLimit' | 'GasUsed' | 'Timestamp' | 'Uncles' | 'BaseFeePerGas'
  | 'BlobGasUsed' | 'ExcessBlobGas' | 'ParentBeaconBlockRoot'
  | 'WithdrawalsRoot' | 'Withdrawals' | 'L1BlockNumber' | 'SendCount'
  | 'SendRoot' | 'MixHash';

export type TransactionField =
  | 'BlockHash' | 'BlockNumber' | 'From' | 'Gas' | 'GasPrice' | 'Hash'
  | 'Input' | 'Nonce' | 'To' | 'TransactionIndex' | 'Value' | 'V' | 'R' | 'S'
  | 'YParity' | 'MaxPriorityFeePerGas' | 'MaxFeePerGas' | 'ChainId'
  | 'AccessList' | 'AuthorizationList' | 'MaxFeePerBlobGas'
  | 'BlobVersionedHashes' | 'CumulativeGasUsed' | 'EffectiveGasPrice'
  | 'GasUsed' | 'ContractAddress' | 'LogsBloom' | 'Kind' | 'Root' | 'Status'
  | 'L1Fee' | 'L1GasPrice' | 'L1GasUsed' | 'L1FeeScalar' | 'GasUsedForL1';

export type LogField =
  | 'Removed' | 'LogIndex' | 'TransactionIndex' | 'TransactionHash'
  | 'BlockHash' | 'BlockNumber' | 'Address' | 'Data' | 'Topic0'
  | 'Topic1' | 'Topic2' | 'Topic3';

export type TraceField =
  | 'From' | 'To' | 'CallType' | 'Gas' | 'Input' | 'Init' | 'Value'
  | 'Author' | 'RewardType' | 'BlockHash' | 'BlockNumber' | 'Address'
  | 'Code' | 'GasUsed' | 'Output' | 'Subtraces' | 'TraceAddress'
  | 'TransactionHash' | 'TransactionPosition' | 'Kind' | 'Error';

export interface FieldSelection {
  block: BlockField[];
  transaction: TransactionField[];
  log: LogField[];
  trace: TraceField[];
}

export type JoinMode = 'Default' | 'JoinAll' | 'JoinNothing';

export interface Query {
  fromBlock: number;
  toBlock?: number;
  logs?: LogSelection[];
  transactions?: TransactionSelection[];
  traces?: TraceSelection[];
  blocks?: BlockSelection[];
  includeAllBlocks?: boolean;
  fieldSelection: FieldSelection;
  maxNumBlocks?: number;
  maxNumTransactions?: number;
  maxNumLogs?: number;
  maxNumTraces?: number;
  joinMode?: JoinMode;
}

// Component props interfaces
export interface HyperSyncQueryBuilderProps {
  // Main query builder component - no required props, manages state internally
}

export interface QueryResultsProps {
  query: Query;
  selectedChainId?: number;
}

export interface ChainSelectorProps {
  selectedChainId?: number;
  onChainSelect: (chainId: number) => void;
}

export interface LogFilterProps {
  filterState: LogSelection;
  onFilterChange: (filter: LogSelection) => void;
  onRemove: () => void;
  filterIndex: number;
}

export interface TransactionFilterProps {
  filterState: TransactionSelection;
  onFilterChange: (filter: TransactionSelection) => void;
  onRemove: () => void;
  filterIndex: number;
}

export interface BlockFilterProps {
  filterState: BlockSelection;
  onFilterChange: (filter: BlockSelection) => void;
  onRemove: () => void;
  filterIndex: number;
}

export interface FieldSelectorProps {
  fieldSelection: FieldSelection;
  onFieldSelectionChange: (fieldSelection: FieldSelection) => void;
}

export interface AdvancedOptionsProps {
  query: Query;
  onQueryChange: (query: Query) => void;
}

export interface QueryLogicProps {
  query: Query;
}

// Component declarations
export declare const HyperSyncQueryBuilder: (props: HyperSyncQueryBuilderProps) => ReactElement;
export declare const QueryResults: (props: QueryResultsProps) => ReactElement;
export declare const ChainSelector: (props: ChainSelectorProps) => ReactElement;
export declare const LogFilter: (props: LogFilterProps) => ReactElement;
export declare const TransactionFilter: (props: TransactionFilterProps) => ReactElement;
export declare const BlockFilter: (props: BlockFilterProps) => ReactElement;
export declare const FieldSelector: (props: FieldSelectorProps) => ReactElement;
export declare const AdvancedOptions: (props: AdvancedOptionsProps) => ReactElement;
export declare const QueryLogic: (props: QueryLogicProps) => ReactElement;

// Default export
declare const _default: (props: HyperSyncQueryBuilderProps) => ReactElement;
export default _default; 
