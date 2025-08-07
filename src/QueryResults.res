open QueryStructure
open Fetch

type activeTab = QueryJson | QueryLogic | Results

@react.component
let make = (~query: query, ~selectedChainName: option<string>) => {
  let (activeTab, setActiveTab) = React.useState(() => QueryJson)
  let (isExecuting, setIsExecuting) = React.useState(() => false)
  let (queryResult, setQueryResult) = React.useState(() => None)
  let (queryError, setQueryError) = React.useState(() => None)

  // Helper function to check if selected chain supports traces
  let selectedChainSupportsTraces = () => {
    switch selectedChainName {
    | Some(chainName) =>
      // Find the selected chain in the default chains list
      let selectedChain = ChainSelector.defaultChains->Array.find(chain => chain.name === chainName)
      switch selectedChain {
      | Some(chain) => ChainSelector.chainSupportsTraces(chain)
      | None => false
      }
    | None => false
    }
  }

  // Helper function to generate the correct URL for the selected chain
  let generateChainUrl = () => {
    switch selectedChainName {
    | Some(chainName) =>
      let selectedChain = ChainSelector.defaultChains->Array.find(chain => chain.name === chainName)
      switch selectedChain {
      | Some(chain) =>
        let baseUrl = `https://${Int.toString(chain.chain_id)}.hypersync.xyz/query`
        if ChainSelector.chainSupportsTraces(chain) {
          `https://${Int.toString(chain.chain_id)}-traces.hypersync.xyz/query`
        } else {
          baseUrl
        }
      | None => ""
      }
    | None => ""
    }
  }

  let serializeLogFilter = (logFilter: logSelection) => {
    let addressJson = switch logFilter.address {
    | Some(addresses) if Array.length(addresses) > 0 =>
      let addressesStr = Array.map(addresses, addr => `"${addr}"`)->Array.join(", ")
      `"address": [${addressesStr}]`
    | _ => ""
    }

    let topicsJson = switch logFilter.topics {
    | Some(topics) if Array.length(topics) > 0 =>
      let topicsStr = Array.map(topics, topicArray => {
        let topicStr = Array.map(topicArray, topic => `"${topic}"`)->Array.join(", ")
        `[${topicStr}]`
      })->Array.join(", ")
      `"topics": [${topicsStr}]`
    | _ => ""
    }

    let parts = [addressJson, topicsJson]->Array.filter(part => part !== "")
    let content = Array.join(parts, ", ")
    `{${content}}`
  }

  let serializeTransactionFilter = (transactionFilter: transactionSelection) => {
    let fromJson = switch transactionFilter.from_ {
    | Some(froms) if Array.length(froms) > 0 =>
      let fromsStr = Array.map(froms, addr => `"${addr}"`)->Array.join(", ")
      Some(`"from": [${fromsStr}]`)
    | _ => None
    }

    let toJson = switch transactionFilter.to_ {
    | Some(tos) if Array.length(tos) > 0 =>
      let tosStr = Array.map(tos, addr => `"${addr}"`)->Array.join(", ")
      Some(`"to": [${tosStr}]`)
    | _ => None
    }

    let sighashJson = switch transactionFilter.sighash {
    | Some(sighashes) if Array.length(sighashes) > 0 =>
      let sighashesStr = Array.map(sighashes, sighash => `"${sighash}"`)->Array.join(", ")
      Some(`"sighash": [${sighashesStr}]`)
    | _ => None
    }

    let statusJson = switch transactionFilter.status {
    | Some(status) => Some(`"status": ${Int.toString(status)}`)
    | None => None
    }

    let kindJson = switch transactionFilter.kind {
    | Some(kinds) if Array.length(kinds) > 0 =>
      let kindsStr = Array.map(kinds, kind => Int.toString(kind))->Array.join(", ")
      Some(`"kind": [${kindsStr}]`)
    | _ => None
    }

    let contractAddressJson = switch transactionFilter.contractAddress {
    | Some(addresses) if Array.length(addresses) > 0 =>
      let addressesStr = Array.map(addresses, addr => `"${addr}"`)->Array.join(", ")
      Some(`"contract_address": [${addressesStr}]`)
    | _ => None
    }

    let authorizationListJson = switch transactionFilter.authorizationList {
    | Some(authList) if Array.length(authList) > 0 =>
      let authListStr = Array.map(authList, auth => {
        let chainIdPart = switch auth.chainId {
        | Some(chainIds) if Array.length(chainIds) > 0 =>
          let chainIdsStr = Array.map(chainIds, id => Int.toString(id))->Array.join(", ")
          Some(`"chainId": [${chainIdsStr}]`)
        | _ => None
        }
        let addressPart = switch auth.address {
        | Some(addresses) if Array.length(addresses) > 0 =>
          let addressesStr = Array.map(addresses, addr => `"${addr}"`)->Array.join(", ")
          Some(`"address": [${addressesStr}]`)
        | _ => None
        }
        let parts = [chainIdPart, addressPart]->Array.filterMap(x => x)
        let content = Array.join(parts, ", ")
        `{${content}}`
      })->Array.join(", ")
      Some(`"authorization_list": [${authListStr}]`)
    | _ => None
    }

    let allParts =
      [
        fromJson,
        toJson,
        sighashJson,
        statusJson,
        kindJson,
        contractAddressJson,
        authorizationListJson,
      ]->Array.filterMap(x => x)
    let content = Array.join(allParts, ", ")
    `{${content}}`
  }

  let serializeBlockFilter = (blockFilter: blockSelection) => {
    let hashJson = switch blockFilter.hash {
    | Some(hashes) if Array.length(hashes) > 0 =>
      let hashesStr = Array.map(hashes, hash => `"${hash}"`)->Array.join(", ")
      Some(`"hash": [${hashesStr}]`)
    | _ => None
    }

    let minerJson = switch blockFilter.miner {
    | Some(miners) if Array.length(miners) > 0 =>
      let minersStr = Array.map(miners, miner => `"${miner}"`)->Array.join(", ")
      Some(`"miner": [${minersStr}]`)
    | _ => None
    }

    let allParts = [hashJson, minerJson]->Array.filterMap(x => x)
    let content = Array.join(allParts, ", ")
    `{${content}}`
  }

  let serializeTraceFilter = (traceFilter: traceSelection) => {
    let fromJson = switch traceFilter.from_ {
    | Some(froms) if Array.length(froms) > 0 =>
      let fromsStr = Array.map(froms, addr => `"${addr}"`)->Array.join(", ")
      Some(`"from": [${fromsStr}]`)
    | _ => None
    }

    let toJson = switch traceFilter.to_ {
    | Some(tos) if Array.length(tos) > 0 =>
      let tosStr = Array.map(tos, addr => `"${addr}"`)->Array.join(", ")
      Some(`"to": [${tosStr}]`)
    | _ => None
    }

    let addressJson = switch traceFilter.address {
    | Some(addresses) if Array.length(addresses) > 0 =>
      let addressesStr = Array.map(addresses, addr => `"${addr}"`)->Array.join(", ")
      Some(`"address": [${addressesStr}]`)
    | _ => None
    }

    let callTypeJson = switch traceFilter.callType {
    | Some(callTypes) if Array.length(callTypes) > 0 =>
      let callTypesStr = Array.map(callTypes, callType => `"${callType}"`)->Array.join(", ")
      Some(`"call_type": [${callTypesStr}]`)
    | _ => None
    }

    let rewardTypeJson = switch traceFilter.rewardType {
    | Some(rewardTypes) if Array.length(rewardTypes) > 0 =>
      let rewardTypesStr = Array.map(rewardTypes, rewardType => `"${rewardType}"`)->Array.join(", ")
      Some(`"reward_type": [${rewardTypesStr}]`)
    | _ => None
    }

    let kindJson = switch traceFilter.kind {
    | Some(kinds) if Array.length(kinds) > 0 =>
      let kindsStr = Array.map(kinds, kind => `"${kind}"`)->Array.join(", ")
      Some(`"kind": [${kindsStr}]`)
    | _ => None
    }

    let sighashJson = switch traceFilter.sighash {
    | Some(sighashes) if Array.length(sighashes) > 0 =>
      let sighashesStr = Array.map(sighashes, sighash => `"${sighash}"`)->Array.join(", ")
      Some(`"sighash": [${sighashesStr}]`)
    | _ => None
    }

    let allParts =
      [
        fromJson,
        toJson,
        addressJson,
        callTypeJson,
        rewardTypeJson,
        kindJson,
        sighashJson,
      ]->Array.filterMap(x => x)
    let content = Array.join(allParts, ", ")
    `{${content}}`
  }

  let serializeFieldSelection = (fieldSelection: fieldSelection) => {
    let blockFields = Array.map(fieldSelection.block, FieldSelector.blockFieldToSnakeCaseString)
    let transactionFields = Array.map(
      fieldSelection.transaction,
      FieldSelector.transactionFieldToSnakeCaseString,
    )
    let logFields = Array.map(fieldSelection.log, FieldSelector.logFieldToSnakeCaseString)
    let traceFields = Array.map(fieldSelection.trace, FieldSelector.traceFieldToSnakeCaseString)

    let blockFieldsStr = Array.map(blockFields, field => `"${field}"`)->Array.join(", ")
    let transactionFieldsStr = Array.map(transactionFields, field => `"${field}"`)->Array.join(", ")
    let logFieldsStr = Array.map(logFields, field => `"${field}"`)->Array.join(", ")
    let traceFieldsStr = Array.map(traceFields, field => `"${field}"`)->Array.join(", ")

    if selectedChainSupportsTraces() {
      `"field_selection": {
    "block": [${blockFieldsStr}],
    "transaction": [${transactionFieldsStr}],
    "log": [${logFieldsStr}],
    "trace": [${traceFieldsStr}]
  }`
    } else {
      `"field_selection": {
    "block": [${blockFieldsStr}],
    "transaction": [${transactionFieldsStr}],
    "log": [${logFieldsStr}]
  }`
    }
  }

  let serializeQuery = (query: query) => {
    let fromBlockPart = `"from_block": ${Int.toString(query.fromBlock)}`

    let toBlockPart = switch query.toBlock {
    | Some(toBlock) => Some(`"to_block": ${Int.toString(toBlock)}`)
    | None => None
    }

    let logsPart = switch query.logs {
    | Some(logs) if Array.length(logs) > 0 =>
      let logsStr = Array.map(logs, serializeLogFilter)->Array.join(",\n    ")
      Some(
        `"logs": [
    ${logsStr}
  ]`,
      )
    | _ => None
    }

    let transactionsPart = switch query.transactions {
    | Some(transactions) if Array.length(transactions) > 0 =>
      let transactionsStr =
        Array.map(transactions, serializeTransactionFilter)->Array.join(",\n    ")
      Some(
        `"transactions": [
    ${transactionsStr}
  ]`,
      )
    | _ => None
    }

    let blocksPart = switch query.blocks {
    | Some(blocks) if Array.length(blocks) > 0 =>
      let blocksStr = Array.map(blocks, serializeBlockFilter)->Array.join(",\n    ")
      Some(
        `"blocks": [
    ${blocksStr}
  ]`,
      )
    | _ => None
    }

    let tracesPart = if selectedChainSupportsTraces() {
      switch query.traces {
      | Some(traces) if Array.length(traces) > 0 =>
        let tracesStr = Array.map(traces, serializeTraceFilter)->Array.join(",\n    ")
        Some(
          `"traces": [
    ${tracesStr}
  ]`,
        )
      | _ => None
      }
    } else {
      None
    }

    let includeAllBlocksPart = switch query.includeAllBlocks {
    | Some(true) => Some(`"include_all_blocks": true`)
    | Some(false) => Some(`"include_all_blocks": false`)
    | None => None
    }

    let fieldSelectionPart = serializeFieldSelection(query.fieldSelection)

    let maxNumBlocksPart = switch query.maxNumBlocks {
    | Some(max) => Some(`"max_num_blocks": ${Int.toString(max)}`)
    | None => None
    }

    let maxNumTransactionsPart = switch query.maxNumTransactions {
    | Some(max) => Some(`"max_num_transactions": ${Int.toString(max)}`)
    | None => None
    }

    let maxNumLogsPart = switch query.maxNumLogs {
    | Some(max) => Some(`"max_num_logs": ${Int.toString(max)}`)
    | None => None
    }

    let maxNumTracesPart = if selectedChainSupportsTraces() {
      switch query.maxNumTraces {
      | Some(max) => Some(`"max_num_traces": ${Int.toString(max)}`)
      | None => None
      }
    } else {
      None
    }

    let joinModePart = switch query.joinMode {
    | Some(Default) => Some(`"join_mode": "Default"`)
    | Some(JoinAll) => Some(`"join_mode": "JoinAll"`)
    | Some(JoinNothing) => Some(`"join_mode": "JoinNothing"`)
    | None => None
    }

    let allParts =
      [
        Some(fromBlockPart),
        toBlockPart,
        logsPart,
        transactionsPart,
        blocksPart,
        tracesPart,
        includeAllBlocksPart,
        Some(fieldSelectionPart),
        maxNumBlocksPart,
        maxNumTransactionsPart,
        maxNumLogsPart,
        maxNumTracesPart,
        joinModePart,
      ]->Array.filterMap(x => x)

    let content = Array.join(allParts, ",\n  ")
    `{
  ${content}
}`
  }

  let executeQuery = async () => {
    switch selectedChainName {
    | Some(_) => {
        setActiveTab(_ => Results) // Switch to Results tab when query starts
        setIsExecuting(_ => true)
        setQueryError(_ => None)
        setQueryResult(_ => None)

        try {
          let url = generateChainUrl()
          let body = serializeQuery(query)

          let response = await fetch(
            url,
            {
              method: #POST,
              body: Body.string(body),
              headers: Headers.fromObject({
                "Content-Type": "application/json",
              }),
            },
          )

          let resultJson = await response->Response.json

          if response->Response.ok {
            // Convert JSON back to string for display purposes
            try {
              let resultText = Js.Json.stringifyWithSpace(resultJson, 2)
              setQueryResult(_ => Some(resultText))
            } catch {
            | e =>
              Console.log(e)
              setQueryError(_ => Some("Caught exception - during stringify of json"))
            }
            // ->Option.getOr("Invalid JSON response")
          } else {
            let errorText = await response->Response.text
            setQueryError(_ => Some(
              `HTTP ${Int.toString(response->Response.status)}: ${errorText}`,
            ))
          }
        } catch {
        | _ => setQueryError(_ => Some("Network error occurred"))
        }

        setIsExecuting(_ => false)
      }
    | None => ()
    }
  }

  let generateCurlCommand = (query: query) => {
    let url = generateChainUrl()
    let body = serializeQuery(query)
    let escapedBody = String.replaceAll(body, "\"", "\\\"")

    `curl -X POST "${url}" \\
  -H "Content-Type: application/json" \\
  -d "${escapedBody}"`
  }

  let copyCurlToClipboard = () => {
    switch selectedChainName {
    | Some(_) => {
        let curlCommand = generateCurlCommand(query)
        // Use the Clipboard API
        let copyToClipboard: string => unit = %raw(`(curlCommand) => {
          navigator.clipboard.writeText(curlCommand).then(() => {
            console.log('cURL command copied to clipboard');
          }).catch(err => {
            console.error('Failed to copy: ', err);
          })
        }`)
        copyToClipboard(curlCommand)
      }
    | None => ()
    }
  }

  let copyJsonToClipboard = () => {
    let jsonText = serializeQuery(query)
    let copyToClipboard: string => unit = %raw(`(text) => {
      navigator.clipboard.writeText(text).then(() => {
        console.log('JSON copied to clipboard');
      }).catch(err => {
        console.error('Failed to copy JSON: ', err);
      })
    }`)
    copyToClipboard(jsonText)
  }

  let copyShareLinkToClipboard = () => {
    let getHref: unit => string = %raw(`() => window.location.href`)
    let href = getHref()
    let copyToClipboard: string => unit = %raw(`(text) => {
      navigator.clipboard.writeText(text).then(() => {
        console.log('Share link copied');
      }).catch(err => {
        console.error('Failed to copy link: ', err);
      })
    }`)
    copyToClipboard(href)
  }

  let downloadJson = () => {
    let jsonText = serializeQuery(query)
    let triggerDownload: string => unit = %raw(`(text) => {
      const blob = new Blob([text], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'hypersync-query.json';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }`)
    triggerDownload(jsonText)
  }

  <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-slate-900 mb-2"> {"Results"->React.string} </h3>
      <p className="text-sm text-slate-600">
        {"View your query structure and results"->React.string}
      </p>
      {switch selectedChainName {
      | Some(_) =>
        <div className="mt-3">
          <span
            className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200">
            {`Query URL: ${generateChainUrl()}`->React.string}
          </span>
        </div>
      | None => React.null
      }}
    </div>

    // Tab Navigation
    <div
      className="border-b border-slate-200 sticky top-[56px] bg-white/80 backdrop-blur z-10 -mx-6 px-6 mb-6">
      <nav className="flex space-x-8">
        <button
          onClick={_ => setActiveTab(_ => QueryJson)}
          className={`py-3 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab ===
              QueryJson
              ? "border-slate-900 text-slate-900"
              : "border-transparent text-slate-500 hover:text-slate-900 hover:border-slate-300"}`}>
          {"Query JSON"->React.string}
        </button>
        <button
          onClick={_ => setActiveTab(_ => QueryLogic)}
          className={`py-3 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab ===
              QueryLogic
              ? "border-slate-900 text-slate-900"
              : "border-transparent text-slate-500 hover:text-slate-900 hover:border-slate-300"}`}>
          {"Query Logic"->React.string}
        </button>
        <button
          onClick={_ => setActiveTab(_ => Results)}
          className={`py-3 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab ===
              Results
              ? "border-slate-900 text-slate-900"
              : "border-transparent text-slate-500 hover:text-slate-900 hover:border-slate-300"}`}>
          {"Results"->React.string}
        </button>
      </nav>
    </div>

    // Tab Content
    <div className="min-h-96">
      {switch activeTab {
      | QueryJson =>
        <div>
          <div className="flex items-center justify-between mb-3">
            <h4 className="text-sm font-medium text-slate-900">
              {"Query Structure"->React.string}
            </h4>
            {switch selectedChainName {
            | Some(_) =>
              <div className="flex space-x-2">
                <button
                  onClick={_ => copyCurlToClipboard()}
                  className="px-3 py-1 bg-slate-600 text-white text-xs font-medium rounded-lg hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                  {"Copy cURL"->React.string}
                </button>
                <button
                  onClick={_ => copyJsonToClipboard()}
                  className="px-3 py-1 bg-slate-100 text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors">
                  {"Copy JSON"->React.string}
                </button>
                <button
                  onClick={_ => downloadJson()}
                  className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors">
                  {"Download"->React.string}
                </button>
                <button
                  onClick={_ => copyShareLinkToClipboard()}
                  className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors">
                  {"Share link"->React.string}
                </button>
                <button
                  onClick={_ => executeQuery()->ignore}
                  disabled={isExecuting}
                  className="px-3 py-1 bg-slate-700 text-white text-xs font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 disabled:opacity-50 transition-colors">
                  {(isExecuting ? "Executing..." : "Execute Query")->React.string}
                </button>
              </div>
            | None => React.null
            }}
          </div>
          <pre
            className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm font-mono overflow-x-auto whitespace-pre">
            {serializeQuery(query)->React.string}
          </pre>
        </div>

      | QueryLogic => <QueryLogic query={query} tracesSupported={selectedChainSupportsTraces()} />

      | Results =>
        <div>
          {switch (queryResult, queryError, isExecuting) {
          | (_, _, true) =>
            <div className="text-center py-12">
              <div className="text-blue-500 mb-4">
                <svg
                  className="w-8 h-8 mx-auto animate-spin"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                  />
                </svg>
              </div>
              <h4 className="text-lg font-medium text-blue-600 mb-2">
                {"Executing Query..."->React.string}
              </h4>
              <p className="text-gray-500">
                {"Please wait while we fetch your results"->React.string}
              </p>
            </div>

          | (Some(result), _, false) =>
            <div>
              <div className="flex items-center justify-between mb-3">
                <h4 className="text-sm font-medium text-gray-900">
                  {"Query Results"->React.string}
                </h4>
                <span
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">
                  {"Success"->React.string}
                </span>
              </div>
              <pre
                className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm font-mono overflow-x-auto whitespace-pre max-h-96">
                {result->React.string}
              </pre>
            </div>

          | (None, Some(error), false) =>
            <div>
              <div className="flex items-center justify-between mb-3">
                <h4 className="text-sm font-medium text-gray-900">
                  {"Query Error"->React.string}
                </h4>
                <span
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                  {"Error"->React.string}
                </span>
              </div>
              <div className="bg-red-50 border border-red-200 rounded-xl p-4 text-sm text-red-700">
                {error->React.string}
              </div>
            </div>

          | (None, None, false) =>
            <div className="text-center py-12">
              <div className="text-slate-400 mb-4">
                <svg
                  className="w-12 h-12 mx-auto"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="1"
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                  />
                </svg>
              </div>
              <h4 className="text-lg font-medium text-slate-600 mb-2">
                {"Query Results"->React.string}
              </h4>
              <p className="text-slate-500">
                {"Execute query to see results here..."->React.string}
              </p>
              {switch selectedChainName {
              | Some(_) =>
                <div className="mt-4 flex justify-center space-x-2">
                  <button
                    onClick={_ => copyCurlToClipboard()}
                    className="px-4 py-2 bg-slate-600 text-white text-sm font-medium rounded-lg hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    {"Copy cURL"->React.string}
                  </button>
                  <button
                    onClick={_ => executeQuery()->ignore}
                    className="px-4 py-2 bg-slate-700 text-white text-sm font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    {"Execute Query"->React.string}
                  </button>
                </div>
              | None =>
                <div className="mt-4 text-sm text-orange-600">
                  {"Please select a chain to execute queries"->React.string}
                </div>
              }}
            </div>
          }}
        </div>
      }}
    </div>
  </div>
}
