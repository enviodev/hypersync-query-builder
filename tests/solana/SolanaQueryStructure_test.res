open Test
open SolanaQueryStructure

let contains = (haystack: string, needle: string): bool => String.includes(haystack, needle)

let baseQuery: query = {
  fromSlot: 437500000,
  toSlot: Some(437500002),
  instructionCalls: None,
  transactions: None,
  logs: None,
  accountActivity: None,
  includeAllBlocks: None,
  fieldSelection: emptyFieldSelection,
  maxNumBlocks: None,
  maxNumTransactions: None,
  maxNumInstructions: None,
  maxNumLogs: None,
  maxNumAccountActivity: None,
}

test("serializeQuery - projection key is field_selection, never fields", () => {
  let json = serializeQuery({
    ...baseQuery,
    fieldSelection: {...emptyFieldSelection, block: [Slot, Blockhash]},
  })
  assertEqual(contains(json, `"field_selection"`), true)
  assertEqual(contains(json, `"fields"`), false)
  assertEqual(contains(json, `"block": ["slot", "blockhash"]`), true)
})

test("serializeQuery - empty field selection still emits the key", () => {
  let json = serializeQuery(baseQuery)
  assertEqual(contains(json, `"field_selection": {}`), true)
})

test("serializeQuery - instruction selections use instruction_calls and executing_account", () => {
  let json = serializeQuery({
    ...baseQuery,
    instructionCalls: Some([
      {
        ...emptyInstructionSelection,
        executingAccount: Some(["TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"]),
        d1: Some(["0x03"]),
        isInner: Some(false),
        txSuccess: Some(true),
      },
    ]),
  })
  assertEqual(contains(json, `"instruction_calls"`), true)
  assertEqual(contains(json, `"instructions"`), false)
  assertEqual(
    contains(json, `"executing_account": ["TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"]`),
    true,
  )
  assertEqual(contains(json, `"program_id"`), false)
  assertEqual(contains(json, `"is_inner": false`), true)
  assertEqual(contains(json, `"tx_success": true`), true)
  assertEqual(contains(json, `"is_committed"`), false)
})

test("serializeQuery - no include_* join booleans are emitted", () => {
  let json = serializeQuery({
    ...baseQuery,
    instructionCalls: Some([emptyInstructionSelection]),
    transactions: Some([emptyTransactionSelection]),
    logs: Some([emptyLogSelection]),
  })
  assertEqual(contains(json, "include_transaction"), false)
  assertEqual(contains(json, "include_logs"), false)
  assertEqual(contains(json, "include_instruction"), false)
  assertEqual(contains(json, "include_account_activity"), false)
})

test("serializeQuery - transaction selection carries transaction_id and transaction_index", () => {
  let json = serializeQuery({
    ...baseQuery,
    transactions: Some([
      {
        ...emptyTransactionSelection,
        transactionId: Some(["5xSig"]),
        transactionIndex: Some([0, 7]),
        success: Some(false),
      },
    ]),
  })
  assertEqual(contains(json, `"transaction_id": ["5xSig"]`), true)
  assertEqual(contains(json, `"transaction_index": [0, 7]`), true)
  assertEqual(contains(json, `"success": false`), true)
})

test("serializeQuery - account activity selection, fields and cap", () => {
  let json = serializeQuery({
    ...baseQuery,
    accountActivity: Some([
      {...emptyAccountActivitySelection, kind: Some(["token"]), isFeePayer: Some(true)},
      emptyAccountActivitySelection,
    ]),
    fieldSelection: {
      ...emptyFieldSelection,
      accountActivity: [Slot, Account, PreTokenBalance, PostTokenBalance],
    },
    maxNumAccountActivity: Some(25),
  })
  assertEqual(contains(json, `"account_activity": [`), true)
  assertEqual(contains(json, `{"kind": ["token"], "is_fee_payer": true}`), true)
  // An empty selection is the "everything in range" request and must stay `{}`
  assertEqual(contains(json, "{}"), true)
  assertEqual(
    contains(
      json,
      `"account_activity": ["slot", "account", "pre_token_balance", "post_token_balance"]`,
    ),
    true,
  )
  assertEqual(contains(json, `"max_num_account_activity": 25`), true)
})

test("field selection drives the joins, so selectedTables reflects it", () => {
  assertEqual(selectedTables(emptyFieldSelection), [])
  assertEqual(
    selectedTables({
      ...emptyFieldSelection,
      transaction: defaultTransactionFields,
      instructionCall: defaultInstructionFields,
    }),
    [Transaction, InstructionCall],
  )
})

test("withTableDefaults gives a table columns and leaves an existing selection alone", () => {
  let seeded = withTableDefaults(emptyFieldSelection, Transaction)
  assertEqual(seeded.transaction, defaultTransactionFields)
  assertEqual(selectedTables(seeded), [Transaction])

  let custom = {...emptyFieldSelection, transaction: [Slot]}
  assertEqual(withTableDefaults(custom, Transaction).transaction, [Slot])
})

test("filter values are JSON-escaped, so quotes and backslashes cannot break the body", () => {
  let nasty = `we"ird\\value` ++ "\n\t"
  let json = serializeQuery({
    ...baseQuery,
    instructionCalls: Some([{...emptyInstructionSelection, executingAccount: Some([nasty])}]),
  })
  // The body has to stay parseable, and the value has to survive the round trip.
  let parsed = JSON.parseOrThrow(json)
  let roundTripped =
    parsed
    ->JSON.Decode.object
    ->Option.flatMap(d => Dict.get(d, "instruction_calls"))
    ->Option.flatMap(JSON.Decode.array)
    ->Option.flatMap(arr => arr->Array.get(0))
    ->Option.flatMap(JSON.Decode.object)
    ->Option.flatMap(d => Dict.get(d, "executing_account"))
    ->Option.flatMap(JSON.Decode.array)
    ->Option.flatMap(arr => arr->Array.get(0))
    ->Option.flatMap(JSON.Decode.string)
  assertEqual(roundTripped, Some(nasty))
})

test("instruction field wire names follow the v0.2.0 renames", () => {
  assertEqual(instructionFieldToSnake(ExecutingAccount), "executing_account")
  assertEqual(instructionFieldToSnake(AccountArguments), "account_arguments")
  assertEqual(instructionFieldToSnake(TxSuccess), "tx_success")
  assertEqual(transactionFieldToSnake(TransactionId), "transaction_id")
  assertEqual(accountActivityFieldToSnake(PostTokenBalance), "post_token_balance")
})
