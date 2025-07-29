open Test
open QueryStructure
open UrlEncoder

let sampleQuery: query = {
  fromBlock: 0,
  toBlock: Some(10),
  logs: None,
  transactions: None,
  traces: None,
  blocks: None,
  includeAllBlocks: Some(false),
  fieldSelection: {
    block: [Number],
    transaction: [Hash],
    log: [Address],
    trace: [],
  },
  maxNumBlocks: Some(10),
  maxNumTransactions: Some(5),
  maxNumLogs: Some(2),
  maxNumTraces: None,
  joinMode: Some(Default),
}

let sampleState: urlState = {
  query: sampleQuery,
  selectedChainName: Some("eth"),
}

test("encode and decode url state", () => {
  let encoded = encodeUrlStateToUrl(sampleState)
  switch decodeUrlStateFromUrl(encoded) {
  | Some(decoded) => assertEqual(serializeUrlState(decoded), serializeUrlState(sampleState))
  | None => assertEqual(true, false)
  }
})
