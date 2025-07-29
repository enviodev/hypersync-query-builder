let serializeQuery: QueryStructure.query => string
let deserializeQuery: string => option<QueryStructure.query>
let encodeQueryToUrl: QueryStructure.query => string
let decodeQueryFromUrl: string => option<QueryStructure.query>
let getQueryFromUrl: unit => option<QueryStructure.query>
let updateUrlWithQuery: QueryStructure.query => unit

// New functions for complete URL state including chain selection
type urlState = {
  query: QueryStructure.query,
  selectedChainId: option<int>,
}

let serializeUrlState: urlState => string
let deserializeUrlState: string => option<urlState>
let encodeUrlStateToUrl: urlState => string
let decodeUrlStateFromUrl: string => option<urlState>
let getUrlStateFromUrl: unit => option<urlState>
let updateUrlWithState: urlState => unit
