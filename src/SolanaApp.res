open SolanaQueryStructure

// Common Solana Programs
let tokenProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
let token2022ProgramId = "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"
let systemProgramId = "11111111111111111111111111111111"
let computeBudgetProgramId = "ComputeBudget111111111111111111111111111111"

@react.component
let make = (~bearerToken: option<string>, ~onTokenSubmit: string => unit) => {
  let defaultQuery = (): query => {
    fromSlot: 0,
    toSlot: None,
    instructions: None,
    transactions: None,
    logs: None,
    includeAllBlocks: None,
    fields: emptyFieldSelection,
    maxNumBlocks: Some(10),
    maxNumTransactions: Some(10),
    maxNumInstructions: Some(50),
    maxNumLogs: Some(50),
  }

  let (query, setQuery) = React.useState(() => defaultQuery())
  let (expandedFilterKey, setExpandedFilterKey) = React.useState(() => None)
  let (executeSignal, setExecuteSignal) = React.useState(() => 0)
  let (currentHead, setCurrentHead) = React.useState(() => None)

  // Fetch current head on mount so users can pick a sensible from_slot
  React.useEffect0(() => {
    let load = async () => {
      try {
        open Fetch
        let response = await fetchSimple("https://solana-near-head-test.hypersync.xyz/height")
        let text = await response->Response.text
        switch Int.fromString(String.trim(text)) {
        | Some(n) => setCurrentHead(_ => Some(n))
        | None => ()
        }
      } catch {
      | _ => ()
      }
    }
    load()->ignore
    None
  })

  let toggleFilter = key =>
    setExpandedFilterKey(prev =>
      switch prev {
      | Some(p) => p === key ? None : Some(key)
      | None => Some(key)
      }
    )

  let resetBuilder = () => {
    setExpandedFilterKey(_ => None)
    setQuery(_ => defaultQuery())
  }

  // Filter management
  let addInstructionFilter = () => {
    let newIndex = query.instructions->Option.getOr([])->Array.length
    setQuery(prev => {
      ...prev,
      instructions: Some(
        Array.concat(prev.instructions->Option.getOr([]), [emptyInstructionSelection]),
      ),
    })
    setExpandedFilterKey(_ => Some(`instruction-${Int.toString(newIndex)}`))
  }

  let updateInstructionFilter = (index, newFilter) =>
    setQuery(prev => {
      let cur = prev.instructions->Option.getOr([])
      let next = Array.mapWithIndex(cur, (f, i) => i === index ? newFilter : f)
      {...prev, instructions: Some(next)}
    })

  let removeInstructionFilter = index => {
    setQuery(prev => {
      let cur = prev.instructions->Option.getOr([])
      let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== index)
      {...prev, instructions: Array.length(next) > 0 ? Some(next) : None}
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

  let updateFieldSelection = newFields => setQuery(prev => {...prev, fields: newFields})

  // Quick start presets
  let applyPresetSplTokenTransfers = () => {
    let from = switch currentHead {
    | Some(h) => h - 5
    | None => 0
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 5),
      instructions: Some([
        {
          ...emptyInstructionSelection,
          programId: Some([tokenProgramId]),
          d1: Some(["0x03"]),
          includeTransaction: true,
        },
      ]),
      fields: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success, Fee],
        instruction: [Slot, TransactionIndex, ProgramId, Data, A0, A1, A2, D1],
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
    | None => 0
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 5),
      instructions: Some([
        {
          ...emptyInstructionSelection,
          programId: Some([systemProgramId]),
          d4: Some(["0x02000000"]),
          includeTransaction: true,
        },
      ]),
      fields: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, BlockTime],
        transaction: [Slot, TransactionIndex, Signatures, FeePayer, Success],
        instruction: [Slot, TransactionIndex, ProgramId, Data, A0, A1, D4],
      },
      maxNumBlocks: Some(5),
      maxNumTransactions: Some(50),
      maxNumInstructions: Some(100),
    })
    setExpandedFilterKey(_ => Some("instruction-0"))
  }

  // include_all_blocks pulls every block in the slot range AND auto-attaches
  // balances/token_balances per-tx, so even a few slots can produce many MB.
  // Keep the range tight by default.
  let applyPresetAllBlocks = () => {
    let from = switch currentHead {
    | Some(h) => h - 2
    | None => 0
    }
    setQuery(_ => {
      ...defaultQuery(),
      fromSlot: from,
      toSlot: Some(from + 2),
      includeAllBlocks: Some(true),
      fields: {
        ...emptyFieldSelection,
        block: [Slot, Blockhash, ParentSlot, BlockTime, BlockHeight],
      },
      maxNumBlocks: Some(2),
    })
  }

  let totalFilters =
    Array.length(query.instructions->Option.getOr([])) +
    Array.length(query.transactions->Option.getOr([])) +
    Array.length(query.logs->Option.getOr([]))

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
                    {"Solana mainnet via the near-head endpoint"->React.string}
                  </p>
                </div>

                <div className="mb-4 px-3 py-2 rounded-md bg-blue-50 border border-blue-200">
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="text-sm font-medium text-blue-900">
                        {"Solana Mainnet (near head)"->React.string}
                      </span>
                      <div className="text-xs text-blue-700 font-mono">
                        {"solana-near-head-test.hypersync.xyz"->React.string}
                      </div>
                    </div>
                    {switch currentHead {
                    | Some(h) =>
                      <span className="text-xs text-blue-700">
                        {`current head: slot ${Int.toString(h)}`->React.string}
                      </span>
                    | None => React.null
                    }}
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
                      {"Start from a popular Solana template"->React.string}
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={_ => applyPresetSplTokenTransfers()}
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"SPL Token Transfers"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetSystemTransfers()}
                      className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      {"System Program SOL Transfers"->React.string}
                    </button>
                    <button
                      onClick={_ => applyPresetAllBlocks()}
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
                  </div>
                </div>

                {totalFilters > 0
                  ? <div className="grid gap-4">
                      {query.instructions
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
                  fieldSelection={query.fields} onFieldSelectionChange={updateFieldSelection}
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
              query={query} executeSignal={executeSignal} bearerToken={bearerToken}
            />
          </div>
        </div>
      </div>
    </main>
  </>
}
