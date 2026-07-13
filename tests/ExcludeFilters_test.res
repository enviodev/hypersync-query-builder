open Test
open QueryStructure

// Tests for exclude filters: English descriptions, boolean hierarchies,
// emptiness checks, and URL round-tripping.

let emptyTransactionFields: transactionSelection = {
  from_: None,
  to_: None,
  sighash: None,
  status: None,
  type_: None,
  contractAddress: None,
  hash: None,
  authorizationList: None,
}

let emptyTraceFields: traceSelection = {
  from_: None,
  to_: None,
  address: None,
  callType: None,
  rewardType: None,
  type_: None,
  sighash: None,
}

// Log filters

test("log english description - include with exclude", () => {
  let state: logSelection = {
    address: None,
    topics: Some([["0xaaa"]]),
    exclude: {address: Some(["0xbbb"]), topics: None},
  }
  let result = BooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(result, "Match logs where: topic[0] is 0xaaa AND NOT (the contract address is 0xbbb)")
})

test("log english description - exclude only", () => {
  let state: logSelection = {
    address: None,
    topics: None,
    exclude: {address: Some(["0xbbb"]), topics: None},
  }
  let result = BooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(result, "Match logs where: NOT (the contract address is 0xbbb)")
})

test("log english description - multi-condition include is parenthesised with exclude", () => {
  let state: logSelection = {
    address: Some(["0x1"]),
    topics: Some([["0x2"]]),
    exclude: {address: Some(["0x3"]), topics: None},
  }
  let result = BooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(
    result,
    "Match logs where: (the contract address is 0x1 AND topic[0] is 0x2) AND NOT (the contract address is 0x3)",
  )
})

test("log english description - empty exclude is ignored", () => {
  let state: logSelection = {
    address: Some(["0x1"]),
    topics: None,
    exclude: {address: None, topics: None},
  }
  let result = BooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(result, "Match logs where: the contract address is 0x1")
})

test("log boolean hierarchy - include with exclude", () => {
  let state: logSelection = {
    address: None,
    topics: Some([["0xaaa"]]),
    exclude: {address: Some(["0xbbb"]), topics: None},
  }
  let result = BooleanLogicGenerator.generateBooleanHierarchy(state)
  assertEqual(
    result,
    "AND\n├── topic[0] = 0xaaa\n└── NOT\n    └── address = 0xbbb",
  )
})

test("log boolean hierarchy - exclude only", () => {
  let state: logSelection = {
    address: None,
    topics: None,
    exclude: {address: Some(["0xbbb"]), topics: None},
  }
  let result = BooleanLogicGenerator.generateBooleanHierarchy(state)
  assertEqual(result, "NOT\n└── address = 0xbbb")
})

test("log boolean hierarchy - multi-line exclude tree is indented", () => {
  let state: logSelection = {
    address: None,
    topics: None,
    exclude: {address: Some(["0xbbb"]), topics: Some([["0xccc"]])},
  }
  let result = BooleanLogicGenerator.generateBooleanHierarchy(state)
  assertEqual(
    result,
    "NOT\n└── AND\n    ├── address = 0xbbb\n    └── topic[0] = 0xccc",
  )
})

test("log isEmptyFilter - exclude-only filter is not empty", () => {
  let state: logSelection = {
    address: None,
    topics: None,
    exclude: {address: Some(["0xbbb"]), topics: None},
  }
  assertEqual(BooleanLogicGenerator.isEmptyFilter(state), false)
})

test("log isEmptyFilter - filter with empty exclude is empty", () => {
  let state: logSelection = {
    address: None,
    topics: None,
    exclude: {address: None, topics: None},
  }
  assertEqual(BooleanLogicGenerator.isEmptyFilter(state), true)
})

test("log multi-filter description - filter with exclude", () => {
  let filters = Some([
    (
      {
        address: None,
        topics: Some([["0xaaa"]]),
        exclude: {address: Some(["0xbbb"]), topics: None},
      }: logSelection
    ),
  ])
  let result = BooleanLogicGenerator.generateMultiFilterDescription(filters)
  assertEqual(
    result,
    "Match logs where: (topic[0] is 0xaaa AND NOT (the contract address is 0xbbb))",
  )
})

// Transaction filters

test("transaction english description - include with exclude", () => {
  let state: transactionSelection = {
    ...emptyTransactionFields,
    from_: Some(["0xa"]),
    exclude: {...emptyTransactionFields, to_: Some(["0xb"])},
  }
  let result = TransactionBooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(
    result,
    "Match transactions where: the sender address is 0xa AND NOT (the recipient address is 0xb)",
  )
})

test("transaction boolean hierarchy - exclude only", () => {
  let state: transactionSelection = {
    ...emptyTransactionFields,
    exclude: {...emptyTransactionFields, to_: Some(["0xb"])},
  }
  let result = TransactionBooleanLogicGenerator.generateBooleanHierarchy(state)
  assertEqual(result, "NOT\n└── to = 0xb")
})

// Block filters

test("block english description - include with exclude", () => {
  let state: blockSelection = {
    hash: None,
    miner: Some(["0xm"]),
    exclude: {hash: Some(["0xh"]), miner: None},
  }
  let result = BlockBooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(
    result,
    "Match blocks where: the miner address is 0xm AND NOT (the block hash is 0xh)",
  )
})

test("block boolean hierarchy - include with exclude", () => {
  let state: blockSelection = {
    hash: None,
    miner: Some(["0xm"]),
    exclude: {hash: Some(["0xh"]), miner: None},
  }
  let result = BlockBooleanLogicGenerator.generateBooleanHierarchy(state)
  assertEqual(result, "AND\n├── miner = 0xm\n└── NOT\n    └── hash = 0xh")
})

// Trace filters

test("trace english description - exclude only", () => {
  let state: traceSelection = {
    ...emptyTraceFields,
    exclude: {...emptyTraceFields, callType: Some(["call"])},
  }
  let result = TraceBooleanLogicGenerator.generateEnglishDescription(state)
  assertEqual(result, "Match traces where: NOT (the call type is call)")
})

// URL round-trip

test("url encode and decode - selections with excludes survive the round trip", () => {
  let query: query = {
    fromBlock: 0,
    toBlock: None,
    logs: Some([
      {
        address: None,
        topics: Some([["0xaaa"]]),
        exclude: {address: Some(["0xbbb"]), topics: None},
      },
    ]),
    transactions: Some([
      {
        ...emptyTransactionFields,
        from_: Some(["0xa"]),
        exclude: {...emptyTransactionFields, to_: Some(["0xb"])},
      },
    ]),
    traces: None,
    blocks: Some([
      {
        hash: None,
        miner: Some(["0xm"]),
        exclude: {hash: Some(["0xh"]), miner: None},
      },
    ]),
    includeAllBlocks: None,
    fieldSelection: {
      block: [Number],
      transaction: [Hash],
      log: [Address],
      trace: [],
    },
    maxNumBlocks: None,
    maxNumTransactions: None,
    maxNumLogs: None,
    maxNumTraces: None,
    joinMode: None,
  }
  let state: UrlEncoder.urlState = {query, selectedChainName: Some("eth")}
  let encoded = UrlEncoder.encodeUrlStateToUrl(state)
  switch UrlEncoder.decodeUrlStateFromUrl(encoded) {
  | Some(decoded) =>
    assertEqual(UrlEncoder.serializeUrlState(decoded), UrlEncoder.serializeUrlState(state))
  | None => assertEqual(true, false)
  }
})

test("url decode - urls without exclude keys still decode", () => {
  // Simulates a URL generated before exclude support existed
  let legacyJson = `{"query":{"fromBlock":0,"toBlock":null,"logs":[{"address":["0x1"],"topics":null}],"transactions":null,"blocks":null,"fieldSelection":{"block":[],"transaction":[],"log":["address"],"trace":[]}},"selectedChainName":"eth"}`
  switch UrlEncoder.deserializeUrlState(legacyJson) {
  | Some(decoded) =>
    switch decoded.query.logs {
    | Some([log]) => {
        assertEqual(log.address, Some(["0x1"]))
        assertEqual(log.exclude, None)
      }
    | _ => assertEqual(true, false)
    }
  | None => assertEqual(true, false)
  }
})

test("url decode - nested excludes are dropped (single exclude level)", () => {
  // A hand-crafted URL payload with exclude.exclude: only one level is kept,
  // matching the server's Selection<T> type
  let jsonWithNestedExclude = `{"query":{"fromBlock":0,"toBlock":null,"logs":[{"address":null,"topics":[["0xaaa"]],"exclude":{"address":["0xbbb"],"topics":null,"exclude":{"address":["0xccc"],"topics":null}}}],"transactions":null,"blocks":null,"fieldSelection":{"block":[],"transaction":[],"log":["address"],"trace":[]}},"selectedChainName":"eth"}`
  switch UrlEncoder.deserializeUrlState(jsonWithNestedExclude) {
  | Some(decoded) =>
    switch decoded.query.logs {
    | Some([log]) =>
      switch log.exclude {
      | Some(ex) => {
          assertEqual(ex.address, Some(["0xbbb"]))
          assertEqual(ex.exclude, None)
        }
      | None => assertEqual(true, false)
      }
    | _ => assertEqual(true, false)
    }
  | None => assertEqual(true, false)
  }
})
