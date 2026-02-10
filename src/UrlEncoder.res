open QueryStructure
// open RescriptReactRouter

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

// Type for the complete state that includes both query and selectedChainName
type urlState = {
  query: query,
  selectedChainName: option<string>,
}

// ============================================================================
// Compression utilities using pako for base64url encoding
// ============================================================================

// Import pako for compression
%%raw(`import * as pako from 'pako'`)

// Compress JSON string to base64url format using pako deflate
let compressToBase64Url: string => string = %raw(`
  function(jsonString) {
    // Compress with deflate
    const compressed = pako.deflate(jsonString);
    // Convert Uint8Array to binary string
    let binary = '';
    for (let i = 0; i < compressed.length; i++) {
      binary += String.fromCharCode(compressed[i]);
    }
    // Convert to base64
    const base64 = btoa(binary);
    // Convert to base64url (URL-safe)
    return base64
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  }
`)

// Decompress base64url string back to JSON string using pako inflate
let decompressFromBase64Url: string => option<string> = %raw(`
  function(encoded) {
    try {
      // Convert base64url to base64
      let base64 = encoded
        .replace(/-/g, '+')
        .replace(/_/g, '/');
      // Add padding if needed
      while (base64.length % 4) {
        base64 += '=';
      }
      // Decode base64 to binary string
      const binary = atob(base64);
      // Convert binary string to Uint8Array
      const bytes = new Uint8Array(binary.length);
      for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
      }
      // Decompress with inflate
      const jsonString = pako.inflate(bytes, { to: 'string' });
      return jsonString;
    } catch (e) {
      return undefined;
    }
  }
`)

// Check if a string looks like old URL-encoded JSON (starts with %7B which is "{")
let isLegacyUrlEncoded: string => bool = %raw(`
  function(str) {
    return str.startsWith('%7B') || str.startsWith('%7b') || str.startsWith('{');
  }
`)

// Helper functions to serialize/deserialize field enums
let serializeBlockField = (field: blockField): string =>
  FieldSelector.blockFieldToCamelCaseString(field)

let deserializeBlockField = (str: string): option<blockField> => {
  let snake = FieldSelector.camelToSnake(str)

  Array.find(QueryStructure.allBlockFields, f =>
    FieldSelector.blockFieldToSnakeCaseString(f) == snake
  )
}

let serializeTransactionField = (field: transactionField): string =>
  FieldSelector.transactionFieldToCamelCaseString(field)

let deserializeTransactionField = (str: string): option<transactionField> => {
  let snake = FieldSelector.camelToSnake(str)
  Array.find(QueryStructure.allTransactionFields, f =>
    FieldSelector.transactionFieldToSnakeCaseString(f) == snake
  )
}

let serializeLogField = (field: logField): string => FieldSelector.logFieldToCamelCaseString(field)

let deserializeLogField = (str: string): option<logField> => {
  let snake = FieldSelector.camelToSnake(str)
  Array.find(QueryStructure.allLogFields, f => FieldSelector.logFieldToSnakeCaseString(f) == snake)
}

let serializeTraceField = (field: traceField): string =>
  FieldSelector.traceFieldToCamelCaseString(field)

let deserializeTraceField = (str: string): option<traceField> => {
  let snake = FieldSelector.camelToSnake(str)
  Array.find(QueryStructure.allTraceFields, f =>
    FieldSelector.traceFieldToSnakeCaseString(f) == snake
  )
}

let serializeUrlState = (state: urlState): string => {
  let json = JSON.Encode.object(
    Dict.fromArray([
      (
        "query",
        JSON.Encode.object(
          Dict.fromArray([
            ("fromBlock", JSON.Encode.float(Int.toFloat(state.query.fromBlock))),
            (
              "toBlock",
              switch state.query.toBlock {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "maxNumBlocks",
              switch state.query.maxNumBlocks {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "maxNumTransactions",
              switch state.query.maxNumTransactions {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "maxNumLogs",
              switch state.query.maxNumLogs {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "joinMode",
              switch state.query.joinMode {
              | Some(Default) => JSON.Encode.string("Default")
              | Some(JoinAll) => JSON.Encode.string("JoinAll")
              | Some(JoinNothing) => JSON.Encode.string("JoinNothing")
              | None => JSON.Encode.null
              },
            ),
            (
              "logs",
              switch state.query.logs {
              | Some(logs) =>
                JSON.Encode.array(
                  logs->Array.map(log => {
                    let addressJson = switch log.address {
                    | Some(addresses) => JSON.Encode.array(addresses->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let topicsJson = switch log.topics {
                    | Some(topics) =>
                      JSON.Encode.array(
                        topics->Array.map(topicArray =>
                          JSON.Encode.array(topicArray->Array.map(JSON.Encode.string))
                        ),
                      )
                    | None => JSON.Encode.null
                    }
                    JSON.Encode.object(
                      Dict.fromArray([("address", addressJson), ("topics", topicsJson)]),
                    )
                  }),
                )
              | None => JSON.Encode.null
              },
            ),
            (
              "transactions",
              switch state.query.transactions {
              | Some(transactions) =>
                JSON.Encode.array(
                  transactions->Array.map(transaction => {
                    let fromJson = switch transaction.from_ {
                    | Some(froms) => JSON.Encode.array(froms->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let toJson = switch transaction.to_ {
                    | Some(tos) => JSON.Encode.array(tos->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let sighashJson = switch transaction.sighash {
                    | Some(sighashes) => JSON.Encode.array(sighashes->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let statusJson = switch transaction.status {
                    | Some(status) => JSON.Encode.float(Int.toFloat(status))
                    | None => JSON.Encode.null
                    }
                    let kindJson = switch transaction.kind {
                    | Some(kinds) =>
                      JSON.Encode.array(
                        kinds->Array.map(kind => JSON.Encode.float(Int.toFloat(kind))),
                      )
                    | None => JSON.Encode.null
                    }
                    let contractAddressJson = switch transaction.contractAddress {
                    | Some(addresses) => JSON.Encode.array(addresses->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let authorizationListJson = switch transaction.authorizationList {
                    | Some(authorizations) =>
                      JSON.Encode.array(
                        authorizations->Array.map(auth => {
                          let authChainIdJson = switch auth.chainId {
                          | Some(chainIds) =>
                            JSON.Encode.array(
                              chainIds->Array.map(
                                chainId => JSON.Encode.float(Int.toFloat(chainId)),
                              ),
                            )
                          | None => JSON.Encode.null
                          }
                          let authAddressJson = switch auth.address {
                          | Some(addresses) =>
                            JSON.Encode.array(addresses->Array.map(JSON.Encode.string))
                          | None => JSON.Encode.null
                          }
                          JSON.Encode.object(
                            Dict.fromArray([
                              ("chainId", authChainIdJson),
                              ("address", authAddressJson),
                            ]),
                          )
                        }),
                      )
                    | None => JSON.Encode.null
                    }
                    JSON.Encode.object(
                      Dict.fromArray([
                        ("from_", fromJson),
                        ("to_", toJson),
                        ("sighash", sighashJson),
                        ("status", statusJson),
                        ("kind", kindJson),
                        ("contractAddress", contractAddressJson),
                        ("authorizationList", authorizationListJson),
                      ]),
                    )
                  }),
                )
              | None => JSON.Encode.null
              },
            ),
            (
              "blocks",
              switch state.query.blocks {
              | Some(blocks) =>
                JSON.Encode.array(
                  blocks->Array.map(block => {
                    let hashJson = switch block.hash {
                    | Some(hashes) => JSON.Encode.array(hashes->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let minerJson = switch block.miner {
                    | Some(miners) => JSON.Encode.array(miners->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    JSON.Encode.object(Dict.fromArray([("hash", hashJson), ("miner", minerJson)]))
                  }),
                )
              | None => JSON.Encode.null
              },
            ),
            (
              "fieldSelection",
              JSON.Encode.object(
                Dict.fromArray([
                  (
                    "block",
                    JSON.Encode.array(
                      state.query.fieldSelection.block
                      ->Array.map(serializeBlockField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                  (
                    "transaction",
                    JSON.Encode.array(
                      state.query.fieldSelection.transaction
                      ->Array.map(serializeTransactionField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                  (
                    "log",
                    JSON.Encode.array(
                      state.query.fieldSelection.log
                      ->Array.map(serializeLogField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                  (
                    "trace",
                    JSON.Encode.array(
                      state.query.fieldSelection.trace
                      ->Array.map(serializeTraceField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
      (
        "selectedChainName",
        switch state.selectedChainName {
        | Some(value) => JSON.Encode.string(value)
        | None => JSON.Encode.null
        },
      ),
    ]),
  )
  JSON.stringify(json)
}

let deserializeUrlState = (jsonString: string): option<urlState> => {
  switch JSON.parseOrThrow(jsonString) {
  | json => {
      let obj = JSON.Decode.object(json)
      switch obj {
      | Some(obj) => {
          let getField = (fieldName: string) => Dict.get(obj, fieldName)

          // Parse query object
          let queryJson = switch getField("query") {
          | Some(value) => value
          | None => JSON.Encode.null
          }

          let queryObj = switch JSON.Decode.object(queryJson) {
          | Some(queryObj) => queryObj
          | None => Dict.make()
          }

          let getQueryField = (fieldName: string) => Dict.get(queryObj, fieldName)

          let fromBlock = switch getQueryField("fromBlock") {
          | Some(value) =>
            switch JSON.Decode.float(value) {
            | Some(num) => Float.toInt(num)
            | None => 0
            }
          | None => 0
          }

          let toBlock = switch getQueryField("toBlock") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.float(value) {
              | Some(num) => Some(Float.toInt(num))
              | None => None
              }
            }
          | None => None
          }

          let maxNumBlocks = switch getQueryField("maxNumBlocks") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.float(value) {
              | Some(num) => Some(Float.toInt(num))
              | None => None
              }
            }
          | None => None
          }

          let maxNumTransactions = switch getQueryField("maxNumTransactions") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.float(value) {
              | Some(num) => Some(Float.toInt(num))
              | None => None
              }
            }
          | None => None
          }

          let maxNumLogs = switch getQueryField("maxNumLogs") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.float(value) {
              | Some(num) => Some(Float.toInt(num))
              | None => None
              }
            }
          | None => None
          }

          let joinMode = switch getQueryField("joinMode") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.string(value) {
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
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.array(value) {
              | Some(array) => {
                  let decodedLogs =
                    array
                    ->Array.map(JSON.Decode.object)
                    ->Array.filterMap(x => x)
                    ->Array.map(log => {
                      let address = switch Dict.get(log, "address") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(addresses) =>
                            Some(addresses->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let topics = switch Dict.get(log, "topics") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(topicsArray) => {
                              let decodedTopics =
                                topicsArray
                                ->Array.map(JSON.Decode.array)
                                ->Array.filterMap(x => x)
                                ->Array.map(topicArray =>
                                  topicArray
                                  ->Array.map(JSON.Decode.string)
                                  ->Array.filterMap(x => x)
                                )
                              Some(decodedTopics)
                            }
                          | None => None
                          }
                        }
                      | None => None
                      }
                      {address, topics}
                    })
                  Some(decodedLogs)
                }
              | None => None
              }
            }
          | None => None
          }

          let transactions = switch getQueryField("transactions") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.array(value) {
              | Some(array) => {
                  let decodedTransactions =
                    array
                    ->Array.map(JSON.Decode.object)
                    ->Array.filterMap(x => x)
                    ->Array.map(transaction => {
                      let from_ = switch Dict.get(transaction, "from_") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(froms) =>
                            Some(froms->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let to_ = switch Dict.get(transaction, "to_") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(tos) =>
                            Some(tos->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let sighash = switch Dict.get(transaction, "sighash") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(sighashes) =>
                            Some(sighashes->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let status = switch Dict.get(transaction, "status") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.float(value) {
                          | Some(num) => Some(Float.toInt(num))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let kind = switch Dict.get(transaction, "kind") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(kinds) =>
                            Some(
                              kinds
                              ->Array.map(JSON.Decode.float)
                              ->Array.filterMap(x => x)
                              ->Array.map(kind => Float.toInt(kind)),
                            )
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let contractAddress = switch Dict.get(transaction, "contractAddress") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(addresses) =>
                            Some(addresses->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let authorizationList = switch Dict.get(transaction, "authorizationList") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(authorizations) => {
                              let decodedAuthorizations =
                                authorizations
                                ->Array.map(JSON.Decode.object)
                                ->Array.filterMap(x => x)
                                ->Array.map(auth => {
                                  let chainId = switch Dict.get(auth, "chainId") {
                                  | Some(value) =>
                                    switch JSON.Decode.null(value) {
                                    | Some(_) => None
                                    | None =>
                                      switch JSON.Decode.array(value) {
                                      | Some(chainIds) =>
                                        Some(
                                          chainIds
                                          ->Array.map(JSON.Decode.float)
                                          ->Array.filterMap(x => x)
                                          ->Array.map(chainId => Float.toInt(chainId)),
                                        )
                                      | None => None
                                      }
                                    }
                                  | None => None
                                  }
                                  let address = switch Dict.get(auth, "address") {
                                  | Some(value) =>
                                    switch JSON.Decode.null(value) {
                                    | Some(_) => None
                                    | None =>
                                      switch JSON.Decode.array(value) {
                                      | Some(addresses) =>
                                        Some(
                                          addresses
                                          ->Array.map(JSON.Decode.string)
                                          ->Array.filterMap(x => x),
                                        )
                                      | None => None
                                      }
                                    }
                                  | None => None
                                  }
                                  {chainId, address}
                                })
                              Some(decodedAuthorizations)
                            }
                          | None => None
                          }
                        }
                      | None => None
                      }
                      {from_, to_, sighash, status, kind, contractAddress, authorizationList}
                    })
                  Some(decodedTransactions)
                }
              | None => None
              }
            }
          | None => None
          }

          let blocks = switch getQueryField("blocks") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.array(value) {
              | Some(array) => {
                  let decodedBlocks =
                    array
                    ->Array.map(JSON.Decode.object)
                    ->Array.filterMap(x => x)
                    ->Array.map(block => {
                      let hash = switch Dict.get(block, "hash") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(hashes) =>
                            Some(hashes->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      let miner = switch Dict.get(block, "miner") {
                      | Some(value) =>
                        switch JSON.Decode.null(value) {
                        | Some(_) => None
                        | None =>
                          switch JSON.Decode.array(value) {
                          | Some(miners) =>
                            Some(miners->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
                          | None => None
                          }
                        }
                      | None => None
                      }
                      {hash, miner}
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
          | None => JSON.Encode.null
          }

          let fieldSelectionObj = switch JSON.Decode.object(fieldSelectionJson) {
          | Some(fieldSelectionObj) => fieldSelectionObj
          | None => Dict.make()
          }

          let getFieldSelectionField = (fieldName: string) => Dict.get(fieldSelectionObj, fieldName)

          let blockFields = switch getFieldSelectionField("block") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) => {
                let decodedFields =
                  array
                  ->Array.map(JSON.Decode.string)
                  ->Array.filterMap(x => x)
                  ->Array.map(deserializeBlockField)
                  ->Array.filterMap(x => x)
                Some(decodedFields)
              }
            | None => None
            }
          | None => None
          }

          let transactionFields = switch getFieldSelectionField("transaction") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) => {
                let decodedFields =
                  array
                  ->Array.map(JSON.Decode.string)
                  ->Array.filterMap(x => x)
                  ->Array.map(deserializeTransactionField)
                  ->Array.filterMap(x => x)
                Some(decodedFields)
              }
            | None => None
            }
          | None => None
          }

          let logFields = switch getFieldSelectionField("log") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) => {
                let decodedFields =
                  array
                  ->Array.map(JSON.Decode.string)
                  ->Array.filterMap(x => x)
                  ->Array.map(deserializeLogField)
                  ->Array.filterMap(x => x)
                Some(decodedFields)
              }
            | None => None
            }
          | None => None
          }

          let traceFields = switch getFieldSelectionField("trace") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) => {
                let decodedFields =
                  array
                  ->Array.map(JSON.Decode.string)
                  ->Array.filterMap(x => x)
                  ->Array.map(deserializeTraceField)
                  ->Array.filterMap(x => x)
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
            logs,
            transactions,
            traces: None,
            blocks,
            includeAllBlocks: None,
            fieldSelection,
            maxNumBlocks,
            maxNumTransactions,
            maxNumLogs,
            maxNumTraces: None,
            joinMode,
          }

          // Parse selectedChainName
          let selectedChainName = switch getField("selectedChainName") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.string(value) {
              | Some(name) => Some(name)
              | None => None
              }
            }
          | None => None
          }

          Some({
            query,
            selectedChainName,
          })
        }
      | None => None
      }
    }
  | exception _ => None
  }
}

// Encode state to compressed base64url format
let encodeUrlStateToUrl = (state: urlState): string => {
  let jsonString = serializeUrlState(state)
  compressToBase64Url(jsonString)
}

// Decode state from URL, with backwards compatibility for old URL-encoded format
let decodeUrlStateFromUrl = (encodedString: string): option<urlState> => {
  // First, try the new compressed base64url format
  switch decompressFromBase64Url(encodedString) {
  | Some(jsonString) => deserializeUrlState(jsonString)
  | None =>
    // Fall back to legacy URL-encoded format for backwards compatibility
    if isLegacyUrlEncoded(encodedString) {
      try {
        let decodedString = decodeURIComponent(encodedString)
        deserializeUrlState(decodedString)
      } catch {
      | _ => None
      }
    } else {
      None
    }
  }
}

let getUrlStateFromUrl = (): option<urlState> => {
  // Get the search string from window.location using proper bindings
  let locationObj = location(window)
  let searchStr = search(locationObj)

  // Simple URL parameter parsing without Js.Url
  if String.startsWith(searchStr, "?q=") {
    let encodedQuery = String.substring(searchStr, ~start=3, ~end=String.length(searchStr))
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

/* let getUrlStateFromUrl = (): option<urlState> => {
  let url = RescriptReactRouter.dangerouslyGetInitialUrl()
  let searchStr = url.search
  let params = searchStr->Js.String.split("&")
  switch Array.find(params, p => Js.String.startsWith(p, "q=")) {
  | Some(param) =>
    let encodedQuery = Js.String2.sliceToEnd(param, ~from=2)
    decodeUrlStateFromUrl(encodedQuery)
  | None => None
  }
}

let updateUrlWithState = (state: urlState) => {
  let encodedState = encodeUrlStateToUrl(state)
  RescriptReactRouter.push("/?q=" ++ encodedState)
} */

// Backward compatibility functions for existing code
let serializeQuery = (query: query): string => {
  serializeUrlState({query, selectedChainName: None})
}

let deserializeQuery = (jsonString: string): option<query> => {
  switch deserializeUrlState(jsonString) {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let encodeQueryToUrl = (query: query): string => {
  encodeUrlStateToUrl({query, selectedChainName: None})
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
  updateUrlWithState({query, selectedChainName: None})
}
