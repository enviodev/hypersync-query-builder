open Test
open BooleanLogicGenerator

open QueryStructure

test("generateEnglishDescription - empty state", () => {
  let state = {address: None, topics: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "No filters applied - will match all logs")
})

test("generateEnglishDescription - single address", () => {
  let state = {address: Some(["0x1234567890"]), topics: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: the contract address is 0x1234567890")
})

test("generateEnglishDescription - multiple address", () => {
  let state = {address: Some(["0x1234", "0x5678"]), topics: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: the contract address is 0x1234 OR 0x5678")
})

test("generateEnglishDescription - single topic", () => {
  let state = {address: None, topics: Some([["0xabcd"]])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: topic[0] is 0xabcd")
})

test("generateEnglishDescription - multiple topics in same position", () => {
  let state = {address: None, topics: Some([["0xabcd", "0xefgh"]])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: topic[0] is 0xabcd OR 0xefgh")
})

test("generateEnglishDescription - topics at different positions", () => {
  let state = {address: None, topics: Some([["0xabcd"], [], ["0xefgh"]])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: topic[0] is 0xabcd AND topic[2] is 0xefgh")
})

test("generateEnglishDescription - combined address and topics", () => {
  let state = {address: Some(["0x1234"]), topics: Some([["0xabcd"]])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: the contract address is 0x1234 AND topic[0] is 0xabcd")
})

test("generateEnglishDescription - complex scenario", () => {
  let state = {
    address: Some(["0x1234", "0x5678"]), 
    topics: Some([["0xabcd", "0xefgh"], [], ["0xijkl"]])
  }
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match logs where: the contract address is 0x1234 OR 0x5678 AND topic[0] is 0xabcd OR 0xefgh AND topic[2] is 0xijkl")
})

test("generateBooleanHierarchy - empty state", () => {
  let state = {address: None, topics: None}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "No filters")
})

test("generateBooleanHierarchy - single address", () => {
  let state = {address: Some(["0x1234567890"]), topics: None}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "address = 0x1234567890")
})

test("generateBooleanHierarchy - multiple address", () => {
  let state = {address: Some(["0x1234", "0x5678"]), topics: None}
  let result = generateBooleanHierarchy(state)
  let expected = "OR (address)\n├── 0x1234\n└── 0x5678"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - single topic", () => {
  let state = {address: None, topics: Some([["0xabcd"]])}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "topic[0] = 0xabcd")
})

test("generateBooleanHierarchy - multiple topics in same position", () => {
  let state = {address: None, topics: Some([["0xabcd", "0xefgh"]])}
  let result = generateBooleanHierarchy(state)
  let expected = "OR (topic[0])\n├── 0xabcd\n└── 0xefgh"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - topics at different positions", () => {
  let state = {address: None, topics: Some([["0xabcd"], [], ["0xefgh"]])}
  let result = generateBooleanHierarchy(state)
  let expected = "AND (topics)\n├── topic[0] = 0xabcd\n└── topic[2] = 0xefgh"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - address and single topic", () => {
  let state = {address: Some(["0x1234567890"]), topics: Some([["0xabcd"]])}
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── address = 0x1234567890\n└── topic[0] = 0xabcd"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - user's complex scenario with proper indentation", () => {
  let state = {
    address: Some(["0x1234567890123456789012345678901234567890"]),
    topics: Some([["0x1", "0x2", "0x3"], [], ["0x4"]])
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── address = 0x1234567890123456789012345678901234567890\n└── AND (topics)\n    ├── OR (topic[0])\n    │   ├── 0x1\n    │   ├── 0x2\n    │   └── 0x3\n    └── topic[2] = 0x4"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - user's multiple address with multiple topic arrays", () => {
  let state = {
    address: Some(["0xa", "0xb"]),
    topics: Some([["0x1"], [], ["0x2", "0x3"]])
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── OR (address)\n│   ├── 0xa\n│   └── 0xb\n└── AND (topics)\n    ├── topic[0] = 0x1\n    └── OR (topic[2])\n        ├── 0x2\n        └── 0x3"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - topic array with gaps maintains correct indexing", () => {
  let state = {
    address: None,
    topics: Some([["0x1", "0x2"], [], [], ["0x3"]])
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND (topics)\n├── OR (topic[0])\n│  ├── 0x1\n│  └── 0x2\n└── topic[3] = 0x3"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - complex scenario from user's original example", () => {
  let state = {
    address: Some(["0xa", "0xB"]),
    topics: Some([["0x1"], [], ["0x2", "0x3"]])
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── OR (address)\n│   ├── 0xa\n│   └── 0xB\n└── AND (topics)\n    ├── topic[0] = 0x1\n    └── OR (topic[2])\n        ├── 0x2\n        └── 0x3"
  assertEqual(result, expected)
})

// Tests for generateMultiFilterDescription

test("generateMultiFilterDescription - None case", () => {
  let filters = None
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "selecting None")
})

test("generateMultiFilterDescription - empty array", () => {
  let filters = Some([])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "selecting None")
})

test("generateMultiFilterDescription - single empty filter", () => {
  let filters = Some([{address: None, topics: None}])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "selecting ALL")
})

test("generateMultiFilterDescription - single filter with address", () => {
  let filters = Some([{address: Some(["0x1234"]), topics: None}])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: the contract address is 0x1234")
})

test("generateMultiFilterDescription - single filter with topic", () => {
  let filters = Some([{address: None, topics: Some([["0xabcd"]])}])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: topic[0] is 0xabcd")
})

test("generateMultiFilterDescription - two filters with addresses (OR logic)", () => {
  let filters = Some([
    {address: Some(["0x1234"]), topics: None},
    {address: Some(["0x5678"]), topics: None}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: the contract address is 0x1234 OR the contract address is 0x5678")
})

test("generateMultiFilterDescription - two filters with topics (OR logic)", () => {
  let filters = Some([
    {address: None, topics: Some([["0xaaa"]])},
    {address: None, topics: Some([["0xbbb"]])}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: topic[0] is 0xaaa OR topic[0] is 0xbbb")
})

test("generateMultiFilterDescription - complex filter with parentheses", () => {
  let filters = Some([
    {address: Some(["0x1234"]), topics: Some([["0xaaa"], [], ["0xbbb"]])},
    {address: Some(["0x5678"]), topics: None}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: (the contract address is 0x1234 AND topic[0] is 0xaaa AND topic[2] is 0xbbb) OR the contract address is 0x5678")
})

test("generateMultiFilterDescription - mix of empty and non-empty filters", () => {
  let filters = Some([
    {address: None, topics: None},
    {address: Some(["0x1234"]), topics: None},
    {address: Some(["0x5678"]), topics: Some([["0xaaa"]])}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: ALL logs OR the contract address is 0x1234 OR (the contract address is 0x5678 AND topic[0] is 0xaaa)")
})

test("generateMultiFilterDescription - multiple complex filters", () => {
  let filters = Some([
    {address: Some(["0x1111", "0x2222"]), topics: Some([["0xaaa", "0xbbb"]])},
    {address: Some(["0x3333"]), topics: Some([["0xccc"], [], ["0xddd", "0xeee"]])},
    {address: None, topics: Some([["0xfff"]])}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: (the contract address is 0x1111 OR 0x2222 AND topic[0] is 0xaaa OR 0xbbb) OR (the contract address is 0x3333 AND topic[0] is 0xccc AND topic[2] is 0xddd OR 0xeee) OR topic[0] is 0xfff")
})

test("generateMultiFilterDescription - real-world scenario: ERC20 Transfer OR Approval", () => {
  let filters = Some([
    // ERC20 Transfer event: Transfer(address,address,uint256)
    {address: None, topics: Some([["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]])},
    // ERC20 Approval event: Approval(address,address,uint256)  
    {address: None, topics: Some([["0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"]])}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: topic[0] is 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef OR topic[0] is 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925")
})

test("generateMultiFilterDescription - DEX scenario: Uniswap V2/V3 swaps", () => {
  let filters = Some([
    // Uniswap V2 Swap
    {address: Some(["0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"]), topics: Some([["0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822"]])},
    // Uniswap V3 Swap  
    {address: Some(["0x1F98431c8aD98523631AE4a59f267346ea31F984"]), topics: Some([["0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67"]])},
    // Any contract with generic swap topic
    {address: None, topics: Some([["0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1"]])}
  ])
  let result = generateMultiFilterDescription(filters)
  assertEqual(result, "Match logs where: (the contract address is 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f AND topic[0] is 0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822) OR (the contract address is 0x1F98431c8aD98523631AE4a59f267346ea31F984 AND topic[0] is 0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67) OR topic[0] is 0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1")
})

// Tests for generateMultiBooleanHierarchy

test("generateMultiBooleanHierarchy - None case", () => {
  let filters = None
  let result = generateMultiBooleanHierarchy(filters)
  assertEqual(result, "No filters")
})

test("generateMultiBooleanHierarchy - empty array", () => {
  let filters = Some([])
  let result = generateMultiBooleanHierarchy(filters)
  assertEqual(result, "No filters")
})

test("generateMultiBooleanHierarchy - single empty filter", () => {
  let filters = Some([{address: None, topics: None}])
  let result = generateMultiBooleanHierarchy(filters)
  assertEqual(result, "All logs")
})

test("generateMultiBooleanHierarchy - single non-empty filter", () => {
  let filters = Some([{address: Some(["0x1234"]), topics: None}])
  let result = generateMultiBooleanHierarchy(filters)
  assertEqual(result, "address = 0x1234")
})

test("generateMultiBooleanHierarchy - single complex filter", () => {
  let filters = Some([{address: Some(["0x1234"]), topics: Some([["0xaaa"], [], ["0xbbb"]])}])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "AND\n├── address = 0x1234\n└── AND (topics)\n    ├── topic[0] = 0xaaa\n    └── topic[2] = 0xbbb"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - two simple filters", () => {
  let filters = Some([
    {address: Some(["0x1234"]), topics: None},
    {address: Some(["0x5678"]), topics: None}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── address = 0x1234\n└── address = 0x5678"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - three simple filters", () => {
  let filters = Some([
    {address: Some(["0x1111"]), topics: None},
    {address: Some(["0x2222"]), topics: None},
    {address: Some(["0x3333"]), topics: None}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── address = 0x1111\n├── address = 0x2222\n└── address = 0x3333"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - mix with empty filter", () => {
  let filters = Some([
    {address: Some(["0x1234"]), topics: None},
    {address: None, topics: None},
    {address: Some(["0x5678"]), topics: None}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── address = 0x1234\n├── address = 0x5678\n└── All logs"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - complex filters with proper indentation", () => {
  let filters = Some([
    {address: Some(["0x1234"]), topics: Some([["0xaaa"], [], ["0xbbb"]])},
    {address: Some(["0x5678"]), topics: None}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── AND\n│   ├── address = 0x1234\n│   └── AND (topics)\n│       ├── topic[0] = 0xaaa\n│       └── topic[2] = 0xbbb\n└── address = 0x5678"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - multiple complex filters", () => {
  let filters = Some([
    {address: Some(["0x1111", "0x2222"]), topics: Some([["0xaaa"]])},
    {address: Some(["0x3333"]), topics: Some([["0xbbb"], [], ["0xccc", "0xddd"]])},
    {address: None, topics: Some([["0xeee"]])}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── AND\n│   ├── OR (address)\n│   │   ├── 0x1111\n│   │   └── 0x2222\n│   └── topic[0] = 0xaaa\n├── AND\n│   ├── address = 0x3333\n│   └── AND (topics)\n│       ├── topic[0] = 0xbbb\n│       └── OR (topic[2])\n│           ├── 0xccc\n│           └── 0xddd\n└── topic[0] = 0xeee"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - real-world ERC20 events", () => {
  let filters = Some([
    // ERC20 Transfer
    {address: None, topics: Some([["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]])},
    // ERC20 Approval
    {address: None, topics: Some([["0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"]])}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── topic[0] = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef\n└── topic[0] = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"
  assertEqual(result, expected)
})

test("generateMultiBooleanHierarchy - DEX scenario with complex nesting", () => {
  let filters = Some([
    // Uniswap V2 factory with Swap event
    {address: Some(["0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"]), topics: Some([["0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822"]])},
    // Multiple DEX routers with Transfer events  
    {address: Some(["0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", "0xE592427A0AEce92De3Edee1F18E0157C05861564"]), topics: Some([["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]])},
    // Any swap event regardless of contract
    {address: None, topics: Some([["0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1"]])}
  ])
  let result = generateMultiBooleanHierarchy(filters)
  let expected = "OR\n├── AND\n│   ├── address = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f\n│   └── topic[0] = 0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822\n├── AND\n│   ├── OR (address)\n│   │   ├── 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D\n│   │   └── 0xE592427A0AEce92De3Edee1F18E0157C05861564\n│   └── topic[0] = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef\n└── topic[0] = 0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1"
  assertEqual(result, expected)
})
