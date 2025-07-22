open Test
open TransactionBooleanLogicGenerator
open QueryStructure

test("generateEnglishDescription - empty transaction filter", () => {
  let state = {from_: None, to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "No filters applied - will match all transactions")
})

test("generateEnglishDescription - single from address", () => {
  let state = {from_: Some(["0x1234567890"]), to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the sender address is 0x1234567890")
})

test("generateEnglishDescription - multiple from addresses", () => {
  let state = {from_: Some(["0x1234", "0x5678"]), to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the sender address is 0x1234 OR 0x5678")
})

test("generateEnglishDescription - single to address", () => {
  let state = {from_: None, to_: Some(["0xabcd"]), sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the recipient address is 0xabcd")
})

test("generateEnglishDescription - multiple to addresses", () => {
  let state = {from_: None, to_: Some(["0xabcd", "0xefgh"]), sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the recipient address is 0xabcd OR 0xefgh")
})

test("generateEnglishDescription - single sighash", () => {
  let state = {from_: None, to_: None, sighash: Some(["0xa9059cbb"]), status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the function signature is 0xa9059cbb")
})

test("generateEnglishDescription - multiple sighashes", () => {
  let state = {from_: None, to_: None, sighash: Some(["0xa9059cbb", "0x23b872dd"]), status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the function signature is 0xa9059cbb OR 0x23b872dd")
})

test("generateEnglishDescription - successful status", () => {
  let state = {from_: None, to_: None, sighash: None, status: Some(1), kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the transaction is successful")
})

test("generateEnglishDescription - failed status", () => {
  let state = {from_: None, to_: None, sighash: None, status: Some(0), kind: None, contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the transaction is failed")
})

test("generateEnglishDescription - single kind", () => {
  let state = {from_: None, to_: None, sighash: None, status: None, kind: Some([2]), contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the transaction kind is 2")
})

test("generateEnglishDescription - multiple kinds", () => {
  let state = {from_: None, to_: None, sighash: None, status: None, kind: Some([0, 2]), contractAddress: None, authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the transaction kind is 0 OR 2")
})

test("generateEnglishDescription - single contract address", () => {
  let state = {from_: None, to_: None, sighash: None, status: None, kind: None, contractAddress: Some(["0xA0b86a33E6441c8C06DD2F1ea9D25E4A7BB9A74e"]), authorizationList: None}
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the contract address is 0xA0b86a33E6441c8C06DD2F1ea9D25E4A7BB9A74e")
})

test("generateEnglishDescription - complex transaction filter", () => {
  let state = {
    from_: Some(["0x1234"]), 
    to_: Some(["0x5678"]), 
    sighash: Some(["0xa9059cbb"]), 
    status: Some(1), 
    kind: None, 
    contractAddress: None, 
    authorizationList: None
  }
  let result = generateEnglishDescription(state)
  assertEqual(result, "Match transactions where: the sender address is 0x1234 AND the recipient address is 0x5678 AND the function signature is 0xa9059cbb AND the transaction is successful")
})

test("generateBooleanHierarchy - empty transaction filter", () => {
  let state = {from_: None, to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "No filters")
})

test("generateBooleanHierarchy - single from address", () => {
  let state = {from_: Some(["0x1234567890"]), to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateBooleanHierarchy(state)
  assertEqual(result, "from = 0x1234567890")
})

test("generateBooleanHierarchy - multiple from addresses", () => {
  let state = {from_: Some(["0x1234", "0x5678"]), to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateBooleanHierarchy(state)
  let expected = "OR (from)\n├── 0x1234\n└── 0x5678"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - from and to addresses", () => {
  let state = {from_: Some(["0x1234"]), to_: Some(["0x5678"]), sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── from = 0x1234\n└── to = 0x5678"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - complex transaction with multiple conditions", () => {
  let state = {
    from_: Some(["0x1234", "0x5678"]), 
    to_: Some(["0xabcd"]), 
    sighash: Some(["0xa9059cbb", "0x23b872dd"]), 
    status: Some(1), 
    kind: Some([2]), 
    contractAddress: None, 
    authorizationList: None
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── OR (from)\n│   ├── 0x1234\n│   └── 0x5678\n├── to = 0xabcd\n├── OR (sighash)\n│   ├── 0xa9059cbb\n│   └── 0x23b872dd\n├── status = 1 (success)\n└── kind = 2"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - ERC20 transfer transaction", () => {
  let state = {
    from_: None, 
    to_: Some(["0xA0b86a33E6441c8C06DD2F1ea9D25E4A7BB9A74e"]), 
    sighash: Some(["0xa9059cbb"]), // ERC20 transfer signature
    status: Some(1), 
    kind: None, 
    contractAddress: None, 
    authorizationList: None
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── to = 0xA0b86a33E6441c8C06DD2F1ea9D25E4A7BB9A74e\n├── sighash = 0xa9059cbb\n└── status = 1 (success)"
  assertEqual(result, expected)
})

test("generateBooleanHierarchy - DEX swap transaction", () => {
  let state = {
    from_: Some(["0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"]), // Uniswap V2 Router
    to_: None, 
    sighash: Some(["0x38ed1739", "0x8803dbee"]), // swapExactTokensForTokens, swapTokensForExactTokens
    status: Some(1), 
    kind: None, 
    contractAddress: None, 
    authorizationList: None
  }
  let result = generateBooleanHierarchy(state)
  let expected = "AND\n├── from = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D\n├── OR (sighash)\n│   ├── 0x38ed1739\n│   └── 0x8803dbee\n└── status = 1 (success)"
  assertEqual(result, expected)
}) 
