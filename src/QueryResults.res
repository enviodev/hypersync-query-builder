open QueryStructure
open Fetch

type activeTab = QueryJson | QueryLogic | Results
type resultsView = Raw | Table
type rawMode = Plain | Interactive

@react.component
let make = (~query: query, ~selectedChainName: option<string>, ~executeSignal: int) => {
  let (activeTab, setActiveTab) = React.useState(() => QueryJson)
  let (isExecuting, setIsExecuting) = React.useState(() => false)
  let (queryResult, setQueryResult) = React.useState(() => None)
  let (queryError, setQueryError) = React.useState(() => None)
  let (resultsView, setResultsView) = React.useState(() => Raw)
  let (rawMode, setRawMode) = React.useState(() => Plain)
  let (queryResultJson, setQueryResultJson) = React.useState(() => None)
  let (sortColumn, setSortColumn) = React.useState(() => None)
  let (sortAscending, setSortAscending) = React.useState(() => true)
  let (clientMs, setClientMs) = React.useState(() => None)
  let (serverMs, setServerMs) = React.useState(() => None)
  let (responseBytes, setResponseBytes) = React.useState(() => None)
  let (selectedDataset, setSelectedDataset) = React.useState(() => None)

  // executeSignal will be handled after executeQuery is defined

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
        setQueryResultJson(_ => None)
        setClientMs(_ => None)
        setServerMs(_ => None)
        setResponseBytes(_ => None)
        setSelectedDataset(_ => None)
        setQueryResultJson(_ => None)

        try {
          let url = generateChainUrl()
          let body = serializeQuery(query)
          let calcByteLength: string => int = %raw(`(s) => new TextEncoder().encode(s).length`)
          let t0: float = %raw("performance.now()")
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
          let resultTextRaw = await response->Response.text
          let t1: float = %raw("performance.now()")
          let clientElapsed = t1 -. t0
          setClientMs(_ => Some(Float.toInt(clientElapsed)))
          setResponseBytes(_ => Some(calcByteLength(resultTextRaw)))
          let resultJson = try {
            Js.Json.parseExn(resultTextRaw)
          } catch {
          | _ => Js.Json.string(resultTextRaw)
          }

          if response->Response.ok {
            // Convert JSON back to string for display purposes
            try {
              let resultText = Js.Json.stringifyWithSpace(resultJson, 2)
              setQueryResult(_ => Some(resultText))
              setQueryResultJson(_ => Some(resultJson))
              // server duration if present
              let serverDurationMs =
                resultJson
                ->Js.Json.decodeObject
                ->Option.flatMap(dict => Js.Dict.get(dict, "total_execution_time"))
                ->Option.flatMap(Js.Json.decodeNumber)
                ->Option.map(Float.toInt)
              setServerMs(_ => serverDurationMs)
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

  // Trigger execute when the inline button is pressed in the parent
  React.useEffect1(() => {
    executeQuery()->ignore
    None
  }, [executeSignal])

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

  // Copy full results JSON
  let copyResultsJson = () => {
    switch queryResult {
    | Some(result) => {
        let copyToClipboard: string => unit = %raw(`(text) => {
          navigator.clipboard.writeText(text).catch(() => {})
        }`)
        copyToClipboard(result)
      }
    | None => ()
    }
  }

  // ---- Table helpers (analysis, sorting, formatting) ----
  // Determine column data types from sample rows
  let analyzeColumns: array<Js.Dict.t<string>> => Js.Dict.t<string> = %raw(`(flatRows) => {
    const isNumeric = (v) => typeof v === 'string' && /^-?\d+(?:\.\d+)?$/.test(v.trim());
    const isHex = (v) => typeof v === 'string' && /^0x[0-9a-fA-F]{6,}$/.test(v);
    const counts = new Map();
    for (let i = 0; i < flatRows.length && i < 200; i++) {
      const r = flatRows[i];
      for (const k in r) {
        const v = r[k];
        let t = 'text';
        if (isNumeric(v)) t = 'numeric';
        else if (isHex(v)) t = 'hex';
        const m = counts.get(k) || { numeric: 0, hex: 0, text: 0 };
        m[t]++;
        counts.set(k, m);
      }
    }
    const out = {};
    counts.forEach((m, k) => {
      if (m.numeric >= m.hex && m.numeric >= m.text) out[k] = 'numeric';
      else if (m.hex >= m.numeric && m.hex >= m.text) out[k] = 'hex';
      else out[k] = 'text';
    });
    return out;
  }`)

  // Sort rows by a column (stable-ish)
  let sortFlatRows: (
    array<Js.Dict.t<string>>,
    string,
    string,
    bool,
  ) => array<Js.Dict.t<string>> = %raw(`(rows, col, colType, asc) => {
      const arr = rows.slice();
      const cmp = (a, b) => {
        const av = a[col];
        const bv = b[col];
        if (colType === 'numeric') {
          const an = parseFloat(av ?? '0');
          const bn = parseFloat(bv ?? '0');
          return an === bn ? 0 : (an < bn ? -1 : 1);
        }
        const as = String(av ?? '');
        const bs = String(bv ?? '');
        return as.localeCompare(bs);
      };
      arr.sort((a, b) => asc ? cmp(a, b) : -cmp(a, b));
      return arr;
    }`)

  // Truncate long values moderately in the middle for readability
  let _truncateMiddle: string => string = %raw(`(s) => {
    if (typeof s !== 'string') return String(s ?? '');
    const max = 24;
    if (s.length <= max) return s;
    const head = s.slice(0, 10);
    const tail = s.slice(-8);
    return head + '…' + tail;
  }`)

  let copyText: string => unit = %raw(`(text) => {
    navigator.clipboard && navigator.clipboard.writeText(text).catch(() => {});
  }`)

  // Dataset detection and extraction
  let _detectDatasetNames: Js.Json.t => array<string> = %raw(`(data) => {
    const names = new Set();
    const scanObject = (obj) => {
      if (!obj || typeof obj !== 'object') return;
      const preferred = ['logs','transactions','blocks','traces','rows','results','items'];
      for (const k of Object.keys(obj)) {
        const v = obj[k];
        if (Array.isArray(v)) names.add(k);
      }
      // Special-case nested arrays under data
      if (Array.isArray(obj.data)) {
        const arr = obj.data;
        if (arr.length && typeof arr[0] === 'object') {
          for (const k of Object.keys(arr[0])) {
            if (Array.isArray(arr[0][k])) names.add(k);
          }
        } else {
          names.add('data');
        }
      }
      // order by preference then alpha
      const list = Array.from(names);
      list.sort((a,b) => {
        const ia = preferred.indexOf(a);
        const ib = preferred.indexOf(b);
        if (ia !== -1 || ib !== -1) return (ia === -1 ? 1 : ia) - (ib === -1 ? 1 : ib);
        return a.localeCompare(b);
      });
      return list;
    };
    if (Array.isArray(data)) {
      if (data.length === 0) return [];
      if (typeof data[0] === 'object') {
        // gather keys across elements
        const keys = new Set();
        for (const el of data) {
          if (el && typeof el === 'object') {
            for (const k of Object.keys(el)) if (Array.isArray(el[k])) keys.add(k);
          }
        }
        if (keys.size) return Array.from(keys).sort();
      }
      return ['data'];
    }
    if (data && typeof data === 'object') return scanObject(data);
    return [];
  }`)

  let getDatasetRowsByName: (Js.Json.t, string) => array<Js.Json.t> = %raw(`(data, name) => {
    const concat = (a,b) => (a.push.apply(a,b), a);
    if (Array.isArray(data)) {
      if (name === 'data') return data;
      let out = [];
      for (const el of data) {
        if (el && typeof el === 'object' && Array.isArray(el[name])) out = concat(out, el[name]);
      }
      return out;
    }
    if (data && typeof data === 'object') {
      if (name === 'data' && Array.isArray(data.data)) return data.data;
      if (Array.isArray(data[name])) return data[name];
      if (Array.isArray(data.data)) {
        let out = [];
        for (const el of data.data) {
          if (el && typeof el === 'object' && Array.isArray(el[name])) out = concat(out, el[name]);
        }
        return out;
      }
    }
    return [];
  }`)

  let formatBytes: int => string = %raw(`(b) => {
    if (b < 1024) return b + ' B';
    if (b < 1024*1024) return (Math.round(b/102.4)/10) + ' KB';
    return (Math.round(b/104857.6)/10) + ' MB';
  }`)

  // Fixed column width for all columns to prevent overlap
  let fixedColumnWidth = "200px" // Fixed width that guarantees no overlap

  // Improved truncation for very long values
  let smartTruncate = (text: string, maxLength: int): string => {
    if String.length(text) <= maxLength {
      text
    } else {
      let half = maxLength / 2 - 2
      let start = Js.String2.substring(text, ~from=0, ~to_=half)
      let end = Js.String2.substringToEnd(text, ~from=String.length(text) - half)
      start ++ "..." ++ end
    }
  }

  // Collapsible JSON renderer using <details/summary>
  let rec renderJsonNode = (label: string, node: Js.Json.t, depth: int): React.element => {
    let indent = if depth > 0 {
      "ml-4"
    } else {
      ""
    }
    switch Js.Json.classify(node) {
    | JSONString(s) =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: "${s}"`->React.string}
      </div>
    | JSONNumber(n) =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: ${Js.Float.toString(n)}`->React.string}
      </div>
    | JSONTrue =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: true`->React.string}
      </div>
    | JSONFalse =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: false`->React.string}
      </div>
    | JSONNull =>
      <div className={`text-xs ${indent} font-mono text-slate-500`}>
        {`${label}: null`->React.string}
      </div>
    | JSONArray(arr) =>
      <details className={`text-xs ${indent}`} open_={depth < 1}>
        <summary className="cursor-pointer font-mono text-slate-700">
          {`${label} [${Int.toString(Array.length(arr))}]`->React.string}
        </summary>
        <div className="mt-1">
          {arr
          ->Array.mapWithIndex((v, i) => renderJsonNode(Int.toString(i), v, depth + 1))
          ->React.array}
        </div>
      </details>
    | JSONObject(obj) => {
        let keys = Js.Dict.keys(obj)
        <details className={`text-xs ${indent}`} open_={depth < 1}>
          <summary className="cursor-pointer font-mono text-slate-700">
            {`${label} {}`->React.string}
          </summary>
          <div className="mt-1">
            {keys
            ->Array.map(k => {
              let v = Js.Dict.get(obj, k)->Belt.Option.getWithDefault(Js.Json.null)
              renderJsonNode(k, v, depth + 1)
            })
            ->React.array}
          </div>
        </details>
      }
    }
  }

  // Return only core dataset names in order of preference
  let getCoreDatasetNames: Js.Json.t => array<string> = %raw(`(data) => {
    const keys = ['logs','transactions','blocks','traces'];
    const found = new Set();
    const scan = (obj) => {
      if (!obj || typeof obj !== 'object') return;
      for (const k of keys) if (Array.isArray(obj[k])) found.add(k);
    };
    if (Array.isArray(data)) {
      for (const el of data) scan(el);
    } else if (data && typeof data === 'object') {
      scan(data);
      if (Array.isArray(data.data)) for (const el of data.data) scan(el);
    }
    const out = Array.from(found);
    const order = (a,b) => keys.indexOf(a) - keys.indexOf(b);
    out.sort(order);
    return out;
  }`)

  // ---- Table helpers (JS interop) ----
  // Pick an array from common response shapes
  let _pickFirstArrayDataset: Js.Json.t => array<Js.Json.t> = %raw(`(data) => {
    if (Array.isArray(data)) return data;
    if (data && typeof data === 'object') {
      const preferred = ['rows','data','results','logs','transactions','blocks','traces','items'];
      for (const k of preferred) { if (Array.isArray(data[k])) return data[k]; }
      for (const k in data) { if (Array.isArray(data[k])) return data[k]; }
    }
    return [];
  }`)

  // Flatten nested objects; stringify arrays
  let flattenRows: array<Js.Json.t> => array<Js.Dict.t<string>> = %raw(`(rows) => {
    const flattenObject = (obj, prefix) => {
      const out = {};
      const stack = [[obj, prefix]];
      while (stack.length) {
        const [cur, pre] = stack.pop();
        if (cur && typeof cur === 'object' && !Array.isArray(cur)) {
          for (const k in cur) {
            if (!Object.prototype.hasOwnProperty.call(cur, k)) continue;
            const v = cur[k];
            const nk = pre ? pre + '.' + k : k;
            if (v && typeof v === 'object' && !Array.isArray(v)) stack.push([v, nk]);
            else if (Array.isArray(v)) out[nk] = JSON.stringify(v);
            else out[nk] = v == null ? '' : String(v);
          }
        } else {
          out[pre || 'value'] = cur == null ? '' : String(cur);
        }
      }
      return out;
    };
    return rows.map(r => flattenObject(r, ''));
  }`)

  // Detect columns from first N rows
  let detectColumns: array<Js.Dict.t<string>> => array<string> = %raw(`(flatRows) => {
    const cols = new Set();
    for (let i = 0; i < flatRows.length && i < 200; i++) {
      const r = flatRows[i];
      for (const k in r) cols.add(k);
    }
    return Array.from(cols).sort();
  }`)

  // Build CSV from flattened rows
  let rowsToCsv: array<Js.Dict.t<string>> => string = %raw(`(flatRows) => {
    const cols = (() => {
      const s = new Set();
      for (let i = 0; i < flatRows.length && i < 200; i++) { for (const k in flatRows[i]) s.add(k); }
      return Array.from(s).sort();
    })();
    const esc = (v) => {
      if (v == null) return '';
      const s = String(v);
      if (s.includes('"') || s.includes(',') || s.includes('\n')) return '"' + s.replaceAll('"','""') + '"';
      return s;
    };
    const lines = [cols.join(',')];
    for (let i = 0; i < flatRows.length && i < 1000; i++) {
      const r = flatRows[i];
      lines.push(cols.map(c => esc(r[c])).join(','));
    }
    return lines.join('\n');
  }`)

  let copyCsvToClipboard = (csvText: string) => {
    let copyToClipboard: string => unit = %raw(`(text) => {
      navigator.clipboard.writeText(text).catch(err => {
        console.error('Failed to copy CSV: ', err);
      })
    }`)
    copyToClipboard(csvText)
  }

  let downloadCsv = (csvText: string) => {
    let triggerDownload: string => unit = %raw(`(text) => {
      const blob = new Blob([text], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'hypersync-results.csv';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }`)
    triggerDownload(csvText)
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
                  {"Share Query Link"->React.string}
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
                <div className="flex items-center">
                  <span
                    className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700 mr-3">
                    {"Success"->React.string}
                  </span>
                  {switch (clientMs, serverMs, responseBytes) {
                  | (Some(cms), server, bytes) =>
                    <span className="text-xs text-slate-500 mr-3">
                      {`${Int.toString(cms)}ms`->React.string}
                      {switch server {
                      | Some(sms) => ` · ${Int.toString(sms)}ms server`->React.string
                      | None => React.null
                      }}
                      {switch bytes {
                      | Some(b) => ` · ${formatBytes(b)}`->React.string
                      | None => React.null
                      }}
                    </span>
                  | _ => React.null
                  }}
                  <button
                    onClick={_ => copyResultsJson()}
                    className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors mr-2">
                    {"Copy Results JSON"->React.string}
                  </button>
                  <div className="inline-flex items-center">
                    <button
                      onClick={_ => setResultsView(_ => Raw)}
                      className={`px-3 py-1 text-xs font-medium rounded-l-lg border border-slate-200 ${resultsView ===
                          Raw
                          ? "bg-slate-800 text-white"
                          : "bg-white text-slate-700 hover:bg-slate-50"}`}>
                      {"Raw"->React.string}
                    </button>
                    <button
                      onClick={_ => setResultsView(_ => Table)}
                      className={`px-3 py-1 text-xs font-medium rounded-r-lg border border-slate-200 border-l-0 ${resultsView ===
                          Table
                          ? "bg-slate-800 text-white"
                          : "bg-white text-slate-700 hover:bg-slate-50"}`}>
                      {"Table"->React.string}
                    </button>
                  </div>
                </div>
              </div>
              {switch resultsView {
              | Raw =>
                switch rawMode {
                | Plain =>
                  <div>
                    <div className="mb-2">
                      <button
                        onClick={_ => setRawMode(_ => Interactive)}
                        className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors">
                        {"Interactive JSON"->React.string}
                      </button>
                    </div>
                    <pre
                      className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm font-mono overflow-x-auto whitespace-pre max-h-96">
                      {result->React.string}
                    </pre>
                  </div>
                | Interactive =>
                  <div>
                    <div className="mb-2">
                      <button
                        onClick={_ => setRawMode(_ => Plain)}
                        className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors">
                        {"Plain JSON"->React.string}
                      </button>
                    </div>
                    <div
                      className="bg-slate-50 border border-slate-200 rounded-xl p-4 max-h-96 overflow-auto">
                      {switch queryResultJson {
                      | Some(json) => renderJsonNode("root", json, 0)
                      | None => React.null
                      }}
                    </div>
                  </div>
                }
              | Table =>
                switch queryResultJson {
                | Some(json) => {
                    // Dataset selection and rows
                    let datasetNames = getCoreDatasetNames(json)
                    let effectiveDataset = switch selectedDataset {
                    | Some(name) => name
                    | None =>
                      if Array.length(datasetNames) > 0 {
                        Belt.Array.getExn(datasetNames, 0)
                      } else {
                        "data"
                      }
                    }
                    let rowsJson = getDatasetRowsByName(json, effectiveDataset)
                    if Array.length(rowsJson) == 0 {
                      <div
                        className="text-sm text-slate-600 bg-slate-50 border border-slate-200 rounded-xl p-4">
                        {"No tabular rows detected in response"->React.string}
                      </div>
                    } else {
                      let flatRows = flattenRows(rowsJson)
                      let columns = detectColumns(flatRows)
                      let csvText = rowsToCsv(flatRows)
                      let columnTypes = analyzeColumns(flatRows)
                      let displayedRows = switch sortColumn {
                      | Some(col) =>
                        let colType =
                          Js.Dict.get(columnTypes, col)->Belt.Option.getWithDefault("text")
                        sortFlatRows(flatRows, col, colType, sortAscending)
                      | None => flatRows
                      }
                      <div>
                        <div className="mb-2 flex items-center flex-wrap gap-2">
                          {Array.length(datasetNames) > 1
                            ? <div className="inline-flex items-center mr-2">
                                <span className="text-xs text-slate-500 mr-2">
                                  {"Dataset"->React.string}
                                </span>
                                <div
                                  className="inline-flex rounded-lg border border-slate-200 overflow-hidden">
                                  {datasetNames
                                  ->Array.map(name =>
                                    <button
                                      key={name}
                                      onClick={_ => setSelectedDataset(_ => Some(name))}
                                      className={`px-3 py-1 text-xs ${name === effectiveDataset
                                          ? "bg-slate-800 text-white"
                                          : "bg-white text-slate-700 hover:bg-slate-50"}`}>
                                      {name->React.string}
                                    </button>
                                  )
                                  ->React.array}
                                </div>
                              </div>
                            : React.null}
                          <button
                            onClick={_ => copyCsvToClipboard(csvText)}
                            className="px-3 py-1 bg-slate-100 text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors mr-2">
                            {"Copy CSV"->React.string}
                          </button>
                          <button
                            onClick={_ => downloadCsv(csvText)}
                            className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors">
                            {"Download CSV"->React.string}
                          </button>
                          <span className="ml-3 text-xs text-slate-500">
                            {`Showing ${Int.toString(
                                Array.length(displayedRows),
                              )} rows`->React.string}
                          </span>
                        </div>
                        <div
                          className="overflow-x-auto max-h-96 rounded-xl border border-slate-200">
                          <table className="w-full table-fixed border-collapse">
                            <thead>
                              <tr>
                                {columns
                                ->Array.map(col =>
                                  <th
                                    key={col}
                                    className="px-3 py-2 text-left text-xs font-semibold text-slate-700 sticky top-0 z-10 bg-white border-b border-slate-200"
                                    style={{width: fixedColumnWidth, maxWidth: fixedColumnWidth}}>
                                    <div className="flex items-center justify-between">
                                      <button
                                        className="inline-flex items-center gap-1 hover:underline truncate flex-1 text-left"
                                        onClick={_ =>
                                          setSortColumn(prev =>
                                            if prev === Some(col) {
                                              setSortAscending(prevAsc => !prevAsc)
                                              Some(col)
                                            } else {
                                              setSortAscending(_ => true)
                                              Some(col)
                                            }
                                          )}
                                        title={col}>
                                        <span className="truncate">
                                          {smartTruncate(col, 20)->React.string}
                                        </span>
                                        {switch sortColumn {
                                        | Some(active) if active === col =>
                                          <span className="text-slate-400 ml-1">
                                            {sortAscending
                                              ? "↑"->React.string
                                              : "↓"->React.string}
                                          </span>
                                        | _ => React.null
                                        }}
                                      </button>
                                    </div>
                                  </th>
                                )
                                ->React.array}
                              </tr>
                            </thead>
                            <tbody>
                              {displayedRows
                              ->Array.mapWithIndex((r, i) =>
                                <tr
                                  key={Int.toString(i)}
                                  className={mod(i, 2) == 1 ? "bg-slate-50" : "bg-white"}>
                                  {columns
                                  ->Array.map(col => {
                                    let v = Js.Dict.get(r, col)->Belt.Option.getWithDefault("")
                                    <td
                                      key={col}
                                      className="px-3 py-2 text-xs text-slate-800 border-b border-slate-200 font-mono"
                                      style={{width: fixedColumnWidth, maxWidth: fixedColumnWidth}}>
                                      <div className="flex items-center gap-2 overflow-hidden">
                                        <span className="truncate flex-1 cursor-default" title={v}>
                                          {smartTruncate(v, 25)->React.string}
                                        </span>
                                        {String.length(v) > 25
                                          ? <button
                                              title={`Copy: ${v}`}
                                              onClick={_ => copyText(v)}
                                              className="text-slate-400 hover:text-slate-700 shrink-0 px-1 py-0.5 rounded hover:bg-slate-200 transition-colors">
                                              <svg
                                                className="w-3 h-3"
                                                fill="none"
                                                stroke="currentColor"
                                                viewBox="0 0 24 24">
                                                <path
                                                  strokeLinecap="round"
                                                  strokeLinejoin="round"
                                                  strokeWidth="2"
                                                  d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                                                />
                                              </svg>
                                            </button>
                                          : React.null}
                                      </div>
                                    </td>
                                  })
                                  ->React.array}
                                </tr>
                              )
                              ->React.array}
                            </tbody>
                          </table>
                        </div>
                      </div>
                    }
                  }
                | None =>
                  <div
                    className="text-sm text-slate-600 bg-slate-50 border border-slate-200 rounded-xl p-4">
                    {"No tabular rows detected in response"->React.string}
                  </div>
                }
              }}
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
