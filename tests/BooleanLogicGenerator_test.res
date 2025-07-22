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
