%%raw(`import './App.css'`)
%%raw(`import './tailwind.css'`)

open QueryStructure

type preset = {
  title: string,
  description: string,
  apply: unit => unit,
}

@react.component
let make = () => {
  let (query, setQuery) = React.useState(() => {
    switch UrlEncoder.getUrlStateFromUrl() {
    | Some(urlState) => urlState.query
    | None => {
        fromSlot: 0,
        toSlot: None,
        instructions: None,
        transactions: None,
        includeAllBlocks: None,
        fieldSelection: {
          block: [],
          transaction: [],
          instruction: [],
        },
        maxNumBlocks: Some(10),
        maxNumTransactions: Some(10),
        maxNumInstructions: Some(10),
      }
    }
  })

  let (expandedFilterKey, setExpandedFilterKey) = React.useState(() => None)
  let (executeSignal, setExecuteSignal) = React.useState(() => 0)

  let toggleFilter = key =>
    setExpandedFilterKey(prev =>
      switch prev {
      | Some(prevKey) =>
        if prevKey === key {
          None
        } else {
          Some(key)
        }
      | None => Some(key)
      }
    )

  let resetBuilder = () => {
    setExpandedFilterKey(_ => None)
    setQuery(_ => {
      fromSlot: 0,
      toSlot: None,
      instructions: None,
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: Some(10),
      maxNumInstructions: Some(10),
    })
  }

  // Preset: Block metadata across a slot range
  let applyPresetBlocks = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505505),
      instructions: None,
      transactions: None,
      includeAllBlocks: Some(true),
      fieldSelection: {
        block: [Slot, Blockhash, BlockTime, BlockHeight],
        transaction: [],
        instruction: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: None,
      maxNumInstructions: None,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => None)
  }

  // Preset: Jupiter v6 aggregator swaps
  let applyPresetJupiter = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505510),
      instructions: Some([
        {
          program_id: Some(["JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D8, Accounts, A0, Data, IsInner],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(50),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: Raydium AMM v4 — pool swaps and liquidity
  let applyPresetRaydium = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505510),
      instructions: Some([
        {
          program_id: Some(["675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D1, Accounts, A0, Data, IsInner],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(50),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: Pump.fun bonding curve token launches
  let applyPresetPumpFun = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505510),
      instructions: Some([
        {
          program_id: Some(["6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D8, Accounts, A0, Data, IsInner],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(50),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: SPL Token Program — transfers, mints, burns
  let applyPresetTokenProgram = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505502),
      instructions: Some([
        {
          program_id: Some(["TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D1, Accounts, A0],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(50),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: System Program — SOL transfers and account creation
  let applyPresetSystemProgram = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505502),
      instructions: Some([
        {
          program_id: Some(["11111111111111111111111111111111"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D1, Accounts, A0, Data],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(50),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: Jupiter OR Raydium — cross-DEX activity via OR filter
  let applyPresetDexOr = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505510),
      instructions: Some([
        {
          program_id: Some(["JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
        {
          program_id: Some(["675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D1, D8, Accounts, IsInner],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(100),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: Top-level instructions only — exclude CPI inner calls
  let applyPresetOuterOnly = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505501),
      instructions: Some([
        {
          program_id: None,
          d1: None,
          d8: None,
          a0: None,
          is_inner: Some(false),
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, IsInner, D1],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(100),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // Preset: Successful transactions
  let applyPresetSuccessfulTxns = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505502),
      instructions: None,
      transactions: Some([
        {
          fee_payer: None,
          success: Some(true),
        },
      ]),
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Fee],
        instruction: [],
      },
      maxNumBlocks: None,
      maxNumTransactions: Some(50),
      maxNumInstructions: None,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("transaction-0"))
  }

  // Preset: Failed transactions
  let applyPresetFailedTxns = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505502),
      instructions: None,
      transactions: Some([
        {
          fee_payer: None,
          success: Some(false),
        },
      ]),
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Err],
        instruction: [],
      },
      maxNumBlocks: None,
      maxNumTransactions: Some(50),
      maxNumInstructions: None,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("transaction-0"))
  }

  // Preset: Orca Whirlpool — concentrated liquidity swaps
  let applyPresetOrca = () => {
    let preset: query = {
      fromSlot: 382505500,
      toSlot: Some(382505510),
      instructions: Some([
        {
          program_id: Some(["whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc"]),
          d1: None,
          d8: None,
          a0: None,
          is_inner: None,
        },
      ]),
      transactions: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        instruction: [Slot, TransactionIndex, ProgramId, D8, Accounts, A0, Data, IsInner],
      },
      maxNumBlocks: None,
      maxNumTransactions: None,
      maxNumInstructions: Some(50),
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  let presets = [
    {
      title: "Block Metadata",
      description: "Slot, blockhash, time across a 5-slot range",
      apply: applyPresetBlocks,
    },
    {
      title: "Jupiter v6",
      description: "DEX aggregator swaps (JUP6Lkb...)",
      apply: applyPresetJupiter,
    },
    {
      title: "Raydium AMM v4",
      description: "AMM pool swaps & liquidity (675kPX9...)",
      apply: applyPresetRaydium,
    },
    {
      title: "Pump.fun",
      description: "Bonding curve token launches (6EF8rre...)",
      apply: applyPresetPumpFun,
    },
    {
      title: "Orca Whirlpool",
      description: "Concentrated liquidity swaps (whirLbM...)",
      apply: applyPresetOrca,
    },
    {
      title: "SPL Token Program",
      description: "Token transfers, mints & burns",
      apply: applyPresetTokenProgram,
    },
    {
      title: "System Program",
      description: "SOL transfers & account creation",
      apply: applyPresetSystemProgram,
    },
    {
      title: "Jupiter OR Raydium",
      description: "Cross-DEX activity via OR filter",
      apply: applyPresetDexOr,
    },
    {
      title: "Outer Only",
      description: "Top-level instructions, no CPI inner calls",
      apply: applyPresetOuterOnly,
    },
    {
      title: "Successful Txns",
      description: "Filter transactions by success=true",
      apply: applyPresetSuccessfulTxns,
    },
    {
      title: "Failed Txns",
      description: "Inspect failed transactions & errors",
      apply: applyPresetFailedTxns,
    },
  ]

  // Update URL when query changes
  React.useEffect1(() => {
    UrlEncoder.updateUrlWithState({query, selectedChainName: None})
    None
  }, [query])

  let updateFieldSelection = (newFieldSelection: fieldSelection) => {
    setQuery(prev => {...prev, fieldSelection: newFieldSelection})
  }

  let addInstructionFilter = () => {
    let newIndex = query.instructions->Option.getOr([])->Array.length
    let newFilter: instructionSelection = {
      program_id: None,
      d1: None,
      d8: None,
      a0: None,
      is_inner: None,
    }
    setQuery(prev => {
      ...prev,
      instructions: Some(Array.concat(prev.instructions->Option.getOr([]), [newFilter])),
    })
    setExpandedFilterKey(_ => Some(`instruction-${Int.toString(newIndex)}`))
  }

  let updateInstructionFilter = (index: int, newFilter: instructionSelection) => {
    setQuery(prev => {
      let current = prev.instructions->Option.getOr([])
      let updated = Array.mapWithIndex(current, (filter, i) => i === index ? newFilter : filter)
      {...prev, instructions: Some(updated)}
    })
  }

  let removeInstructionFilter = (index: int) => {
    setQuery(prev => {
      let current = prev.instructions->Option.getOr([])
      let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
      {...prev, instructions: Array.length(updated) > 0 ? Some(updated) : None}
    })
    let key = `instruction-${Int.toString(index)}`
    setExpandedFilterKey(prev =>
      if prev === Some(key) {
        None
      } else {
        prev
      }
    )
  }

  let addTransactionFilter = () => {
    let newIndex = query.transactions->Option.getOr([])->Array.length
    let newFilter: transactionSelection = {
      fee_payer: None,
      success: None,
    }
    setQuery(prev => {
      ...prev,
      transactions: Some(Array.concat(prev.transactions->Option.getOr([]), [newFilter])),
    })
    setExpandedFilterKey(_ => Some(`transaction-${Int.toString(newIndex)}`))
  }

  let updateTransactionFilter = (index: int, newFilter: transactionSelection) => {
    setQuery(prev => {
      let current = prev.transactions->Option.getOr([])
      let updated = Array.mapWithIndex(current, (filter, i) => i === index ? newFilter : filter)
      {...prev, transactions: Some(updated)}
    })
  }

  let removeTransactionFilter = (index: int) => {
    setQuery(prev => {
      let current = prev.transactions->Option.getOr([])
      let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
      {
        ...prev,
        transactions: Array.length(updated) > 0 ? Some(updated) : None,
      }
    })
    let key = `transaction-${Int.toString(index)}`
    setExpandedFilterKey(prev =>
      if prev === Some(key) {
        None
      } else {
        prev
      }
    )
  }

  <main className="flex-1 overflow-hidden bg-slate-50">
    <div className="h-full flex flex-col lg:flex-row">
      // Left Column - Query Builder
      <div className="w-full lg:w-1/2 overflow-y-auto">
        <div className="p-6 lg:p-4 lg:pr-2">
          <div className="mb-8 flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold text-slate-900 mb-1">
                {"Create Your Query"->React.string}
              </h2>
              <p className="text-sm text-slate-600">
                {"Build and test Solana HyperSync queries with a visual interface"->React.string}
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
              <div className="flex items-center mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-slate-900">
                    {"Configuration"->React.string}
                  </h3>
                  <p className="text-sm text-slate-600">
                    {"Configure slot range and query limits"->React.string}
                  </p>
                </div>
              </div>

              // Advanced Options
              <AdvancedOptions query={query} onQueryChange={newQuery => setQuery(_ => newQuery)} />

              // Quick Start Templates
              <div className="mt-6">
                <div className="flex items-center justify-between mb-3">
                  <div>
                    <h4 className="text-sm font-medium text-slate-900">
                      {"Quick start"->React.string}
                    </h4>
                    <p className="text-xs text-slate-600">
                      {"Start from an example Solana query"->React.string}
                    </p>
                  </div>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-2 xl:grid-cols-3 gap-2">
                  {presets->Array.mapWithIndex((p, i) =>
                    <button
                      key={Int.toString(i)}
                      onClick={_ => p.apply()}
                      className="flex flex-col items-start px-3 py-2 text-left rounded-lg border border-slate-200 bg-white hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors"
                    >
                      <span className="text-xs font-semibold text-slate-800">
                        {p.title->React.string}
                      </span>
                      <span className="text-[10px] text-slate-500 leading-tight mt-0.5">
                        {p.description->React.string}
                      </span>
                    </button>
                  )->React.array}
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
                    {"Define what data you want to retrieve: "->React.string}
                    <span className="font-medium"> {"instructions"->React.string} </span>
                    {" and "->React.string}
                    <span className="font-medium"> {"transactions"->React.string} </span>
                  </p>
                </div>
                {Array.length(query.instructions->Option.getOr([])) > 0 ||
                  Array.length(query.transactions->Option.getOr([])) > 0
                  ? <div className="ml-auto">
                      <span
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700"
                      >
                        {`${Int.toString(
                            Array.length(query.instructions->Option.getOr([])) +
                            Array.length(query.transactions->Option.getOr([])),
                          )} filter${Array.length(query.instructions->Option.getOr([])) +
                          Array.length(query.transactions->Option.getOr([])) === 1
                            ? ""
                            : "s"}`->React.string}
                      </span>
                    </div>
                  : React.null}
              </div>

              <div className="mb-8">
                <div className="flex flex-wrap gap-3">
                  <button
                    onClick={_ => addInstructionFilter()}
                    className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors"
                  >
                    <svg
                      className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                      />
                    </svg>
                    {"Add Instruction Filter"->React.string}
                  </button>
                  <button
                    onClick={_ => addTransactionFilter()}
                    className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors"
                  >
                    <svg
                      className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                      />
                    </svg>
                    {"Add Transaction Filter"->React.string}
                  </button>
                </div>
              </div>

              // Active Filters Display
              {Array.length(query.instructions->Option.getOr([])) > 0 ||
                Array.length(query.transactions->Option.getOr([])) > 0
                ? <div className="mt-6 relative z-0">
                    <div className="grid gap-4">
                      // Instruction Filters
                      {Array.mapWithIndex(query.instructions->Option.getOr([]), (
                        instrFilter,
                        index,
                      ) =>
                        <InstructionFilter
                          key={`instruction-${Int.toString(index)}`}
                          filterState={instrFilter}
                          onFilterChange={newFilter => updateInstructionFilter(index, newFilter)}
                          onRemove={() => removeInstructionFilter(index)}
                          filterIndex={index}
                          isExpanded={expandedFilterKey ===
                            Some(`instruction-${Int.toString(index)}`)}
                          onToggleExpand={() => toggleFilter(`instruction-${Int.toString(index)}`)}
                        />
                      )->React.array}

                      // Transaction Filters
                      {Array.mapWithIndex(query.transactions->Option.getOr([]), (
                        transactionFilter,
                        index,
                      ) =>
                        <TransactionFilter
                          key={`transaction-${Int.toString(index)}`}
                          filterState={transactionFilter}
                          onFilterChange={newFilter => updateTransactionFilter(index, newFilter)}
                          onRemove={() => removeTransactionFilter(index)}
                          filterIndex={index}
                          isExpanded={expandedFilterKey ===
                            Some(`transaction-${Int.toString(index)}`)}
                          onToggleExpand={() => toggleFilter(`transaction-${Int.toString(index)}`)}
                        />
                      )->React.array}
                    </div>
                  </div>
                : <div className="mt-6">
                    <div
                      className="text-center py-8 border-2 border-dashed border-slate-300 rounded-lg"
                    >
                      <div className="text-slate-400 mb-3">
                        <svg
                          className="w-8 h-8 mx-auto"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="1"
                            d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
                          />
                        </svg>
                      </div>
                      <h4 className="text-sm font-medium text-slate-600 mb-1">
                        {"No filters added yet"->React.string}
                      </h4>
                      <p className="text-xs text-slate-500">
                        {"Click a button above to add your first filter"->React.string}
                      </p>
                    </div>
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
                    {"Choose which data fields to include in your query response"->React.string}
                  </p>
                </div>
                {Array.length(query.fieldSelection.block) > 0 ||
                Array.length(query.fieldSelection.transaction) > 0 ||
                Array.length(query.fieldSelection.instruction) > 0
                  ? <div className="ml-auto">
                      <span
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700"
                      >
                        {`${Int.toString(
                            Array.length(query.fieldSelection.block) +
                            Array.length(query.fieldSelection.transaction) +
                            Array.length(query.fieldSelection.instruction),
                          )} fields`->React.string}
                      </span>
                    </div>
                  : React.null}
              </div>
              <FieldSelector
                fieldSelection={query.fieldSelection} onFieldSelectionChange={updateFieldSelection}
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
          <QueryResults query={query} executeSignal={executeSignal} />
        </div>
      </div>
    </div>
  </main>
}
