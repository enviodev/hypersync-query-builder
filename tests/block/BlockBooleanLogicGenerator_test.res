open Test
open BlockBooleanLogicGenerator
open QueryStructure

test("generateEnglishDescription - empty block filter", () => {
  let state = {hash: None, miner: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "No filters applied - will match all blocks")
})

test("generateEnglishDescription - single block hash", () => {
  let state = {hash: Some(["0x1234567890abcdef"]), miner: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match blocks where: the block hash is 0x1234567890abcdef")
})

test("generateEnglishDescription - multiple block hashes", () => {
  let state = {hash: Some(["0x1234567890abcdef", "0xfedcba0987654321"]), miner: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match blocks where: the block hash is 0x1234567890abcdef OR 0xfedcba0987654321")
})

test("generateEnglishDescription - single miner", () => {
  let state = {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match blocks where: the miner address is 0xea674fdde714fd979de3edf0f56aa9716b898ec8")
})

test("generateEnglishDescription - multiple miners", () => {
  let state = {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match blocks where: the miner address is 0xea674fdde714fd979de3edf0f56aa9716b898ec8 OR 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5")
})

test("generateEnglishDescription - hash and miner combined", () => {
  let state = {hash: Some(["0x1234567890abcdef"]), miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match blocks where: the block hash is 0x1234567890abcdef AND the miner address is 0xea674fdde714fd979de3edf0f56aa9716b898ec8")
})

test("generateEnglishDescription - multiple hashes and miners", () => {
  let state = {
    hash: Some(["0x1234567890abcdef", "0xfedcba0987654321"]), 
    miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])
  }
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match blocks where: the block hash is 0x1234567890abcdef OR 0xfedcba0987654321 AND the miner address is 0xea674fdde714fd979de3edf0f56aa9716b898ec8 OR 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5")
})

test("generateBooleanHierarchy - empty block filter", () => {
  let state = {hash: None, miner: None}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "No filters")
})

test("generateBooleanHierarchy - single block hash", () => {
  let state = {hash: Some(["0x1234567890abcdef"]), miner: None}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "hash = 0x1234567890abcdef")
})

test("generateBooleanHierarchy - multiple block hashes", () => {
  let state = {hash: Some(["0x1234567890abcdef", "0xfedcba0987654321"]), miner: None}
  let result = generateBooleanHierarchy(state)
  let expected = "OR (hash)\n├── 0x1234567890abcdef\n└── 0xfedcba0987654321"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - single miner", () => {
  let state = {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "miner = 0xea674fdde714fd979de3edf0f56aa9716b898ec8")
})

test("generateBooleanHierarchy - multiple miners", () => {
  let state = {hash: None, miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])}
  let result = generateBooleanHierarchy(state)
  let expected = "OR (miner)\n├── 0xea674fdde714fd979de3edf0f56aa9716b898ec8\n└── 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - hash and miner combined", () => {
  let state = {hash: Some(["0x1234567890abcdef"]), miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])}
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── hash = 0x1234567890abcdef\n└── miner = 0xea674fdde714fd979de3edf0f56aa9716b898ec8"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - multiple hashes and single miner", () => {
  let state = {hash: Some(["0x1234567890abcdef", "0xfedcba0987654321"]), miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8"])}
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── OR (hash)\n│   ├── 0x1234567890abcdef\n│   └── 0xfedcba0987654321\n└── miner = 0xea674fdde714fd979de3edf0f56aa9716b898ec8"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - single hash and multiple miners", () => {
  let state = {hash: Some(["0x1234567890abcdef"]), miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])}
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── hash = 0x1234567890abcdef\n└── OR (miner)\n    ├── 0xea674fdde714fd979de3edf0f56aa9716b898ec8\n    └── 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - multiple hashes and miners", () => {
  let state = {
    hash: Some(["0x1234567890abcdef", "0xfedcba0987654321"]), 
    miner: Some(["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"])
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── OR (hash)\n│   ├── 0x1234567890abcdef\n│   └── 0xfedcba0987654321\n└── OR (miner)\n    ├── 0xea674fdde714fd979de3edf0f56aa9716b898ec8\n    └── 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - real-world mining pools", () => {
  let state = {
    hash: None, 
    miner: Some([
      "0xea674fdde714fd979de3edf0f56aa9716b898ec8", // Ethermine
      "0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5", // Nanopool
      "0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c"  // Spark Pool
    ])
  }
  let result = generateBooleanHierarchy(state)
  let expected = "OR (miner)\n├── 0xea674fdde714fd979de3edf0f56aa9716b898ec8\n├── 0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5\n└── 0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - specific block analysis", () => {
  let state = {
    hash: Some([
      "0x88e96d4537bea4d9c05d12549907b32561d3bf31f45aae734cdc119f13406cb6", // Famous block
      "0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3"  // Another block
    ]), 
    miner: None
  }
  let result = generateBooleanHierarchy(state)
  let expected = "OR (hash)\n├── 0x88e96d4537bea4d9c05d12549907b32561d3bf31f45aae734cdc119f13406cb6\n└── 0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3"
  assertEqual(result, expected)
}) 
