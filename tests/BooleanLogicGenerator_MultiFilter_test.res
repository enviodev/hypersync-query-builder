open Test
open BooleanLogicGenerator
open QueryStructure

// Tests for Transaction Multi-Filter Functions

test("generateMultiTransactionFilterDescription - None case", () => {
  let filters = None
  let result = generateMultiTransactionFilterDescription(filters)
  assertEqual(result, "selecting None")
})

test("generateMultiTransactionFilterDescription - empty array", () => {
  let filters = Some([])
  let result = generateMultiTransactionFilterDescription(filters)
  assertEqual(result, "selecting None")
})

test("generateMultiTransactionFilterDescription - single empty filter", () => {
  let filters = Some([
    {
      from_: None,
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionFilterDescription(filters)
  assertEqual(result, "selecting ALL")
})

test("generateMultiTransactionFilterDescription - single filter with from", () => {
  let filters = Some([
    {
      from_: Some(["0x1234"]),
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionFilterDescription(filters)
  assertEqual(result, "Match transactions where: the sender address is 0x1234")
})

test("generateMultiTransactionFilterDescription - two filters with OR logic", () => {
  let filters = Some([
    {
      from_: Some(["0x1234"]),
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
    {
      from_: None,
      to_: Some(["0x5678"]),
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionFilterDescription(filters)
  assertEqual(
    result,
    "Match transactions where: the sender address is 0x1234 OR the recipient address is 0x5678",
  )
})

test("generateMultiTransactionFilterDescription - complex ERC20 scenario", () => {
  let filters = Some([
    // ERC20 Transfer
    {
      from_: None,
      to_: None,
      sighash: Some(["0xa9059cbb"]),
      status: Some(1),
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
    // ERC20 Approval
    {
      from_: None,
      to_: None,
      sighash: Some(["0x095ea7b3"]),
      status: Some(1),
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionFilterDescription(filters)
  assertEqual(
    result,
    "Match transactions where: (the function signature is 0xa9059cbb AND the transaction is successful) OR (the function signature is 0x095ea7b3 AND the transaction is successful)",
  )
})

test("generateMultiTransactionBooleanHierarchy - None case", () => {
  let filters = None
  let result = generateMultiTransactionBooleanHierarchy(filters)
  assertEqual(result, "No filters")
})

test("generateMultiTransactionBooleanHierarchy - empty array", () => {
  let filters = Some([])
  let result = generateMultiTransactionBooleanHierarchy(filters)
  assertEqual(result, "No filters")
})

test("generateMultiTransactionBooleanHierarchy - single empty filter", () => {
  let filters = Some([
    {
      from_: None,
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionBooleanHierarchy(filters)
  assertEqual(result, "All transactions")
})

test("generateMultiTransactionBooleanHierarchy - single non-empty filter", () => {
  let filters = Some([
    {
      from_: Some(["0x1234"]),
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionBooleanHierarchy(filters)
  assertEqual(result, "from = 0x1234")
})

test("generateMultiTransactionBooleanHierarchy - two simple filters", () => {
  let filters = Some([
    {
      from_: Some(["0x1234"]),
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
    {
      from_: None,
      to_: Some(["0x5678"]),
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionBooleanHierarchy(filters)
  let expected = "OR\n├── from = 0x1234\n└── to = 0x5678"
  assertEqual(result, expected)
})

test("generateMultiTransactionBooleanHierarchy - DEX multi-router scenario", () => {
  let filters = Some([
    // Uniswap V2 Router
    {
      from_: Some(["0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"]),
      to_: None,
      sighash: Some(["0x38ed1739"]),
      status: Some(1),
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
    // Uniswap V3 Router
    {
      from_: Some(["0xE592427A0AEce92De3Edee1F18E0157C05861564"]),
      to_: None,
      sighash: Some(["0x414bf389"]),
      status: Some(1),
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
  ])
  let result = generateMultiTransactionBooleanHierarchy(filters)
  let expected = "OR\n├── AND\n│   ├── from = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D\n│   ├── sighash = 0x38ed1739\n│   └── status = 1 (success)\n└── AND\n    ├── from = 0xE592427A0AEce92De3Edee1F18E0157C05861564\n    ├── sighash = 0x414bf389\n    └── status = 1 (success)"
  assertEqual(result, expected)
})

// Tests for Block Multi-Filter Functions

test("generateMultiBlockFilterDescription - None case", () => {
  let filters = None
  let result = generateMultiBlockFilterDescription(filters)
  assertEqual(result, "selecting None")
})

test("generateMultiBlockFilterDescription - empty array", () => {
  let filters = Some([])
  let result = generateMultiBlockFilterDescription(filters)
  assertEqual(result, "selecting None")
})

test("generateMultiBlockFilterDescription - single empty filter", () => {
  let filters = Some([{hash: None, miner: None}])
  let result = generateMultiBlockFilterDescription(filters)
  assertEqual(result, "selecting ALL")
})

test("generateMultiBlockFilterDescription - single filter with hash", () => {
  let filters = Some([{hash: Some(["0x1234567890abcdef"]), miner: None}])
  let result = generateMultiBlockFilterDescription(filters)
  assertEqual(result, "Match blocks where: the block hash is 0x1234567890abcdef")
})

test("generateMultiBlockFilterDescription - two filters with OR logic", () => {
  let filters = Some([
    {hash: Some(["0x1234567890abcdef"]), miner: None},
    {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])},
  ])
  let result = generateMultiBlockFilterDescription(filters)
  assertEqual(
    result,
    "Match blocks where: the block hash is 0x1234567890abcdef OR the miner address is 0xea674fdde714fd979de3edf0f56aa9716b898ec8",
  )
})

test("generateMultiBlockFilterDescription - mining pools scenario", () => {
  let filters = Some([
    // Ethermine pool
    {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])},
    // Nanopool
    {hash: None, miner: Some(["0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])},
    // Spark Pool
    {hash: None, miner: Some(["0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c"])},
  ])
  let result = generateMultiBlockFilterDescription(filters)
  assertEqual(
    result,
    "Match blocks where: the miner address is 0xea674fdde714fd979de3edf0f56aa9716b898ec8 OR the miner address is 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5 OR the miner address is 0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c",
  )
})

test("generateMultiBlockBooleanHierarchy - None case", () => {
  let filters = None
  let result = generateMultiBlockBooleanHierarchy(filters)
  assertEqual(result, "No filters")
})

test("generateMultiBlockBooleanHierarchy - empty array", () => {
  let filters = Some([])
  let result = generateMultiBlockBooleanHierarchy(filters)
  assertEqual(result, "No filters")
})

test("generateMultiBlockBooleanHierarchy - single empty filter", () => {
  let filters = Some([{hash: None, miner: None}])
  let result = generateMultiBlockBooleanHierarchy(filters)
  assertEqual(result, "All blocks")
})

test("generateMultiBlockBooleanHierarchy - single non-empty filter", () => {
  let filters = Some([{hash: Some(["0x1234567890abcdef"]), miner: None}])
  let result = generateMultiBlockBooleanHierarchy(filters)
  assertEqual(result, "hash = 0x1234567890abcdef")
})

test("generateMultiBlockBooleanHierarchy - two simple filters", () => {
  let filters = Some([
    {hash: Some(["0x1234567890abcdef"]), miner: None},
    {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])},
  ])
  let result = generateMultiBlockBooleanHierarchy(filters)
  let expected = "OR\n├── hash = 0x1234567890abcdef\n└── miner = 0xea674fdde714fd979de3edf0f56aa9716b898ec8"
  assertEqual(result, expected)
})

test("generateMultiBlockBooleanHierarchy - complex mining analysis", () => {
  let filters = Some([
    // Specific block with hash and miner
    {
      hash: Some(["0x88e96d4537bea4d9c05d12549907b32561d3bf31f45aae734cdc119f13406cb6"]),
      miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"]),
    },
    // Any block from Nanopool
    {hash: None, miner: Some(["0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])},
    // Multiple blocks from any miner
    {
      hash: Some([
        "0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3",
        "0x1234567890abcdef",
      ]),
      miner: None,
    },
  ])
  let result = generateMultiBlockBooleanHierarchy(filters)
  let expected = "OR\n├── AND\n│   ├── hash = 0x88e96d4537bea4d9c05d12549907b32561d3bf31f45aae734cdc119f13406cb6\n│   └── miner = 0xea674fdde714fd979de3edf0f56aa9716b898ec8\n├── miner = 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5\n└── OR (hash)\n    ├── 0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3\n    └── 0x1234567890abcdef"
  assertEqual(result, expected)
})

test("generateMultiBlockBooleanHierarchy - mix with empty filter", () => {
  let filters = Some([
    {hash: Some(["0x1234567890abcdef"]), miner: None},
    {hash: None, miner: None}, // Empty filter
    {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])},
  ])
  let result = generateMultiBlockBooleanHierarchy(filters)
  let expected = "OR\n├── hash = 0x1234567890abcdef\n├── miner = 0xea674fdde714fd979de3edf0f56aa9716b898ec8\n└── All blocks"
  assertEqual(result, expected)
})
