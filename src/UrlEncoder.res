open QueryStructure

// External bindings for Web API using proper ReScript patterns
@val external window: 'a = "window"

// Access window.location properties using @get
@get external location: 'a => 'b = "location"
@get external search: 'a => string = "search"
@get external origin: 'a => string = "origin"
@get external pathname: 'a => string = "pathname"

// Access window.history methods using @send
@get external history: 'a => 'b = "history"
@send external pushState: ('a, 'b, string, string) => unit = "pushState"

// Type for the complete state that includes both query and selectedChainId
type urlState = {
  query: query,
  selectedChainId: option<int>,
}

// Helper functions to serialize/deserialize field enums
let serializeBlockField = (field: blockField): string => {
  switch field {
  | Number => "Number"
  | Hash => "Hash"
  | ParentHash => "ParentHash"
  | Nonce => "Nonce"
  | Sha3Uncles => "Sha3Uncles"
  | LogsBloom => "LogsBloom"
  | TransactionsRoot => "TransactionsRoot"
  | StateRoot => "StateRoot"
  | ReceiptsRoot => "ReceiptsRoot"
  | Miner => "Miner"
  | Difficulty => "Difficulty"
  | TotalDifficulty => "TotalDifficulty"
  | ExtraData => "ExtraData"
  | Size => "Size"
  | GasLimit => "GasLimit"
  | GasUsed => "GasUsed"
  | Timestamp => "Timestamp"
  | Uncles => "Uncles"
  | BaseFeePerGas => "BaseFeePerGas"
  | BlobGasUsed => "BlobGasUsed"
  | ExcessBlobGas => "ExcessBlobGas"
  | ParentBeaconBlockRoot => "ParentBeaconBlockRoot"
  | WithdrawalsRoot => "WithdrawalsRoot"
  | Withdrawals => "Withdrawals"
  | L1BlockNumber => "L1BlockNumber"
  | SendCount => "SendCount"
  | SendRoot => "SendRoot"
  | MixHash => "MixHash"
  }
}

let deserializeBlockField = (str: string): option<blockField> => {
  switch str {
  | "Number" => Some(Number)
  | "Hash" => Some(Hash)
  | "ParentHash" => Some(ParentHash)
  | "Nonce" => Some(Nonce)
  | "Sha3Uncles" => Some(Sha3Uncles)
  | "LogsBloom" => Some(LogsBloom)
  | "TransactionsRoot" => Some(TransactionsRoot)
  | "StateRoot" => Some(StateRoot)
  | "ReceiptsRoot" => Some(ReceiptsRoot)
  | "Miner" => Some(Miner)
  | "Difficulty" => Some(Difficulty)
  | "TotalDifficulty" => Some(TotalDifficulty)
  | "ExtraData" => Some(ExtraData)
  | "Size" => Some(Size)
  | "GasLimit" => Some(GasLimit)
  | "GasUsed" => Some(GasUsed)
  | "Timestamp" => Some(Timestamp)
  | "Uncles" => Some(Uncles)
  | "BaseFeePerGas" => Some(BaseFeePerGas)
  | "BlobGasUsed" => Some(BlobGasUsed)
  | "ExcessBlobGas" => Some(ExcessBlobGas)
  | "ParentBeaconBlockRoot" => Some(ParentBeaconBlockRoot)
  | "WithdrawalsRoot" => Some(WithdrawalsRoot)
  | "Withdrawals" => Some(Withdrawals)
  | "L1BlockNumber" => Some(L1BlockNumber)
  | "SendCount" => Some(SendCount)
  | "SendRoot" => Some(SendRoot)
  | "MixHash" => Some(MixHash)
  | _ => None
  }
}

let serializeTransactionField = (field: transactionField): string => {
  switch field {
  | BlockHash => "BlockHash"
  | BlockNumber => "BlockNumber"
  | From => "From"
  | Gas => "Gas"
  | GasPrice => "GasPrice"
  | Hash => "Hash"
  | Input => "Input"
  | Nonce => "Nonce"
  | To => "To"
  | TransactionIndex => "TransactionIndex"
  | Value => "Value"
  | V => "V"
  | R => "R"
  | S => "S"
  | YParity => "YParity"
  | MaxPriorityFeePerGas => "MaxPriorityFeePerGas"
  | MaxFeePerGas => "MaxFeePerGas"
  | ChainId => "ChainId"
  | AccessList => "AccessList"
  | AuthorizationList => "AuthorizationList"
  | MaxFeePerBlobGas => "MaxFeePerBlobGas"
  | BlobVersionedHashes => "BlobVersionedHashes"
  | CumulativeGasUsed => "CumulativeGasUsed"
  | EffectiveGasPrice => "EffectiveGasPrice"
  | GasUsed => "GasUsed"
  | ContractAddress => "ContractAddress"
  | LogsBloom => "LogsBloom"
  | Kind => "Kind"
  | Root => "Root"
  | Status => "Status"
  | L1Fee => "L1Fee"
  | L1GasPrice => "L1GasPrice"
  | L1GasUsed => "L1GasUsed"
  | L1FeeScalar => "L1FeeScalar"
  | GasUsedForL1 => "GasUsedForL1"
  }
}

let deserializeTransactionField = (str: string): option<transactionField> => {
  switch str {
  | "BlockHash" => Some(BlockHash)
  | "BlockNumber" => Some(BlockNumber)
  | "From" => Some(From)
  | "Gas" => Some(Gas)
  | "GasPrice" => Some(GasPrice)
  | "Hash" => Some(Hash)
  | "Input" => Some(Input)
  | "Nonce" => Some(Nonce)
  | "To" => Some(To)
  | "TransactionIndex" => Some(TransactionIndex)
  | "Value" => Some(Value)
  | "V" => Some(V)
  | "R" => Some(R)
  | "S" => Some(S)
  | "YParity" => Some(YParity)
  | "MaxPriorityFeePerGas" => Some(MaxPriorityFeePerGas)
  | "MaxFeePerGas" => Some(MaxFeePerGas)
  | "ChainId" => Some(ChainId)
  | "AccessList" => Some(AccessList)
  | "AuthorizationList" => Some(AuthorizationList)
  | "MaxFeePerBlobGas" => Some(MaxFeePerBlobGas)
  | "BlobVersionedHashes" => Some(BlobVersionedHashes)
  | "CumulativeGasUsed" => Some(CumulativeGasUsed)
  | "EffectiveGasPrice" => Some(EffectiveGasPrice)
  | "GasUsed" => Some(GasUsed)
  | "ContractAddress" => Some(ContractAddress)
  | "LogsBloom" => Some(LogsBloom)
  | "Kind" => Some(Kind)
  | "Root" => Some(Root)
  | "Status" => Some(Status)
  | "L1Fee" => Some(L1Fee)
  | "L1GasPrice" => Some(L1GasPrice)
  | "L1GasUsed" => Some(L1GasUsed)
  | "L1FeeScalar" => Some(L1FeeScalar)
  | "GasUsedForL1" => Some(GasUsedForL1)
  | _ => None
  }
}

let serializeLogField = (field: logField): string => {
  switch field {
  | Removed => "Removed"
  | LogIndex => "LogIndex"
  | TransactionIndex => "TransactionIndex"
  | TransactionHash => "TransactionHash"
  | BlockHash => "BlockHash"
  | BlockNumber => "BlockNumber"
  | Address => "Address"
  | Data => "Data"
  | Topic0 => "Topic0"
  | Topic1 => "Topic1"
  | Topic2 => "Topic2"
  | Topic3 => "Topic3"
  }
}

let deserializeLogField = (str: string): option<logField> => {
  switch str {
  | "Removed" => Some(Removed)
  | "LogIndex" => Some(LogIndex)
  | "TransactionIndex" => Some(TransactionIndex)
  | "TransactionHash" => Some(TransactionHash)
  | "BlockHash" => Some(BlockHash)
  | "BlockNumber" => Some(BlockNumber)
  | "Address" => Some(Address)
  | "Data" => Some(Data)
  | "Topic0" => Some(Topic0)
  | "Topic1" => Some(Topic1)
  | "Topic2" => Some(Topic2)
  | "Topic3" => Some(Topic3)
  | _ => None
  }
}

let serializeTraceField = (field: traceField): string => {
  switch field {
  | From => "From"
  | To => "To"
  | CallType => "CallType"
  | Gas => "Gas"
  | Input => "Input"
  | Init => "Init"
  | Value => "Value"
  | Author => "Author"
  | RewardType => "RewardType"
  | BlockHash => "BlockHash"
  | BlockNumber => "BlockNumber"
  | Address => "Address"
  | Code => "Code"
  | GasUsed => "GasUsed"
  | Output => "Output"
  | Subtraces => "Subtraces"
  | TraceAddress => "TraceAddress"
  | TransactionHash => "TransactionHash"
  | TransactionPosition => "TransactionPosition"
  | Kind => "Kind"
  | Error => "Error"
  }
}

let deserializeTraceField = (str: string): option<traceField> => {
  switch str {
  | "From" => Some(From)
  | "To" => Some(To)
  | "CallType" => Some(CallType)
  | "Gas" => Some(Gas)
  | "Input" => Some(Input)
  | "Init" => Some(Init)
  | "Value" => Some(Value)
  | "Author" => Some(Author)
  | "RewardType" => Some(RewardType)
  | "BlockHash" => Some(BlockHash)
  | "BlockNumber" => Some(BlockNumber)
  | "Address" => Some(Address)
  | "Code" => Some(Code)
  | "GasUsed" => Some(GasUsed)
  | "Output" => Some(Output)
  | "Subtraces" => Some(Subtraces)
  | "TraceAddress" => Some(TraceAddress)
  | "TransactionHash" => Some(TransactionHash)
  | "TransactionPosition" => Some(TransactionPosition)
  | "Kind" => Some(Kind)
  | "Error" => Some(Error)
  | _ => None
  }
}

let serializeUrlState = (state: urlState): string => {
  let json = Js.Json.object_(Js.Dict.fromArray([
    ("query", Js.Json.object_(Js.Dict.fromArray([
      ("fromBlock", Js.Json.number(Int.toFloat(state.query.fromBlock))),
      ("toBlock", switch state.query.toBlock {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("maxNumBlocks", switch state.query.maxNumBlocks {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("maxNumTransactions", switch state.query.maxNumTransactions {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("maxNumLogs", switch state.query.maxNumLogs {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("joinMode", switch state.query.joinMode {
        | Some(Default) => Js.Json.string("Default")
        | Some(JoinAll) => Js.Json.string("JoinAll")
        | Some(JoinNothing) => Js.Json.string("JoinNothing")
        | None => Js.Json.null
      }),
      ("logs", switch state.query.logs {
        | Some(logs) => Js.Json.array(logs->Array.map(log => {
          let addressJson = switch log.address {
          | Some(addresses) => Js.Json.array(addresses->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          let topicsJson = switch log.topics {
          | Some(topics) => Js.Json.array(topics->Array.map(topicArray => 
            Js.Json.array(topicArray->Array.map(Js.Json.string))
          ))
          | None => Js.Json.null
          }
          Js.Json.object_(Js.Dict.fromArray([
            ("address", addressJson),
            ("topics", topicsJson),
          ]))
        }))
        | None => Js.Json.null
      }),
      ("transactions", switch state.query.transactions {
        | Some(transactions) => Js.Json.array(transactions->Array.map(transaction => {
          let fromJson = switch transaction.from_ {
          | Some(froms) => Js.Json.array(froms->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          let toJson = switch transaction.to_ {
          | Some(tos) => Js.Json.array(tos->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          let sighashJson = switch transaction.sighash {
          | Some(sighashes) => Js.Json.array(sighashes->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          let statusJson = switch transaction.status {
          | Some(status) => Js.Json.number(Int.toFloat(status))
          | None => Js.Json.null
          }
          let kindJson = switch transaction.kind {
          | Some(kinds) => Js.Json.array(kinds->Array.map(kind => Js.Json.number(Int.toFloat(kind))))
          | None => Js.Json.null
          }
          let contractAddressJson = switch transaction.contractAddress {
          | Some(addresses) => Js.Json.array(addresses->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          let authorizationListJson = switch transaction.authorizationList {
          | Some(authorizations) => Js.Json.array(authorizations->Array.map(auth => {
            let authChainIdJson = switch auth.chainId {
            | Some(chainIds) => Js.Json.array(chainIds->Array.map(chainId => Js.Json.number(Int.toFloat(chainId))))
            | None => Js.Json.null
            }
            let authAddressJson = switch auth.address {
            | Some(addresses) => Js.Json.array(addresses->Array.map(Js.Json.string))
            | None => Js.Json.null
            }
            Js.Json.object_(Js.Dict.fromArray([
              ("chainId", authChainIdJson),
              ("address", authAddressJson),
            ]))
          }))
          | None => Js.Json.null
          }
          Js.Json.object_(Js.Dict.fromArray([
            ("from_", fromJson),
            ("to_", toJson),
            ("sighash", sighashJson),
            ("status", statusJson),
            ("kind", kindJson),
            ("contractAddress", contractAddressJson),
            ("authorizationList", authorizationListJson),
          ]))
        }))
        | None => Js.Json.null
      }),
      ("blocks", switch state.query.blocks {
        | Some(blocks) => Js.Json.array(blocks->Array.map(block => {
          let hashJson = switch block.hash {
          | Some(hashes) => Js.Json.array(hashes->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          let minerJson = switch block.miner {
          | Some(miners) => Js.Json.array(miners->Array.map(Js.Json.string))
          | None => Js.Json.null
          }
          Js.Json.object_(Js.Dict.fromArray([
            ("hash", hashJson),
            ("miner", minerJson),
          ]))
        }))
        | None => Js.Json.null
      }),
      ("fieldSelection", Js.Json.object_(Js.Dict.fromArray([
        ("block", Js.Json.array(state.query.fieldSelection.block->Array.map(serializeBlockField)->Array.map(Js.Json.string))),
        ("transaction", Js.Json.array(state.query.fieldSelection.transaction->Array.map(serializeTransactionField)->Array.map(Js.Json.string))),
        ("log", Js.Json.array(state.query.fieldSelection.log->Array.map(serializeLogField)->Array.map(Js.Json.string))),
        ("trace", Js.Json.array(state.query.fieldSelection.trace->Array.map(serializeTraceField)->Array.map(Js.Json.string))),
      ]))),
    ]))),
    ("selectedChainId", switch state.selectedChainId {
      | Some(value) => Js.Json.number(Int.toFloat(value))
      | None => Js.Json.null
    }),
  ]))
  Js.Json.stringify(json)
}

let deserializeUrlState = (jsonString: string): option<urlState> => {
  switch Js.Json.parseExn(jsonString) {
  | json => {
    let obj = Js.Json.decodeObject(json)
    switch obj {
    | Some(obj) => {
      let getField = (fieldName: string) => Js.Dict.get(obj, fieldName)
      
      // Parse query object
      let queryJson = switch getField("query") {
      | Some(value) => value
      | None => Js.Json.null
      }
      
      let queryObj = switch Js.Json.decodeObject(queryJson) {
      | Some(queryObj) => queryObj
      | None => Js.Dict.empty()
      }
      
      let getQueryField = (fieldName: string) => Js.Dict.get(queryObj, fieldName)
      
      let fromBlock = switch getQueryField("fromBlock") {
      | Some(value) => switch Js.Json.decodeNumber(value) {
        | Some(num) => Float.toInt(num)
        | None => 0
        }
      | None => 0
      }
      
      let toBlock = switch getQueryField("toBlock") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumBlocks = switch getQueryField("maxNumBlocks") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumTransactions = switch getQueryField("maxNumTransactions") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumLogs = switch getQueryField("maxNumLogs") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let joinMode = switch getQueryField("joinMode") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeString(value) {
          | Some("Default") => Some(Default)
          | Some("JoinAll") => Some(JoinAll)
          | Some("JoinNothing") => Some(JoinNothing)
          | Some(_) => None
          | None => None
          }
        }
      | None => None
      }
      
      let logs = switch getQueryField("logs") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeArray(value) {
          | Some(array) => {
            let decodedLogs = array->Array.map(Js.Json.decodeObject)->Array.filterMap(x => x)->Array.map(log => {
              let address = switch Js.Dict.get(log, "address") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(addresses) => Some(addresses->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              let topics = switch Js.Dict.get(log, "topics") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(topicsArray) => {
                    let decodedTopics = topicsArray->Array.map(Js.Json.decodeArray)->Array.filterMap(x => x)->Array.map(topicArray => topicArray->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                    Some(decodedTopics)
                  }
                  | None => None
                  }
                }
              | None => None
              }
              { address, topics }
            })
            Some(decodedLogs)
          }
          | None => None
          }
        }
      | None => None
      }
      
      let transactions = switch getQueryField("transactions") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeArray(value) {
          | Some(array) => {
            let decodedTransactions = array->Array.map(Js.Json.decodeObject)->Array.filterMap(x => x)->Array.map(transaction => {
              let from_ = switch Js.Dict.get(transaction, "from_") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(froms) => Some(froms->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              let to_ = switch Js.Dict.get(transaction, "to_") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(tos) => Some(tos->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              let sighash = switch Js.Dict.get(transaction, "sighash") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(sighashes) => Some(sighashes->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              let status = switch Js.Dict.get(transaction, "status") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeNumber(value) {
                  | Some(num) => Some(Float.toInt(num))
                  | None => None
                  }
                }
              | None => None
              }
              let kind = switch Js.Dict.get(transaction, "kind") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(kinds) => Some(kinds->Array.map(Js.Json.decodeNumber)->Array.filterMap(x => x)->Array.map(kind => Float.toInt(kind)))
                  | None => None
                  }
                }
              | None => None
              }
              let contractAddress = switch Js.Dict.get(transaction, "contractAddress") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(addresses) => Some(addresses->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              let authorizationList = switch Js.Dict.get(transaction, "authorizationList") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(authorizations) => {
                                         let decodedAuthorizations = authorizations->Array.map(Js.Json.decodeObject)->Array.filterMap(x => x)->Array.map(auth => {
                       let chainId = switch Js.Dict.get(auth, "chainId") {
                       | Some(value) => switch Js.Json.decodeNull(value) {
                         | Some(_) => None
                         | None => switch Js.Json.decodeArray(value) {
                           | Some(chainIds) => Some(chainIds->Array.map(Js.Json.decodeNumber)->Array.filterMap(x => x)->Array.map(chainId => Float.toInt(chainId)))
                           | None => None
                           }
                         }
                       | None => None
                       }
                       let address = switch Js.Dict.get(auth, "address") {
                       | Some(value) => switch Js.Json.decodeNull(value) {
                         | Some(_) => None
                         | None => switch Js.Json.decodeArray(value) {
                           | Some(addresses) => Some(addresses->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                           | None => None
                           }
                         }
                       | None => None
                       }
                       { chainId, address }
                     })
                    Some(decodedAuthorizations)
                  }
                  | None => None
                  }
                }
              | None => None
              }
              { from_, to_, sighash, status, kind, contractAddress, authorizationList }
            })
            Some(decodedTransactions)
          }
          | None => None
          }
        }
      | None => None
      }
      
      let blocks = switch getQueryField("blocks") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeArray(value) {
          | Some(array) => {
            let decodedBlocks = array->Array.map(Js.Json.decodeObject)->Array.filterMap(x => x)->Array.map(block => {
              let hash = switch Js.Dict.get(block, "hash") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(hashes) => Some(hashes->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              let miner = switch Js.Dict.get(block, "miner") {
              | Some(value) => switch Js.Json.decodeNull(value) {
                | Some(_) => None
                | None => switch Js.Json.decodeArray(value) {
                  | Some(miners) => Some(miners->Array.map(Js.Json.decodeString)->Array.filterMap(x => x))
                  | None => None
                  }
                }
              | None => None
              }
              { hash, miner }
            })
            Some(decodedBlocks)
          }
          | None => None
          }
        }
      | None => None
      }
      
      let fieldSelectionJson = switch getQueryField("fieldSelection") {
      | Some(value) => value
      | None => Js.Json.null
      }
      
      let fieldSelectionObj = switch Js.Json.decodeObject(fieldSelectionJson) {
      | Some(fieldSelectionObj) => fieldSelectionObj
      | None => Js.Dict.empty()
      }
      
      let getFieldSelectionField = (fieldName: string) => Js.Dict.get(fieldSelectionObj, fieldName)
      
      let blockFields = switch getFieldSelectionField("block") {
      | Some(value) => switch Js.Json.decodeArray(value) {
        | Some(array) => {
          let decodedFields = array->Array.map(Js.Json.decodeString)->Array.filterMap(x => x)->Array.map(deserializeBlockField)->Array.filterMap(x => x)
          Some(decodedFields)
        }
        | None => None
        }
      | None => None
      }
      
      let transactionFields = switch getFieldSelectionField("transaction") {
      | Some(value) => switch Js.Json.decodeArray(value) {
        | Some(array) => {
          let decodedFields = array->Array.map(Js.Json.decodeString)->Array.filterMap(x => x)->Array.map(deserializeTransactionField)->Array.filterMap(x => x)
          Some(decodedFields)
        }
        | None => None
        }
      | None => None
      }
      
      let logFields = switch getFieldSelectionField("log") {
      | Some(value) => switch Js.Json.decodeArray(value) {
        | Some(array) => {
          let decodedFields = array->Array.map(Js.Json.decodeString)->Array.filterMap(x => x)->Array.map(deserializeLogField)->Array.filterMap(x => x)
          Some(decodedFields)
        }
        | None => None
        }
      | None => None
      }
      
      let traceFields = switch getFieldSelectionField("trace") {
      | Some(value) => switch Js.Json.decodeArray(value) {
        | Some(array) => {
          let decodedFields = array->Array.map(Js.Json.decodeString)->Array.filterMap(x => x)->Array.map(deserializeTraceField)->Array.filterMap(x => x)
          Some(decodedFields)
        }
        | None => None
        }
      | None => None
      }
      
      let fieldSelection = {
        block: blockFields->Option.getOr([]),
        transaction: transactionFields->Option.getOr([]),
        log: logFields->Option.getOr([]),
        trace: traceFields->Option.getOr([]),
      }
      
      let query = {
        fromBlock,
        toBlock,
        logs: logs,
        transactions: transactions,
        traces: None,
        blocks: blocks,
        includeAllBlocks: None,
        fieldSelection,
        maxNumBlocks,
        maxNumTransactions,
        maxNumLogs,
        maxNumTraces: None,
        joinMode,
      }
      
      // Parse selectedChainId
      let selectedChainId = switch getField("selectedChainId") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      Some({
        query,
        selectedChainId,
      })
    }
    | None => None
    }
  }
  | exception _ => None
  }
}

let encodeUrlStateToUrl = (state: urlState): string => {
  let jsonString = serializeUrlState(state)
  Js.Global.encodeURIComponent(jsonString)
}

let decodeUrlStateFromUrl = (encodedString: string): option<urlState> => {
  let decodedString = Js.Global.decodeURIComponent(encodedString)
  deserializeUrlState(decodedString)
}

let getUrlStateFromUrl = (): option<urlState> => {
  // Get the search string from window.location using proper bindings
  let locationObj = location(window)
  let searchStr = search(locationObj)
  // Simple URL parameter parsing without Js.Url
  if Js.String2.startsWith(searchStr, "?q=") {
    let encodedQuery = Js.String2.substring(searchStr, ~from=3, ~to_=Js.String2.length(searchStr))
    decodeUrlStateFromUrl(encodedQuery)
  } else {
    None
  }
}

let updateUrlWithState = (state: urlState) => {
  let encodedState = encodeUrlStateToUrl(state)
  let locationObj = location(window)
  let originStr = origin(locationObj)
  let pathnameStr = pathname(locationObj)
  let newUrl = originStr ++ pathnameStr ++ "?q=" ++ encodedState
  let historyObj = history(window)
  pushState(historyObj, null, "", newUrl)
}

// Backward compatibility functions for existing code
let serializeQuery = (query: query): string => {
  serializeUrlState({query, selectedChainId: None})
}

let deserializeQuery = (jsonString: string): option<query> => {
  switch deserializeUrlState(jsonString) {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let encodeQueryToUrl = (query: query): string => {
  encodeUrlStateToUrl({query, selectedChainId: None})
}

let decodeQueryFromUrl = (encodedString: string): option<query> => {
  switch decodeUrlStateFromUrl(encodedString) {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let getQueryFromUrl = (): option<query> => {
  switch getUrlStateFromUrl() {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let updateUrlWithQuery = (query: query) => {
  updateUrlWithState({query, selectedChainId: None})
} 