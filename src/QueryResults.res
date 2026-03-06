open QueryStructure
open Fetch

type activeTab = QueryJson | Results
type resultsView = Raw | Table
type rawMode = Plain | Interactive

@react.component
let make = (~query: query, ~executeSignal: int) => {
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
  let (copiedCurl, setCopiedCurl) = React.useState(() => false)
  let (copiedJson, setCopiedJson) = React.useState(() => false)
  let (copiedLink, setCopiedLink) = React.useState(() => false)
  let (copiedResults, setCopiedResults) = React.useState(() => false)

  // Switch to QueryJson tab when query changes (but not on initial render)
  let isFirstRender = React.useRef(true)
  React.useEffect1(() => {
    if isFirstRender.current {
      isFirstRender.current = false
    } else if activeTab === Results {
      setActiveTab(_ => QueryJson)
    }
    None
  }, [query])

  let generateChainUrl = () => {
    "/query"
  }

  let serializeInstructionFilter = (filter: instructionSelection) => {
    let programIdJson = switch filter.program_id {
    | Some(ids) if Array.length(ids) > 0 =>
      let idsStr = Array.map(ids, id => `"${id}"`)->Array.join(", ")
      Some(`"program_id": [${idsStr}]`)
    | _ => None
    }

    let d1Json = switch filter.d1 {
    | Some(vals) if Array.length(vals) > 0 =>
      let valsStr = Array.map(vals, v => `"${v}"`)->Array.join(", ")
      Some(`"d1": [${valsStr}]`)
    | _ => None
    }

    let d8Json = switch filter.d8 {
    | Some(vals) if Array.length(vals) > 0 =>
      let valsStr = Array.map(vals, v => `"${v}"`)->Array.join(", ")
      Some(`"d8": [${valsStr}]`)
    | _ => None
    }

    let a0Json = switch filter.a0 {
    | Some(vals) if Array.length(vals) > 0 =>
      let valsStr = Array.map(vals, v => `"${v}"`)->Array.join(", ")
      Some(`"a0": [${valsStr}]`)
    | _ => None
    }

    let isInnerJson = switch filter.is_inner {
    | Some(true) => Some(`"is_inner": true`)
    | Some(false) => Some(`"is_inner": false`)
    | None => None
    }

    let allParts = [programIdJson, d1Json, d8Json, a0Json, isInnerJson]->Array.filterMap(x => x)
    let content = Array.join(allParts, ", ")
    `{${content}}`
  }

  let serializeTransactionFilter = (filter: transactionSelection) => {
    let feePayerJson = switch filter.fee_payer {
    | Some(payers) if Array.length(payers) > 0 =>
      let payersStr = Array.map(payers, p => `"${p}"`)->Array.join(", ")
      Some(`"fee_payer": [${payersStr}]`)
    | _ => None
    }

    let successJson = switch filter.success {
    | Some(true) => Some(`"success": true`)
    | Some(false) => Some(`"success": false`)
    | None => None
    }

    let allParts = [feePayerJson, successJson]->Array.filterMap(x => x)
    let content = Array.join(allParts, ", ")
    `{${content}}`
  }

  let serializeFieldSelection = (fieldSelection: fieldSelection) => {
    let blockFields = Array.map(fieldSelection.block, FieldSelector.blockFieldToSnakeCaseString)
    let transactionFields = Array.map(
      fieldSelection.transaction,
      FieldSelector.transactionFieldToSnakeCaseString,
    )
    let instructionFields = Array.map(
      fieldSelection.instruction,
      FieldSelector.instructionFieldToSnakeCaseString,
    )

    let blockFieldsStr = Array.map(blockFields, field => `"${field}"`)->Array.join(", ")
    let transactionFieldsStr = Array.map(transactionFields, field => `"${field}"`)->Array.join(", ")
    let instructionFieldsStr = Array.map(instructionFields, field => `"${field}"`)->Array.join(", ")

    `"field_selection": {
    "block": [${blockFieldsStr}],
    "transaction": [${transactionFieldsStr}],
    "instruction": [${instructionFieldsStr}]
  }`
  }

  let serializeQuery = (query: query) => {
    let fromSlotPart = `"from_slot": ${Int.toString(query.fromSlot)}`

    let toSlotPart = switch query.toSlot {
    | Some(toSlot) => Some(`"to_slot": ${Int.toString(toSlot)}`)
    | None => None
    }

    let instructionsPart = switch query.instructions {
    | Some(instructions) if Array.length(instructions) > 0 =>
      let instructionsStr =
        Array.map(instructions, serializeInstructionFilter)->Array.join(",\n    ")
      Some(
        `"instructions": [
    ${instructionsStr}
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

    let maxNumInstructionsPart = switch query.maxNumInstructions {
    | Some(max) => Some(`"max_num_instructions": ${Int.toString(max)}`)
    | None => None
    }

    let allParts =
      [
        Some(fromSlotPart),
        toSlotPart,
        instructionsPart,
        transactionsPart,
        includeAllBlocksPart,
        Some(fieldSelectionPart),
        maxNumBlocksPart,
        maxNumTransactionsPart,
        maxNumInstructionsPart,
      ]->Array.filterMap(x => x)

    let content = Array.join(allParts, ",\n  ")
    `{
  ${content}
}`
  }

  let hasValidUrl = () => true

  let executeQuery = async () => {
    setActiveTab(_ => Results)
    setIsExecuting(_ => true)
    setQueryError(_ => None)
    setQueryResult(_ => None)
    setQueryResultJson(_ => None)
    setClientMs(_ => None)
    setServerMs(_ => None)
    setResponseBytes(_ => None)
    setSelectedDataset(_ => None)

    try {
      let url = generateChainUrl()
      let body = serializeQuery(query)
      let calcByteLength: string => int = %raw(`(s) => new TextEncoder().encode(s).length`)
      let t0: float = %raw("performance.now()")

      let headers = Headers.fromObject({
        "Content-Type": "application/json",
      })

      let requestInit = makeRequestInit({
        "method": "POST",
        "body": Body.string(body),
        "headers": headers,
      })

      let response = await fetch(url, requestInit)
      let resultTextRaw = await response->Response.text
      let t1: float = %raw("performance.now()")
      let clientElapsed = t1 -. t0
      setClientMs(_ => Some(Float.toInt(clientElapsed)))
      setResponseBytes(_ => Some(calcByteLength(resultTextRaw)))
      let resultJson = try {
        JSON.parseOrThrow(resultTextRaw)
      } catch {
      | _ => JSON.Encode.string(resultTextRaw)
      }

      if response->Response.ok {
        try {
          let resultText = JSON.stringify(resultJson, ~space=2)
          setQueryResult(_ => Some(resultText))
          setQueryResultJson(_ => Some(resultJson))
          let serverDurationMs =
            resultJson
            ->JSON.Decode.object
            ->Option.flatMap(dict => Dict.get(dict, "total_execution_time"))
            ->Option.flatMap(JSON.Decode.float)
            ->Option.map(Float.toInt)
          setServerMs(_ => serverDurationMs)
        } catch {
        | e =>
          Console.log(e)
          setQueryError(_ => Some("Caught exception - during stringify of json"))
        }
      } else {
        setQueryError(_ => Some(`HTTP ${Int.toString(response->Response.status)}: ${resultTextRaw}`))
      }
    } catch {
    | _ =>
      setQueryError(_ => Some(
        "Network error occurred. Could not reach the Solana HyperSync server at solana-test.hypersync.xyz",
      ))
    }

    setIsExecuting(_ => false)
  }

  // Trigger execute when the inline button is pressed in the parent
  React.useEffect1(() => {
    if executeSignal > 0 {
      executeQuery()->ignore
    }
    None
  }, [executeSignal])

  let generateCurlCommand = (query: query) => {
    let body = serializeQuery(query)
    let escapedBody = String.replaceAll(body, "\"", "\\\"")

    `curl -X POST "https://solana-test.hypersync.xyz/query" \\
  -H "Content-Type: application/json" \\
  -d '${escapedBody}'`
  }

  let copyCurlToClipboard = () => {
    let curlCommand = generateCurlCommand(query)
    let copyToClipboard: string => unit = %raw(`(curlCommand) => {
      navigator.clipboard.writeText(curlCommand).then(() => {
        console.log('cURL command copied to clipboard');
      }).catch(err => {
        console.error('Failed to copy: ', err);
      })
    }`)
    copyToClipboard(curlCommand)
    setCopiedCurl(_ => true)
    let _: timeoutId = setTimeout(() => setCopiedCurl(_ => false), 2000)
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
    setCopiedJson(_ => true)
    let _: timeoutId = setTimeout(() => setCopiedJson(_ => false), 2000)
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
    setCopiedLink(_ => true)
    let _: timeoutId = setTimeout(() => setCopiedLink(_ => false), 2000)
  }

  let downloadJson = () => {
    let jsonText = serializeQuery(query)
    let triggerDownload: string => unit = %raw(`(text) => {
      const blob = new Blob([text], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'solana-hypersync-query.json';
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
        setCopiedResults(_ => true)
        let _: timeoutId = setTimeout(() => setCopiedResults(_ => false), 2000)
      }
    | None => ()
    }
  }

  // ---- Table helpers (analysis, sorting, formatting) ----
  let analyzeColumns: array<dict<string>> => dict<string> = %raw(`(flatRows) => {
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

  let sortFlatRows: (
    array<dict<string>>,
    string,
    string,
    bool,
  ) => array<dict<string>> = %raw(`(rows, col, colType, asc) => {
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

  let copyText: string => unit = %raw(`(text) => {
    navigator.clipboard && navigator.clipboard.writeText(text).catch(() => {});
  }`)

  let getCoreDatasetNames: JSON.t => array<string> = %raw(`(data) => {
    const keys = ['instructions','transactions','blocks'];
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

  let getDatasetRowsByName: (JSON.t, string) => array<JSON.t> = %raw(`(data, name) => {
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

  let fixedColumnWidth = "200px"

  let smartTruncate = (text: string, maxLength: int): string => {
    if String.length(text) <= maxLength {
      text
    } else {
      let half = maxLength / 2 - 2
      let start = String.substring(text, ~start=0, ~end=half)
      let end = String.substring(text, ~start=String.length(text) - half)
      start ++ "..." ++ end
    }
  }

  // Collapsible JSON renderer
  let rec renderJsonNode = (label: string, node: JSON.t, depth: int): React.element => {
    let indent = if depth > 0 {
      "ml-4"
    } else {
      ""
    }
    switch node {
    | JSON.String(s) =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: "${s}"`->React.string}
      </div>
    | JSON.Number(n) =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: ${Float.toString(n)}`->React.string}
      </div>
    | JSON.Boolean(true) =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: true`->React.string}
      </div>
    | JSON.Boolean(false) =>
      <div className={`text-xs ${indent} font-mono text-slate-800`}>
        {`${label}: false`->React.string}
      </div>
    | JSON.Null =>
      <div className={`text-xs ${indent} font-mono text-slate-500`}>
        {`${label}: null`->React.string}
      </div>
    | JSON.Array(arr) =>
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
    | JSON.Object(obj) => {
        let keys = Dict.keysToArray(obj)
        <details className={`text-xs ${indent}`} open_={depth < 1}>
          <summary className="cursor-pointer font-mono text-slate-700">
            {`${label} {}`->React.string}
          </summary>
          <div className="mt-1">
            {keys
            ->Array.map(k => {
              let v = Dict.get(obj, k)->Option.getOr(JSON.Encode.null)
              renderJsonNode(k, v, depth + 1)
            })
            ->React.array}
          </div>
        </details>
      }
    }
  }

  let flattenRows: array<JSON.t> => array<dict<string>> = %raw(`(rows) => {
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

  let detectColumns: array<dict<string>> => array<string> = %raw(`(flatRows) => {
    const cols = new Set();
    for (let i = 0; i < flatRows.length && i < 200; i++) {
      const r = flatRows[i];
      for (const k in r) cols.add(k);
    }
    return Array.from(cols).sort();
  }`)

  let rowsToCsv: array<dict<string>> => string = %raw(`(flatRows) => {
    const cols = (() => {
      const s = new Set();
      for (let i = 0; i < flatRows.length && i < 200; i++) { for (const k in flatRows[i]) s.add(k); }
      return Array.from(s).sort();
    })();
    const esc = (v) => {
      if (v == null) return '';
      const s = String(v);
      if (s.includes('"') || s.includes(',') || s.includes('\\n')) return '"' + s.replaceAll('"','""') + '"';
      return s;
    };
    const lines = [cols.join(',')];
    for (let i = 0; i < flatRows.length && i < 1000; i++) {
      const r = flatRows[i];
      lines.push(cols.map(c => esc(r[c])).join(','));
    }
    return lines.join('\\n');
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
      a.download = 'solana-hypersync-results.csv';
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
      <div className="mt-3">
        <span
          className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200"
        >
          {`Query URL: ${generateChainUrl()}`->React.string}
        </span>
      </div>
    </div>

    // Tab Navigation
    <div
      className="border-b border-slate-200 sticky top-[56px] bg-white/80 backdrop-blur z-10 -mx-6 px-6 mb-6"
    >
      <nav className="flex space-x-8">
        <button
          onClick={_ => setActiveTab(_ => QueryJson)}
          className={`py-3 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab ===
              QueryJson
              ? "border-slate-900 text-slate-900"
              : "border-transparent text-slate-500 hover:text-slate-900 hover:border-slate-300"}`}
        >
          {"Query JSON"->React.string}
        </button>
        <button
          onClick={_ => setActiveTab(_ => Results)}
          className={`py-3 px-1 border-b-2 font-medium text-sm transition-colors ${activeTab ===
              Results
              ? "border-slate-900 text-slate-900"
              : "border-transparent text-slate-500 hover:text-slate-900 hover:border-slate-300"}`}
        >
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
            {hasValidUrl()
              ? <div className="flex space-x-2">
                  <button
                    onClick={_ => copyCurlToClipboard()}
                    className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-slate-500 ${copiedCurl
                        ? "bg-emerald-600 text-white"
                        : "bg-slate-600 text-white hover:bg-slate-700"}`}
                  >
                    {copiedCurl
                      ? <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M5 13l4 4L19 7"
                            />
                          </svg>
                          {"Copied!"->React.string}
                        </>
                      : <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                            />
                          </svg>
                          {"Copy cURL"->React.string}
                        </>}
                  </button>
                  <button
                    onClick={_ => copyJsonToClipboard()}
                    className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg border transition-colors focus:outline-none focus:ring-2 focus:ring-slate-500 ${copiedJson
                        ? "bg-emerald-100 text-emerald-700 border-emerald-200"
                        : "bg-slate-100 text-slate-700 hover:bg-slate-200 border-slate-200"}`}
                  >
                    {copiedJson
                      ? <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M5 13l4 4L19 7"
                            />
                          </svg>
                          {"Copied!"->React.string}
                        </>
                      : <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                            />
                          </svg>
                          {"Copy JSON"->React.string}
                        </>}
                  </button>
                  <button
                    onClick={_ => downloadJson()}
                    className="inline-flex items-center px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors"
                  >
                    <svg
                      className="w-3.5 h-3.5 mr-1.5"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                      />
                    </svg>
                    {"Download"->React.string}
                  </button>
                  <button
                    onClick={_ => copyShareLinkToClipboard()}
                    className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg border transition-colors focus:outline-none focus:ring-2 focus:ring-slate-500 ${copiedLink
                        ? "bg-emerald-100 text-emerald-700 border-emerald-200"
                        : "bg-white text-slate-700 hover:bg-slate-50 border-slate-200"}`}
                  >
                    {copiedLink
                      ? <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M5 13l4 4L19 7"
                            />
                          </svg>
                          {"Copied!"->React.string}
                        </>
                      : <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                            />
                          </svg>
                          {"Copy Query Link"->React.string}
                        </>}
                  </button>
                  <button
                    onClick={_ => executeQuery()->ignore}
                    disabled={isExecuting}
                    className="inline-flex items-center px-3 py-1 bg-slate-700 text-white text-xs font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 disabled:opacity-50 transition-colors"
                  >
                    {(isExecuting ? "Executing..." : "Execute Query")->React.string}
                  </button>
                </div>
              : React.null}
          </div>
          <pre
            className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm font-mono overflow-x-auto whitespace-pre"
          >
            {serializeQuery(query)->React.string}
          </pre>
        </div>

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
                  viewBox="0 0 24 24"
                >
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
                    className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700 mr-3"
                  >
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
                    className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg border transition-colors focus:outline-none focus:ring-2 focus:ring-slate-500 mr-2 ${copiedResults
                        ? "bg-emerald-100 text-emerald-700 border-emerald-200"
                        : "bg-white text-slate-700 hover:bg-slate-50 border-slate-200"}`}
                  >
                    {copiedResults
                      ? <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M5 13l4 4L19 7"
                            />
                          </svg>
                          {"Copied!"->React.string}
                        </>
                      : <>
                          <svg
                            className="w-3.5 h-3.5 mr-1.5"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth="2"
                              d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                            />
                          </svg>
                          {"Copy Results JSON"->React.string}
                        </>}
                  </button>
                  <div className="inline-flex items-center">
                    <button
                      onClick={_ => setResultsView(_ => Raw)}
                      className={`px-3 py-1 text-xs font-medium rounded-l-lg border border-slate-200 ${resultsView ===
                          Raw
                          ? "bg-slate-800 text-white"
                          : "bg-white text-slate-700 hover:bg-slate-50"}`}
                    >
                      {"Raw"->React.string}
                    </button>
                    <button
                      onClick={_ => setResultsView(_ => Table)}
                      className={`px-3 py-1 text-xs font-medium rounded-r-lg border border-slate-200 border-l-0 ${resultsView ===
                          Table
                          ? "bg-slate-800 text-white"
                          : "bg-white text-slate-700 hover:bg-slate-50"}`}
                    >
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
                        className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors"
                      >
                        {"Interactive JSON"->React.string}
                      </button>
                    </div>
                    <pre
                      className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm font-mono overflow-x-auto whitespace-pre max-h-96"
                    >
                      {result->React.string}
                    </pre>
                  </div>
                | Interactive =>
                  <div>
                    <div className="mb-2">
                      <button
                        onClick={_ => setRawMode(_ => Plain)}
                        className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors"
                      >
                        {"Plain JSON"->React.string}
                      </button>
                    </div>
                    <div
                      className="bg-slate-50 border border-slate-200 rounded-xl p-4 max-h-96 overflow-auto"
                    >
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
                        className="text-sm text-slate-600 bg-slate-50 border border-slate-200 rounded-xl p-4"
                      >
                        {"No tabular rows detected in response"->React.string}
                      </div>
                    } else {
                      let flatRows = flattenRows(rowsJson)
                      let columns = detectColumns(flatRows)
                      let csvText = rowsToCsv(flatRows)
                      let columnTypes = analyzeColumns(flatRows)
                      let displayedRows = switch sortColumn {
                      | Some(col) =>
                        let colType = Dict.get(columnTypes, col)->Belt.Option.getWithDefault("text")
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
                                  className="inline-flex rounded-lg border border-slate-200 overflow-hidden"
                                >
                                  {datasetNames
                                  ->Array.map(name =>
                                    <button
                                      key={name}
                                      onClick={_ => setSelectedDataset(_ => Some(name))}
                                      className={`px-3 py-1 text-xs ${name === effectiveDataset
                                          ? "bg-slate-800 text-white"
                                          : "bg-white text-slate-700 hover:bg-slate-50"}`}
                                    >
                                      {name->React.string}
                                    </button>
                                  )
                                  ->React.array}
                                </div>
                              </div>
                            : React.null}
                          <button
                            onClick={_ => copyCsvToClipboard(csvText)}
                            className="px-3 py-1 bg-slate-100 text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors mr-2"
                          >
                            {"Copy CSV"->React.string}
                          </button>
                          <button
                            onClick={_ => downloadCsv(csvText)}
                            className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 border border-slate-200 transition-colors"
                          >
                            {"Download CSV"->React.string}
                          </button>
                          <span className="ml-3 text-xs text-slate-500">
                            {`Showing ${Int.toString(
                                Array.length(displayedRows),
                              )} rows`->React.string}
                          </span>
                        </div>
                        <div
                          className="overflow-x-auto max-h-96 rounded-xl border border-slate-200"
                        >
                          <table className="w-full table-fixed border-collapse">
                            <thead>
                              <tr>
                                {columns
                                ->Array.map(col =>
                                  <th
                                    key={col}
                                    className="px-3 py-2 text-left text-xs font-semibold text-slate-700 sticky top-0 z-10 bg-white border-b border-slate-200"
                                    style={{width: fixedColumnWidth, maxWidth: fixedColumnWidth}}
                                  >
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
                                        title={col}
                                      >
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
                                  className={mod(i, 2) == 1 ? "bg-slate-50" : "bg-white"}
                                >
                                  {columns
                                  ->Array.map(col => {
                                    let v = Dict.get(r, col)->Belt.Option.getWithDefault("")
                                    <td
                                      key={col}
                                      className="px-3 py-2 text-xs text-slate-800 border-b border-slate-200 font-mono"
                                      style={{width: fixedColumnWidth, maxWidth: fixedColumnWidth}}
                                    >
                                      <div className="flex items-center gap-2 overflow-hidden">
                                        <span className="truncate flex-1 cursor-default" title={v}>
                                          {smartTruncate(v, 25)->React.string}
                                        </span>
                                        {String.length(v) > 25
                                          ? <button
                                              title={`Copy: ${v}`}
                                              onClick={_ => copyText(v)}
                                              className="text-slate-400 hover:text-slate-700 shrink-0 px-1 py-0.5 rounded hover:bg-slate-200 transition-colors"
                                            >
                                              <svg
                                                className="w-3 h-3"
                                                fill="none"
                                                stroke="currentColor"
                                                viewBox="0 0 24 24"
                                              >
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
                    className="text-sm text-slate-600 bg-slate-50 border border-slate-200 rounded-xl p-4"
                  >
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
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800"
                >
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
                  viewBox="0 0 24 24"
                >
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
              <div className="mt-4 flex justify-center space-x-2">
                <button
                  onClick={_ => copyCurlToClipboard()}
                  className="px-4 py-2 bg-slate-600 text-white text-sm font-medium rounded-lg hover:bg-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors"
                >
                  {"Copy cURL"->React.string}
                </button>
                <button
                  onClick={_ => executeQuery()->ignore}
                  className="px-4 py-2 bg-slate-700 text-white text-sm font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors"
                >
                  {"Execute Query"->React.string}
                </button>
              </div>
            </div>
          }}
        </div>
      }}
    </div>
  </div>
}
