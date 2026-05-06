open SolanaQueryStructure
open Fetch

type activeTab = QueryJson | Results
type resultsView = Raw | Table
type rawMode = Plain | Interactive

let solanaEndpoint = "https://solana-near-head-test.hypersync.xyz/query"

let strList = (arr: array<string>): string => arr->Array.map(s => `"${s}"`)->Array.join(", ")

let serializeInstructionFilter = (sel: instructionSelection): string => {
  let parts: array<option<string>> = [
    switch sel.programId {
    | Some(arr) if Array.length(arr) > 0 => Some(`"program_id": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.d1 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"d1": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.d2 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"d2": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.d4 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"d4": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.d8 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"d8": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a0 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a0": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a1 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a1": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a2 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a2": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a3 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a3": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a4 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a4": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a5 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a5": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a6 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a6": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a7 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a7": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a8 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a8": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.a9 {
    | Some(arr) if Array.length(arr) > 0 => Some(`"a9": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.isInner {
    | Some(true) => Some(`"is_inner": true`)
    | Some(false) => Some(`"is_inner": false`)
    | None => None
    },
    sel.includeTransaction ? Some(`"include_transaction": true`) : None,
    sel.includeLogs ? Some(`"include_logs": true`) : None,
  ]
  let active = parts->Array.filterMap(x => x)
  `{${Array.join(active, ", ")}}`
}

let serializeTransactionFilter = (sel: transactionSelection): string => {
  let parts: array<option<string>> = [
    switch sel.feePayer {
    | Some(arr) if Array.length(arr) > 0 => Some(`"fee_payer": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.success {
    | Some(true) => Some(`"success": true`)
    | Some(false) => Some(`"success": false`)
    | None => None
    },
    sel.includeInstructions ? Some(`"include_instructions": true`) : None,
  ]
  let active = parts->Array.filterMap(x => x)
  `{${Array.join(active, ", ")}}`
}

let serializeLogFilter = (sel: logSelection): string => {
  let parts: array<option<string>> = [
    switch sel.programId {
    | Some(arr) if Array.length(arr) > 0 => Some(`"program_id": [${strList(arr)}]`)
    | _ => None
    },
    switch sel.kind {
    | Some(arr) if Array.length(arr) > 0 => Some(`"kind": [${strList(arr)}]`)
    | _ => None
    },
    sel.includeTransaction ? Some(`"include_transaction": true`) : None,
    sel.includeInstruction ? Some(`"include_instruction": true`) : None,
  ]
  let active = parts->Array.filterMap(x => x)
  `{${Array.join(active, ", ")}}`
}

let serializeFields = (fs: fieldSelection): string => {
  let blockArr = fs.block->Array.map(f => `"${blockFieldToSnake(f)}"`)->Array.join(", ")
  let txnArr = fs.transaction->Array.map(f => `"${transactionFieldToSnake(f)}"`)->Array.join(", ")
  let instrArr = fs.instruction->Array.map(f => `"${instructionFieldToSnake(f)}"`)->Array.join(", ")
  let logArr = fs.log->Array.map(f => `"${logFieldToSnake(f)}"`)->Array.join(", ")
  let balArr = fs.balance->Array.map(f => `"${balanceFieldToSnake(f)}"`)->Array.join(", ")
  let tbArr = fs.tokenBalance->Array.map(f => `"${tokenBalanceFieldToSnake(f)}"`)->Array.join(", ")
  let rewArr = fs.reward->Array.map(f => `"${rewardFieldToSnake(f)}"`)->Array.join(", ")
  `"fields": {
    "block": [${blockArr}],
    "transaction": [${txnArr}],
    "instruction": [${instrArr}],
    "log": [${logArr}],
    "balance": [${balArr}],
    "token_balance": [${tbArr}],
    "reward": [${rewArr}]
  }`
}

let serializeQuery = (q: query): string => {
  let parts: array<option<string>> = [
    Some(`"from_slot": ${Int.toString(q.fromSlot)}`),
    switch q.toSlot {
    | Some(v) => Some(`"to_slot": ${Int.toString(v)}`)
    | None => None
    },
    switch q.instructions {
    | Some(arr) if Array.length(arr) > 0 =>
      let body = arr->Array.map(serializeInstructionFilter)->Array.join(",\n    ")
      Some(
        `"instructions": [
    ${body}
  ]`,
      )
    | _ => None
    },
    switch q.transactions {
    | Some(arr) if Array.length(arr) > 0 =>
      let body = arr->Array.map(serializeTransactionFilter)->Array.join(",\n    ")
      Some(
        `"transactions": [
    ${body}
  ]`,
      )
    | _ => None
    },
    switch q.logs {
    | Some(arr) if Array.length(arr) > 0 =>
      let body = arr->Array.map(serializeLogFilter)->Array.join(",\n    ")
      Some(
        `"logs": [
    ${body}
  ]`,
      )
    | _ => None
    },
    switch q.includeAllBlocks {
    | Some(true) => Some(`"include_all_blocks": true`)
    | Some(false) => Some(`"include_all_blocks": false`)
    | None => None
    },
    Some(serializeFields(q.fields)),
    switch q.maxNumBlocks {
    | Some(v) => Some(`"max_num_blocks": ${Int.toString(v)}`)
    | None => None
    },
    switch q.maxNumTransactions {
    | Some(v) => Some(`"max_num_transactions": ${Int.toString(v)}`)
    | None => None
    },
    switch q.maxNumInstructions {
    | Some(v) => Some(`"max_num_instructions": ${Int.toString(v)}`)
    | None => None
    },
    switch q.maxNumLogs {
    | Some(v) => Some(`"max_num_logs": ${Int.toString(v)}`)
    | None => None
    },
  ]
  let active = parts->Array.filterMap(x => x)
  `{
  ${Array.join(active, ",\n  ")}
}`
}

@react.component
let make = (~query: query, ~executeSignal: int, ~bearerToken: option<string>) => {
  let (activeTab, setActiveTab) = React.useState(() => QueryJson)
  let (isExecuting, setIsExecuting) = React.useState(() => false)
  let (queryResult, setQueryResult) = React.useState(() => None)
  let (queryError, setQueryError) = React.useState(() => None)
  let (queryResultJson, setQueryResultJson) = React.useState(() => None)
  let (resultsView, setResultsView) = React.useState(() => Table)
  let (rawMode, setRawMode) = React.useState(() => Plain)
  let (clientMs, setClientMs) = React.useState(() => None)
  let (serverMs, setServerMs) = React.useState(() => None)
  let (responseBytes, setResponseBytes) = React.useState(() => None)
  let (selectedDataset, setSelectedDataset) = React.useState(() => None)
  let (sortColumn, setSortColumn) = React.useState(() => None)
  let (sortAscending, setSortAscending) = React.useState(() => true)
  let (copiedCurl, setCopiedCurl) = React.useState(() => false)
  let (copiedJson, setCopiedJson) = React.useState(() => false)
  let (copiedResults, setCopiedResults) = React.useState(() => false)

  let isFirstRender = React.useRef(true)
  React.useEffect1(() => {
    if isFirstRender.current {
      isFirstRender.current = false
    } else if activeTab === Results {
      setActiveTab(_ => QueryJson)
    }
    None
  }, [query])

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
      let body = serializeQuery(query)
      let calcByteLength: string => int = %raw(`(s) => new TextEncoder().encode(s).length`)
      let t0: float = %raw("performance.now()")
      let headers = switch bearerToken {
      | Some(token) =>
        Headers.fromObject({
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`,
        })
      | None => Headers.fromObject({"Content-Type": "application/json"})
      }
      let requestInit = makeRequestInit({
        "method": "POST",
        "body": Body.string(body),
        "headers": headers,
      })
      let response = await fetch(solanaEndpoint, requestInit)
      let resultTextRaw = await response->Response.text
      let t1: float = %raw("performance.now()")
      let clientElapsed = t1 -. t0
      setClientMs(_ => Some(Float.toInt(clientElapsed)))
      setResponseBytes(_ => Some(calcByteLength(resultTextRaw)))
      let resultJson = try {JSON.parseOrThrow(resultTextRaw)} catch {
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
            ->Option.flatMap(d => Dict.get(d, "total_execution_time_ms"))
            ->Option.flatMap(JSON.Decode.float)
            ->Option.map(Float.toInt)
          setServerMs(_ => serverDurationMs)
        } catch {
        | _ => setQueryError(_ => Some("Failed to stringify response JSON"))
        }
      } else {
        setQueryError(_ => Some(
          `HTTP ${Int.toString(response->Response.status)}: ${resultTextRaw}`,
        ))
      }
    } catch {
    | _ => setQueryError(_ => Some("Network error occurred"))
    }
    setIsExecuting(_ => false)
  }

  React.useEffect1(() => {
    // Skip auto-execute on mount; only run when the user explicitly fires it
    if executeSignal > 0 {
      executeQuery()->ignore
    }
    None
  }, [executeSignal])

  let generateCurlCommand = () => {
    let body = serializeQuery(query)
    let escaped = String.replaceAll(body, "\"", "\\\"")
    let authHeader = switch bearerToken {
    | Some(token) => `\n  -H "Authorization: Bearer ${token}" \\`
    | None => ""
    }
    `curl -X POST "${solanaEndpoint}" \\
  -H "Content-Type: application/json" \\${authHeader}
  -d "${escaped}"`
  }

  let copyToClipboard: string => unit = %raw(`(text) => {
    navigator.clipboard.writeText(text).catch(() => {})
  }`)

  let copyCurl = () => {
    copyToClipboard(generateCurlCommand())
    setCopiedCurl(_ => true)
    let _: timeoutId = setTimeout(() => setCopiedCurl(_ => false), 2000)
  }

  let copyJson = () => {
    copyToClipboard(serializeQuery(query))
    setCopiedJson(_ => true)
    let _: timeoutId = setTimeout(() => setCopiedJson(_ => false), 2000)
  }

  let downloadJson = () => {
    let jsonText = serializeQuery(query)
    let triggerDownload: string => unit = %raw(`(text) => {
      const blob = new Blob([text], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'hypersync-solana-query.json';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }`)
    triggerDownload(jsonText)
  }

  let copyResultsJson = () =>
    switch queryResult {
    | Some(r) =>
      copyToClipboard(r)
      setCopiedResults(_ => true)
      let _: timeoutId = setTimeout(() => setCopiedResults(_ => false), 2000)
    | None => ()
    }

  let formatBytes: int => string = %raw(`(b) => {
    if (b < 1024) return b + ' B';
    if (b < 1024*1024) return (Math.round(b/102.4)/10) + ' KB';
    return (Math.round(b/104857.6)/10) + ' MB';
  }`)

  // Solana response: { blocks: Vec<Vec<row>>, transactions: ..., ... }
  // Flatten the outer batches into a single row array
  // Only include datasets that actually have rows, so the switcher matches reality
  let solanaDatasetNames: JSON.t => array<string> = %raw(`(data) => {
    if (!data || typeof data !== 'object' || Array.isArray(data)) return [];
    const known = ['blocks','transactions','instructions','logs','balances','token_balances','rewards'];
    const out = [];
    for (const k of known) {
      const v = data[k];
      if (!Array.isArray(v)) continue;
      let total = 0;
      for (const batch of v) {
        if (Array.isArray(batch)) total += batch.length;
        else total += 1;
        if (total > 0) break;
      }
      if (total > 0) out.push(k);
    }
    return out;
  }`)

  let solanaDatasetRows: (JSON.t, string) => array<JSON.t> = %raw(`(data, name) => {
    if (!data || typeof data !== 'object') return [];
    const v = data[name];
    if (!Array.isArray(v)) return [];
    // v is Vec<Vec<row>> — flatten
    let out = [];
    for (const batch of v) {
      if (Array.isArray(batch)) out = out.concat(batch);
      else out.push(batch);
    }
    return out;
  }`)

  let flattenRows: array<JSON.t> => array<dict<string>> = %raw(`(rows) => {
    const flat = (obj, prefix) => {
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
    return rows.map(r => flat(r, ''));
  }`)

  let detectColumns: array<dict<string>> => array<string> = %raw(`(flatRows) => {
    const cols = new Set();
    for (let i = 0; i < flatRows.length && i < 200; i++) {
      const r = flatRows[i];
      for (const k in r) cols.add(k);
    }
    return Array.from(cols).sort();
  }`)

  let analyzeColumns: array<dict<string>> => dict<string> = %raw(`(flatRows) => {
    const isNumeric = (v) => typeof v === 'string' && /^-?\d+(?:\.\d+)?$/.test(v.trim());
    const counts = new Map();
    for (let i = 0; i < flatRows.length && i < 200; i++) {
      const r = flatRows[i];
      for (const k in r) {
        const v = r[k];
        const t = isNumeric(v) ? 'numeric' : 'text';
        const m = counts.get(k) || { numeric: 0, text: 0 };
        m[t]++;
        counts.set(k, m);
      }
    }
    const out = {};
    counts.forEach((m, k) => { out[k] = (m.numeric >= m.text) ? 'numeric' : 'text'; });
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
      return String(av ?? '').localeCompare(String(bv ?? ''));
    };
    arr.sort((a, b) => asc ? cmp(a, b) : -cmp(a, b));
    return arr;
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
      if (s.includes('"') || s.includes(',') || s.includes('\n')) return '"' + s.replaceAll('"','""') + '"';
      return s;
    };
    const lines = [cols.join(',')];
    for (let i = 0; i < flatRows.length && i < 1000; i++) {
      lines.push(cols.map(c => esc(flatRows[i][c])).join(','));
    }
    return lines.join('\n');
  }`)

  let downloadCsv = (csv: string) => {
    let trigger: string => unit = %raw(`(text) => {
      const blob = new Blob([text], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'hypersync-solana-results.csv';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }`)
    trigger(csv)
  }

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

  let copyText: string => unit = %raw(`(text) => {
    navigator.clipboard && navigator.clipboard.writeText(text).catch(() => {});
  }`)

  let fixedColumnWidth = "200px"

  let rec renderJsonNode = (label: string, node: JSON.t, depth: int): React.element => {
    let indent = depth > 0 ? "ml-4" : ""
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
    | JSON.Object(obj) =>
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

  <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-slate-900 mb-2"> {"Results"->React.string} </h3>
      <p className="text-sm text-slate-600">
        {"View your Solana query structure and results"->React.string}
      </p>
      <div className="mt-3">
        <span
          className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-700 border border-slate-200"
        >
          {`Query URL: ${solanaEndpoint}`->React.string}
        </span>
      </div>
    </div>

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

    <div className="min-h-96">
      {switch activeTab {
      | QueryJson =>
        <div>
          <div className="flex items-center justify-between mb-3">
            <h4 className="text-sm font-medium text-slate-900">
              {"Query Structure"->React.string}
            </h4>
            <div className="flex space-x-2">
              <button
                onClick={_ => copyCurl()}
                className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg transition-colors ${copiedCurl
                    ? "bg-emerald-600 text-white"
                    : "bg-slate-600 text-white hover:bg-slate-700"}`}
              >
                {(copiedCurl ? "Copied!" : "Copy cURL")->React.string}
              </button>
              <button
                onClick={_ => copyJson()}
                className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg border transition-colors ${copiedJson
                    ? "bg-emerald-100 text-emerald-700 border-emerald-200"
                    : "bg-slate-100 text-slate-700 hover:bg-slate-200 border-slate-200"}`}
              >
                {(copiedJson ? "Copied!" : "Copy JSON")->React.string}
              </button>
              <button
                onClick={_ => downloadJson()}
                className="inline-flex items-center px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 border border-slate-200 transition-colors"
              >
                {"Download"->React.string}
              </button>
              <button
                onClick={_ => executeQuery()->ignore}
                disabled={isExecuting}
                className="inline-flex items-center px-3 py-1 bg-slate-700 text-white text-xs font-medium rounded-lg hover:bg-slate-800 disabled:opacity-50 transition-colors"
              >
                {(isExecuting ? "Executing..." : "Execute Query")->React.string}
              </button>
            </div>
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
                    className={`inline-flex items-center px-3 py-1 text-xs font-medium rounded-lg border transition-colors mr-2 ${copiedResults
                        ? "bg-emerald-100 text-emerald-700 border-emerald-200"
                        : "bg-white text-slate-700 hover:bg-slate-50 border-slate-200"}`}
                  >
                    {(copiedResults ? "Copied!" : "Copy Results JSON")->React.string}
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
                  // Solana responses can be huge (10MB+); cap the inline pre-block
                  // so the browser does not freeze trying to render millions of chars.
                  let maxLen = 500_000
                  let resultLen = String.length(result)
                  let displayResult = if resultLen > maxLen {
                    String.substring(result, ~start=0, ~end=maxLen) ++
                    `\n\n... (truncated, ${Int.toString(
                        resultLen - maxLen,
                      )} more chars - use "Copy Results JSON" or switch to Table view)`
                  } else {
                    result
                  }
                  <div>
                    <div className="mb-2 flex items-center gap-2">
                      <button
                        onClick={_ => setRawMode(_ => Interactive)}
                        className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 border border-slate-200 transition-colors"
                      >
                        {"Interactive JSON"->React.string}
                      </button>
                      {resultLen > maxLen
                        ? <span className="text-xs text-amber-700">
                            {`Response is ${formatBytes(
                                resultLen,
                              )} - preview truncated`->React.string}
                          </span>
                        : React.null}
                    </div>
                    <pre
                      className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-sm font-mono overflow-x-auto whitespace-pre max-h-96"
                    >
                      {displayResult->React.string}
                    </pre>
                  </div>
                | Interactive =>
                  <div>
                    <div className="mb-2">
                      <button
                        onClick={_ => setRawMode(_ => Plain)}
                        className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 border border-slate-200 transition-colors"
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
                    let datasetNames = solanaDatasetNames(json)
                    let effectiveDataset = switch selectedDataset {
                    | Some(name) => name
                    | None =>
                      Array.length(datasetNames) > 0 ? Belt.Array.getExn(datasetNames, 0) : "blocks"
                    }
                    let rowsJson = solanaDatasetRows(json, effectiveDataset)
                    if Array.length(rowsJson) == 0 {
                      <div
                        className="text-sm text-slate-600 bg-slate-50 border border-slate-200 rounded-xl p-4"
                      >
                        {"No tabular rows in this dataset"->React.string}
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
                            onClick={_ => copyText(csvText)}
                            className="px-3 py-1 bg-slate-100 text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-200 border border-slate-200 transition-colors mr-2"
                          >
                            {"Copy CSV"->React.string}
                          </button>
                          <button
                            onClick={_ => downloadCsv(csvText)}
                            className="px-3 py-1 bg-white text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-50 border border-slate-200 transition-colors"
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
                                      style={{
                                        width: fixedColumnWidth,
                                        maxWidth: fixedColumnWidth,
                                      }}
                                    >
                                      <div className="flex items-center gap-2 overflow-hidden">
                                        <span className="truncate flex-1 cursor-default" title={v}>
                                          {smartTruncate(v, 25)->React.string}
                                        </span>
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
                    {"No data to display"->React.string}
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
                  onClick={_ => copyCurl()}
                  className="px-4 py-2 bg-slate-600 text-white text-sm font-medium rounded-lg hover:bg-slate-700 transition-colors"
                >
                  {"Copy cURL"->React.string}
                </button>
                <button
                  onClick={_ => executeQuery()->ignore}
                  className="px-4 py-2 bg-slate-700 text-white text-sm font-medium rounded-lg hover:bg-slate-800 transition-colors"
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
