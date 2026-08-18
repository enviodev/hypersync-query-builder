open SolanaQueryStructure

// Common Solana Programs
let tokenProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
let token2022ProgramId = "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"
let systemProgramId = "11111111111111111111111111111111"
let computeBudgetProgramId = "ComputeBudget111111111111111111111111111111"
let orcaWhirlpoolProgramId = "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc"
let jupiterV6ProgramId = "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4"

// Anchor 8-byte discriminator for Whirlpool's `swap` instruction
let whirlpoolSwapD8 = "0xf8c69e91e17587c8"

// Demo fee payer used when the user has not entered one
let demoFeePayer = "MfDuWeqSHEqTFVYZ7LoexgAK9dxk7cy4DFJWjWMGVWa"

// Looks like a base58 Solana pubkey (32-44 base58 chars)
let looksLikePubkey = (s: string): bool => {
  let len = String.length(s)
  if len < 32 || len > 44 {
    false
  } else {
    let re = RegExp.fromString("^[1-9A-HJ-NP-Za-km-z]+$")
    RegExp.test(re, s)
  }
}

@react.component
let make = (~bearerToken: option<string>, ~onTokenSubmit: string => unit) => {
  let defaultQuery = (): query => {
    fromSlot: 0,
    toSlot: None,
    instructionCalls: None,
    transactions: None,
    logs: None,
    accountActivity: None,
    includeAllBlocks: None,
    fieldSelection: emptyFieldSelection,
    maxNumBlocks: Some(10),
    maxNumTransactions: Some(10),
    maxNumInstructions: Some(50),
    maxNumLogs: Some(50),
    maxNumAccountActivity: Some(50),
  }

  let (query, setQuery) = React.useState(() => defaultQuery())
  let (expandedFilterKey, setExpandedFilterKey) = React.useState(() => None)
  let (executeSignal, setExecuteSignal) = React.useState(() => 0)
  let (currentHead, setCurrentHead) = React.useState(() => None)
  let (quickStartFeePayer, setQuickStartFeePayer) = React.useState(() => "")
  let (endpointUrl, setEndpointUrl) = React.useState(() => defaultEndpoint)

  // Fetch the selected endpoint's head so users can pick a sensible from_slot
  React.useEffect1(() => {
    let load = async () => {
      try {
        open Fetch
        let response = await fetchSimple(`${endpointUrl}/height`)
        let text = await response->Response.text
        switch Int.fromString(String.trim(text)) {
        | Some(n) =>
          setCurrentHead(_ => Some(n))
          // A from_slot of 0 is below every endpoint's history floor, and the server
          // silently fast-forwards instead of erroring, so seed a usable default.
          setQuery(prev => prev.fromSlot === 0 ? {...prev, fromSlot: n - 100} : prev)
        | None => ()
        }
      } catch {
      | _ => ()
      }
    }
    load()->ignore
    None
  }, [endpointUrl])

  let toggleFilter = key =>
    setExpandedFilterKey(prev =>
      switch prev {
      | Some(p) => p === key ? None : Some(key)
      | None => Some(key)
      }
    )

  let resetBuilder = () => {
    setExpandedFilterKey(_ => None)
    setQuickStartFeePayer(_ => "")
    setQuery(_ => defaultQuery())
  }

  // Filter management
  let addInstructionFilter = () => {
    let newIndex = query.instructionCalls->Option.getOr([])->Array.length
    setQuery(prev => {
      ...prev,
      instructionCalls: Some(
        Array.concat(prev.instructionCalls->Option.getOr([]), [emptyInstructionSelection]),
      ),
    })
    setExpandedFilterKey(_ => Some(`instruction-${Int.toString(newIndex)}`))
  }

  let updateInstructionFilter = (index, newFilter) =>
    setQuery(prev => {
      let cur = prev.instructionCalls->Option.getOr([])
      let next = Array.mapWithIndex(cur, (f, i) => i === index ? newFilter : f)
      {...prev, instructionCalls: Some(next)}
    })

  let removeInstructionFilter = index => {
    setQuery(prev => {
      let cur = prev.instructionCalls->Option.getOr([])
      let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== index)
      {...prev, instructionCalls: Array.length(next) > 0 ? Some(next) : None}
    })
    let key = `instruction-${Int.toString(index)}`
    setExpandedFilterKey(prev => prev === Some(key) ? None : prev)
  }

  let addTransactionFilter = () => {
    let newIndex = query.transactions->Option.getOr([])->Array.length
    setQuery(prev => {
      ...prev,
      transactions: Some(
        Array.concat(prev.transactions->Option.getOr([]), [emptyTransactionSelection]),
      ),
    })
    setExpandedFilterKey(_ => Some(`transaction-${Int.toString(newIndex)}`))
  }

  let updateTransactionFilter = (index, newFilter) =>
    setQuery(prev => {
      let cur = prev.transactions->Option.getOr([])
      let next = Array.mapWithIndex(cur, (f, i) => i === index ? newFilter : f)
      {...prev, transactions: Some(next)}
    })

  let removeTransactionFilter = index => {
    setQuery(prev => {
      let cur = prev.transactions->Option.getOr([])
      let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== index)
      {...prev, transactions: Array.length(next) > 0 ? Some(next) : None}
    })
    let key = `transaction-${Int.toString(index)}`
    setExpandedFilterKey(prev => prev === Some(key) ? None : prev)
  }

  let addLogFilter = () => {
    let newIndex = query.logs->Option.getOr([])->Array.length
    setQuery(prev => {
      ...prev,
      logs: Some(Array.concat(prev.logs->Option.getOr([]), [emptyLogSelection])),
    })
    setExpandedFilterKey(_ => Some(`log-${Int.toString(newIndex)}`))
  }

  let updateLogFilter = (index, newFilter) =>
    setQuery(prev => {
      let cur = prev.logs->Option.getOr([])
      let next = Array.mapWithIndex(cur, (f, i) => i === index ? newFilter : f)
      {...prev, logs: Some(next)}
    })

  let removeLogFilter = index => {
    setQuery(prev => {
      let cur = prev.logs->Option.getOr([])
      let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== index)
      {...prev, logs: Array.length(next) > 0 ? Some(next) : None}
    })
    let key = `log-${Int.toString(index)}`
    setExpandedFilterKey(prev => prev === Some(key) ? None : prev)
  }

  let updateFieldSelection = newFields => setQuery(prev => {...prev, fieldSelection: newFields})

  // Joins follow field_selection, so "also return table X" just means "give table X
  // some columns". This is what the removed include_* booleans were pretending to do.
  let includeTableFields = (table: string) =>
    setQuery(prev => {
      let fs = prev.fieldSelection
      let next = switch table {
      | "block" => {...fs, block: Array.length(fs.block) > 0 ? fs.block : defaultBlockFields}
      | "transaction" => {
          ...fs,
          transaction: Array.length(fs.transaction) > 0 ? fs.transaction : defaultTransactionFields,
        }
      | "instruction_call" => {
          ...fs,
          instructionCall: Array.length(fs.instructionCall) > 0
            ? fs.instructionCall
            : defaultInstructionFields,
        }
      | "log" => {...fs, log: Array.length(fs.log) > 0 ? fs.log : defaultLogFields}
      | "account_activity" => {
          ...fs,
          accountActivity: Array.length(fs.accountActivity) > 0
            ? fs.accountActivity
            : defaultAccountActivityFields,
        }
      | _ => fs
      }
      {...prev, fieldSelection: next}
    })

  let currentTables = selectedTables(query.fieldSelection)

  // Account activity filter management
  let addAccountActivityFilter = () => {
    let newIndex = query.accountActivity->Option.getOr([])->Array.length
    setQuery(prev => {
      ...prev,
      accountActivity: Some(
        Array.concat(prev.accountActivity->Option.getOr([]), [emptyAccountActivitySelection]),
      ),
    })
    setExpandedFilterKey(_ => Some(`account-activity-${Int.toString(newIndex)}`))
  }

  let updateAccountActivityFilter = (index, newFilter) =>
    setQuery(prev => {
      let cur = prev.accountActivity->Option.getOr([])
      let next = Array.mapWithIndex(cur, (f, i) => i === index ? newFilter : f)
      {...prev, accountActivity: Some(next)}
    })

  let removeAccountActivityFilter = index => {
    setQuery(prev => {
      let cur = prev.accountActivity->Option.getOr([])
      let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== index)
      {...prev, accountActivity: Array.length(next) > 0 ? Some(next) : None}
    })
    let key = `account-activity-${Int.toString(index)}`
    setExpandedFilterKey(prev => prev === Some(key) ? None : prev)
  }

  // Quick start presets
  let applyPresetSplTokenTransfers = () => {
    let from = switch currentHead {
    | Some(h) => h - 5
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 5),
      instructionCalls: Some([
        {
          ...emptyInstructionSelection,
          executingAccount: Some([tokenProgramId]),
          d1: Some(["0x03"]),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Fee],
        instructionCall: [Slot, TransactionIndex, ExecutingAccount, Data, A0, A1, A2, D1],
      },
      maxNumBlocks: Some(5),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(100),
    })
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  let applyPresetSystemTransfers = () => {
    let from = switch currentHead {
    | Some(h) => h - 5
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 5),
      instructionCalls: Some([
        {
          ...emptyInstructionSelection,
          executingAccount: Some([systemProgramId]),
          d4: Some(["0x02000000"]),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success],
        instructionCall: [Slot, TransactionIndex, ExecutingAccount, Data, A0, A1, D4],
      },
      maxNumBlocks: Some(5),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(100),
    })
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // include_all_blocks pulls every block in the slot range. Combined with a wide
  // field_selection (account_activity in particular) even a few slots are many MB,
  // so keep the range tight by default.
  let applyPresetAllBlocks = () => {
    let from = switch currentHead {
    | Some(h) => h - 2
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 2),
      includeAllBlocks: Some(true),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, ParentSlot, BlockTime, BlockHeight],
      },
      maxNumBlocks: Some(2),
    })
  }

  // Token-2022 transfers - same d1 byte as classic SPL Token, but a different program ID.
  // Useful for showing devs the modern alternative to TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA.
  let applyPresetToken2022Transfers = () => {
    let from = switch currentHead {
    | Some(h) => h - 5
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 5),
      instructionCalls: Some([
        {
          ...emptyInstructionSelection,
          executingAccount: Some([token2022ProgramId]),
          d1: Some(["0x03"]),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Fee],
        instructionCall: [Slot, TransactionIndex, ExecutingAccount, Data, A0, A1, A2, D1],
      },
      maxNumBlocks: Some(5),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(100),
    })
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Orca Whirlpool swaps - Anchor program filtered by its 8-byte swap discriminator.
  let applyPresetWhirlpoolSwaps = () => {
    let from = switch currentHead {
    | Some(h) => h - 5
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 5),
      instructionCalls: Some([
        {
          ...emptyInstructionSelection,
          executingAccount: Some([orcaWhirlpoolProgramId]),
          d8: Some([whirlpoolSwapD8]),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Err, Fee],
        instructionCall: [
          Slot,
          TransactionIndex,
          InstructionAddress,
          ExecutingAccount,
          AccountArguments,
          Data,
          D8,
          IsInner,
        ],
      },
      maxNumBlocks: Some(5),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(100),
    })
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Multi-DEX OR - two separate instruction_calls[] entries combine with OR semantics.
  // Each entry only sets executing_account, so any ix from either Jupiter v6 or Whirlpool matches.
  let applyPresetJupiterOrOrca = () => {
    let from = switch currentHead {
    | Some(h) => h - 3
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 3),
      instructionCalls: Some([
        {
          ...emptyInstructionSelection,
          executingAccount: Some([jupiterV6ProgramId]),
        },
        {
          ...emptyInstructionSelection,
          executingAccount: Some([orcaWhirlpoolProgramId]),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Fee],
        instructionCall: [
          Slot,
          TransactionIndex,
          InstructionAddress,
          ExecutingAccount,
          Data,
          D8,
          IsInner,
        ],
      },
      maxNumBlocks: Some(3),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(150),
    })
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Failed transactions - transaction-side filter using success: false.
  // Only transaction columns are selected: the server's trim policy keeps no
  // instruction rows for failed transactions, so an instruction table would be empty.
  let applyPresetFailedTransactions = () => {
    let from = switch currentHead {
    | Some(h) => h - 3
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 3),
      transactions: Some([
        {
          ...emptyTransactionSelection,
          success: Some(false),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [
          Slot,
          TransactionIndex,
          Signatures,
          FeePayer,
          Success,
          Err,
          Fee,
          ComputeUnitsConsumed,
        ],
      },
      maxNumBlocks: Some(3),
      maxNumTransactions: Some(50),
    })
    setExpandedFilterKey(_ => Some("transaction-0"))
  }

  // Transactions by fee payer - inverse direction. Filter on the transactions table;
  // selecting instruction_call columns pulls the instructions of those transactions.
  let applyPresetTxnsByFeePayer = () => {
    let from = switch currentHead {
    | Some(h) => h - 50
    | None => historyFloorSlot
    }
    let payer = if looksLikePubkey(quickStartFeePayer) {
      quickStartFeePayer
    } else {
      demoFeePayer
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 50),
      transactions: Some([
        {
          ...emptyTransactionSelection,
          feePayer: Some([payer]),
        },
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [
          Slot,
          TransactionIndex,
          Signatures,
          FeePayer,
          Success,
          Err,
          Fee,
          ComputeUnitsConsumed,
        ],
        instructionCall: [
          Slot,
          TransactionIndex,
          InstructionAddress,
          ExecutingAccount,
          AccountArguments,
          Data,
          D8,
        ],
      },
      maxNumBlocks: Some(50),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(500),
    })
    setExpandedFilterKey(_ => Some("transaction-0"))
  }

  // Every account activity row in a tight range: an empty selection matches all.
  // There is no include_account_activity flag any more.
  let applyPresetAccountActivity = () => {
    let from = switch currentHead {
    | Some(h) => h - 1
    | None => historyFloorSlot
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 1),
      accountActivity: Some([emptyAccountActivitySelection]),
      fieldSelection: {
        ...emptyFieldSelection,
        accountActivity: defaultAccountActivityFields,
      },
      maxNumAccountActivity: Some(200),
    })
    setExpandedFilterKey(_ => Some("account-activity-0"))
  }

  // Everything a wallet touched. `account` is the wallet on native rows but the token
  // account on token rows, so this needs two selections: account = W OR owner = W.
  let applyPresetWalletActivity = () => {
    let from = switch currentHead {
    | Some(h) => h - 50
    | None => historyFloorSlot
    }
    let wallet = if looksLikePubkey(quickStartFeePayer) {
      quickStartFeePayer
    } else {
      demoFeePayer
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 50),
      accountActivity: Some([
        {...emptyAccountActivitySelection, account: Some([wallet])},
        {...emptyAccountActivitySelection, owner: Some([wallet])},
      ]),
      fieldSelection: {
        ...emptyFieldSelection,
        transaction: [Slot, TransactionIndex, TransactionId, FeePayer, Success],
        accountActivity: allAccountActivityFields,
      },
      maxNumAccountActivity: Some(200),
      maxNumTransactions: Some(50),
    })
    setExpandedFilterKey(_ => Some("account-activity-0"))
  }

  let totalFilters =
    Array.length(query.instructionCalls->Option.getOr([])) +
    Array.length(query.transactions->Option.getOr([])) +
    Array.length(query.logs->Option.getOr([])) +
    Array.length(query.accountActivity->Option.getOr([]))

  <>
    {!AuthToken.isValidToken(bearerToken)
      ? <TokenPrompt onTokenSubmit={onTokenSubmit} />
      : React.null}
    <main className="flex-1 overflow-hidden bg-slate-50">
      // Experimental notice banner
      <div className="bg-amber-50 border-b border-amber-200 px-6 py-3">
        <div className="max-w-6xl mx-auto flex items-start gap-3">
          <div className="shrink-0 mt-0.5">
            <svg
              className="w-5 h-5 text-amber-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
          </div>
          <div className="flex-1 text-sm text-amber-900">
            <p className="font-semibold mb-1"> {"Solana support is experimental"->React.string} </p>
            <p className="mb-1">
              {"This is a preview release. The schema, endpoints, and behavior may change before the official launch. We will be expanding the historical slot range over time as the integration matures."->React.string}
            </p>
            <p>
              {"Have questions or feedback? Reach out on "->React.string}
              <a
                href="https://discord.com/invite/envio"
                target="_blank"
                rel="noopener noreferrer"
                className="font-medium text-amber-900 underline hover:text-amber-700"
              >
                {"Discord"->React.string}
              </a>
              {"."->React.string}
            </p>
          </div>
        </div>
      </div>

      <div className="h-full flex flex-col lg:flex-row">
        // Left Column - Builder
        <div className="w-full lg:w-1/2 overflow-y-auto">
          <div className="p-6 lg:p-4 lg:pr-2">
            <div className="mb-6 flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-slate-900 mb-1">
                  {"Create Your Solana Query"->React.string}
                </h2>
                <p className="text-sm text-slate-600">
                  {"Build and test HyperSync Solana queries with a visual interface"->React.string}
                </p>
              </div>
              <button
                onClick={_ => resetBuilder()}
                className="inline-flex items-center px-3 py-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 rounded-lg border border-slate-200 transition-colors"
              >
                {"Reset"->React.string}
              </button>
            </div>

            <div className="space-y-6">
              // Section 1: Configuration
              <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
                <div className="mb-4">
                  <h3 className="text-lg font-semibold text-slate-900">
                    {"Network & Slot Range"->React.string}
                  </h3>
                  <p className="text-sm text-slate-600">
                    {"Pick an endpoint and a slot range"->React.string}
                  </p>
                </div>

                <div className="mb-4">
                  <div className="flex flex-wrap gap-2 mb-2">
                    {endpoints
                    ->Array.map(ep => {
                      let isActive = ep.host === endpointUrl
                      <button
                        key={ep.host}
                        onClick={_ => setEndpointUrl(_ => ep.host)}
                        title={ep.note}
                        className={`px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors ${isActive
                            ? "bg-slate-800 text-white border-slate-800"
                            : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}
                      >
                        {ep.label->React.string}
                      </button>
                    })
                    ->React.array}
                  </div>
                  <div className="px-3 py-2 rounded-md bg-blue-50 border border-blue-200">
                    <div className="flex items-center justify-between">
                      <div className="text-xs text-blue-700 font-mono">
                        {endpointUrl->React.string}
                      </div>
                      {switch currentHead {
                      | Some(h) =>
                        <span className="text-xs text-blue-700">
                          {`current head: slot ${Int.toString(h)}`->React.string}
                        </span>
                      | None => React.null
                      }}
                    </div>
                    <p className="mt-1 text-[11px] text-blue-800">
                      {`History starts around slot ${Int.toString(
                          historyFloorSlot,
                        )}. Below an endpoint's floor the server does not error: it fast-forwards next_slot to the floor, so an early from_slot silently returns nothing.`->React.string}
                    </p>
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
                  <div>
                    <label className="block text-xs font-medium text-slate-700 mb-1">
                      {"From Slot"->React.string}
                    </label>
                    <input
                      type_="number"
                      value={Int.toString(query.fromSlot)}
                      onChange={e => {
                        let target = ReactEvent.Form.target(e)
                        let v = Int.fromString(target["value"])->Option.getOr(0)
                        setQuery(prev => {...prev, fromSlot: v})
                      }}
                      className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-slate-500"
                      placeholder="0"
                    />
                    {switch currentHead {
                    | Some(h) =>
                      <button
                        onClick={_ => setQuery(prev => {...prev, fromSlot: h - 100})}
                        className="mt-1 text-xs text-blue-600 hover:text-blue-800"
                      >
                        {`Use head - 100 (${Int.toString(h - 100)})`->React.string}
                      </button>
                    | None => React.null
                    }}
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-slate-700 mb-1">
                      {"To Slot (Optional)"->React.string}
                    </label>
                    <input
                      type_="number"
                      value={switch query.toSlot {
                      | Some(s) => Int.toString(s)
                      | None => ""
                      }}
                      onChange={e => {
                        let target = ReactEvent.Form.target(e)
                        let value = target["value"]
                        setQuery(prev => {
                          ...prev,
                          toSlot: value === "" ? None : Int.fromString(value),
                        })
                      }}
                      className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-slate-500"
                      placeholder="Latest slot"
                    />
                  </div>
                </div>

                <p className="text-[11px] text-slate-500 mb-2">
                  {"The max_num_* knobs are approximate server-side bounds, not exact caps: a response can overshoot them."->React.string}
                </p>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
                  {[
                    (
                      "max_num_blocks",
                      query.maxNumBlocks,
                      n => setQuery(prev => {...prev, maxNumBlocks: n}),
                    ),
                    (
                      "max_num_transactions",
                      query.maxNumTransactions,
                      n => setQuery(prev => {...prev, maxNumTransactions: n}),
                    ),
                    (
                      "max_num_instructions",
                      query.maxNumInstructions,
                      n => setQuery(prev => {...prev, maxNumInstructions: n}),
                    ),
                    (
                      "max_num_logs",
                      query.maxNumLogs,
                      n => setQuery(prev => {...prev, maxNumLogs: n}),
                    ),
                    (
                      "max_num_account_activity",
                      query.maxNumAccountActivity,
                      n => setQuery(prev => {...prev, maxNumAccountActivity: n}),
                    ),
                  ]
                  ->Array.map(((label, value, onSet)) =>
                    <div key={label}>
                      <label className="block text-xs font-medium text-slate-700 mb-1">
                        {label->React.string}
                      </label>
                      <input
                        type_="number"
                        value={switch value {
                        | Some(v) => Int.toString(v)
                        | None => ""
                        }}
                        onChange={e => {
                          let target = ReactEvent.Form.target(e)
                          let v = target["value"]
                          onSet(v === "" ? None : Int.fromString(v))
                        }}
                        className="w-full px-2 py-1.5 border border-slate-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-slate-500"
                        placeholder="none"
                      />
                    </div>
                  )
                  ->React.array}
                </div>

                <div>
                  <label className="inline-flex items-center text-xs text-slate-700 cursor-pointer">
                    <input
                      type_="checkbox"
                      checked={query.includeAllBlocks->Option.getOr(false)}
                      onChange={e => {
                        let target = ReactEvent.Form.target(e)
                        setQuery(prev => {
                          ...prev,
                          includeAllBlocks: target["checked"] ? Some(true) : None,
                        })
                      }}
                      className="mr-2"
                    />
                    {"include_all_blocks (return every block in range)"->React.string}
                  </label>
                </div>

                // Quick Start
                <div className="mt-6">
                  <div className="mb-3">
                    <h4 className="text-sm font-medium text-slate-900">
                      {"Quick start"->React.string}
                    </h4>
                    <p className="text-xs text-slate-600">
                      {"Start from a popular Solana template - each one teaches a different filter pattern"->React.string}
                    </p>
                  </div>
                  <div className="mb-3 flex items-center gap-2">
                    <input
                      type_="text"
                      value={quickStartFeePayer}
                      onChange={e => {
                        let target = ReactEvent.Form.target(e)
                        setQuickStartFeePayer(_ => target["value"])
                      }}
                      placeholder="Pubkey for the 'Txns by Fee Payer' and 'Wallet Activity' presets (base58)"
                      className="flex-1 border border-slate-300 rounded-lg px-3 py-1.5 text-xs font-mono focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition-colors"
                    />
                    <span className="text-[11px] text-slate-500">
                      {if String.length(quickStartFeePayer) === 0 {
                        "Defaults to a demo address"
                      } else if looksLikePubkey(quickStartFeePayer) {
                        "Looks valid"
                      } else {
                        "Not a valid base58 pubkey"
                      }->React.string}
                    </span>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={_ => applyPresetSplTokenTransfers()}
                      title="SPL Token Transfer ix - filtered by program_id and the 1-byte d1 discriminator"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"SPL Token Transfers (d1)"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetToken2022Transfers()}
                      title="Token-2022 Transfer ix - same d1 byte, different program ID"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"Token-2022 Transfers (d1)"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetSystemTransfers()}
                      title="System Program transfer (lamports) - native programs use 4-byte LE u32 indices"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"System SOL Transfers (d4)"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetWhirlpoolSwaps()}
                      title="Orca Whirlpool swap - Anchor programs use 8-byte hash discriminators"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"Whirlpool Swaps (d8 Anchor)"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetJupiterOrOrca()}
                      title="Two entries in the instruction_calls[] array combine with OR semantics"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"Jupiter OR Orca (multi-filter OR)"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetFailedTransactions()}
                      title="Filter on the transactions table by success: false. No instruction rows are kept for failed transactions, so only transaction columns are selected"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"Failed Transactions"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetTxnsByFeePayer()}
                      title="Inverse direction - filter txs by fee_payer; selecting instruction columns pulls their instructions"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"Txns by Fee Payer"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetAccountActivity()}
                      title="account_activity: [{}] - an empty selection returns every activity row in the range"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"All Account Activity"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetWalletActivity()}
                      title="Everything one wallet touched - two selections, account = W OR owner = W"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"Wallet Activity (account OR owner)"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetAllBlocks()}
                      title="include_all_blocks: true - returns every block in the slot range"
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"All Blocks"->React.string}
                    </button>
                  </div>
                </div>
              </div>

              // Section 2: Filters
              <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
                <div className="flex items-center mb-4">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-slate-900">
                      {"Add Filters"->React.string}
                    </h3>
                    <p className="text-sm text-slate-600">
                      {"Define what data you want: "->React.string}
                      <span className="font-medium"> {"instructions"->React.string} </span>
                      {", "->React.string}
                      <span className="font-medium"> {"transactions"->React.string} </span>
                      {", "->React.string}
                      <span className="font-medium"> {"logs"->React.string} </span>
                      {", "->React.string}
                      <span className="font-medium"> {"account activity"->React.string} </span>
                    </p>
                  </div>
                  {totalFilters > 0
                    ? <span
                        className="ml-auto inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700"
                      >
                        {`${Int.toString(totalFilters)} filter${totalFilters === 1
                            ? ""
                            : "s"}`->React.string}
                      </span>
                    : React.null}
                </div>

                <div className="mb-6">
                  <div className="flex flex-wrap gap-3">
                    <button
                      onClick={_ => addInstructionFilter()}
                      className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 transition-colors"
                    >
                      {"+ Instruction Filter"->React.string}
                    </button>
                    <button
                      onClick={_ => addTransactionFilter()}
                      className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 transition-colors"
                    >
                      {"+ Transaction Filter"->React.string}
                    </button>
                    <button
                      onClick={_ => addLogFilter()}
                      className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 transition-colors"
                    >
                      {"+ Log Filter"->React.string}
                    </button>
                    <button
                      onClick={_ => addAccountActivityFilter()}
                      className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 transition-colors"
                    >
                      {"+ Account Activity Filter"->React.string}
                    </button>
                  </div>
                </div>

                {totalFilters > 0
                  ? <div className="grid gap-4">
                      {query.instructionCalls
                      ->Option.getOr([])
                      ->Array.mapWithIndex((f, i) =>
                        <SolanaInstructionFilter
                          key={`instruction-${Int.toString(i)}`}
                          filterState={f}
                          onFilterChange={updateInstructionFilter(i, _)}
                          onRemove={() => removeInstructionFilter(i)}
                          filterIndex={i}
                          isExpanded={expandedFilterKey === Some(`instruction-${Int.toString(i)}`)}
                          onToggleExpand={() => toggleFilter(`instruction-${Int.toString(i)}`)}
                          selectedTables={currentTables}
                          onIncludeTable={includeTableFields}
                        />
                      )
                      ->React.array}
                      {query.transactions
                      ->Option.getOr([])
                      ->Array.mapWithIndex((f, i) =>
                        <SolanaTransactionFilter
                          key={`transaction-${Int.toString(i)}`}
                          filterState={f}
                          onFilterChange={updateTransactionFilter(i, _)}
                          onRemove={() => removeTransactionFilter(i)}
                          filterIndex={i}
                          isExpanded={expandedFilterKey === Some(`transaction-${Int.toString(i)}`)}
                          onToggleExpand={() => toggleFilter(`transaction-${Int.toString(i)}`)}
                          selectedTables={currentTables}
                          onIncludeTable={includeTableFields}
                        />
                      )
                      ->React.array}
                      {query.logs
                      ->Option.getOr([])
                      ->Array.mapWithIndex((f, i) =>
                        <SolanaLogFilter
                          key={`log-${Int.toString(i)}`}
                          filterState={f}
                          onFilterChange={updateLogFilter(i, _)}
                          onRemove={() => removeLogFilter(i)}
                          filterIndex={i}
                          isExpanded={expandedFilterKey === Some(`log-${Int.toString(i)}`)}
                          onToggleExpand={() => toggleFilter(`log-${Int.toString(i)}`)}
                          selectedTables={currentTables}
                          onIncludeTable={includeTableFields}
                        />
                      )
                      ->React.array}
                      {query.accountActivity
                      ->Option.getOr([])
                      ->Array.mapWithIndex((f, i) =>
                        <SolanaAccountActivityFilter
                          key={`account-activity-${Int.toString(i)}`}
                          filterState={f}
                          onFilterChange={updateAccountActivityFilter(i, _)}
                          onRemove={() => removeAccountActivityFilter(i)}
                          filterIndex={i}
                          isExpanded={expandedFilterKey ===
                            Some(`account-activity-${Int.toString(i)}`)}
                          onToggleExpand={() => toggleFilter(`account-activity-${Int.toString(i)}`)}
                          selectedTables={currentTables}
                          onIncludeTable={includeTableFields}
                        />
                      )
                      ->React.array}
                    </div>
                  : <div
                      className="text-center py-8 border-2 border-dashed border-slate-300 rounded-lg"
                    >
                      <h4 className="text-sm font-medium text-slate-600 mb-1">
                        {"No filters added yet"->React.string}
                      </h4>
                      <p className="text-xs text-slate-500">
                        {"Click a button above to add your first filter, or use include_all_blocks to query every block in the slot range."->React.string}
                      </p>
                    </div>}
              </div>

              // Section 3: Field Selection
              <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
                <div className="flex items-center mb-4">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-slate-900">
                      {"Select Fields"->React.string}
                    </h3>
                    <p className="text-sm text-slate-600">
                      {"Choose which fields each table should return. Empty = no rows."->React.string}
                    </p>
                  </div>
                </div>
                <SolanaFieldSelector
                  fieldSelection={query.fieldSelection}
                  onFieldSelectionChange={updateFieldSelection}
                />
              </div>
            </div>
          </div>
        </div>

        // Right Column - Results
        <div className="w-full lg:w-1/2 overflow-y-auto">
          <div className="p-6 lg:p-4 lg:pl-2">
            <div className="mb-6 flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-slate-900 mb-2">
                  {"Query Results"->React.string}
                </h2>
                <p className="text-slate-600">
                  {"View your generated query, execute it, and see the results."->React.string}
                </p>
              </div>
              <div className="flex items-center">
                <button
                  onClick={_ => setExecuteSignal(prev => prev + 1)}
                  className="inline-flex items-center px-3 py-1.5 text-xs font-medium text-white bg-slate-700 hover:bg-slate-800 rounded-lg border border-slate-700 transition-colors"
                >
                  {"Execute Query"->React.string}
                </button>
              </div>
            </div>
            <SolanaQueryResults
              query={query}
              executeSignal={executeSignal}
              bearerToken={bearerToken}
              endpointUrl={endpointUrl}
            />
          </div>
        </div>
      </div>
    </main>
  </>
}
