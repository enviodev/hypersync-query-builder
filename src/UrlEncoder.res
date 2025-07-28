open QueryStructure

// External bindings for Web API using proper ReScript patterns
@val external window: 'a = "window"

// Access window.location properties using @get
@get external location: 'a => 'b = "location"
@get external search: 'a => string = "search"
@get external origin: 'a => string = "origin"
@get external pathname: 'a => string = "pathname"

// Access window.history methods using @send
@get external history: 'a => 'b = "history"
@send external pushState: ('a, 'b, string, string) => unit = "pushState"

// Type for the complete state that includes both query and selectedChainId
type urlState = {
  query: query,
  selectedChainId: option<int>,
}

let serializeUrlState = (state: urlState): string => {
  let json = Js.Json.object_(Js.Dict.fromArray([
    ("query", Js.Json.object_(Js.Dict.fromArray([
      ("fromBlock", Js.Json.number(Int.toFloat(state.query.fromBlock))),
      ("toBlock", switch state.query.toBlock {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("maxNumBlocks", switch state.query.maxNumBlocks {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("maxNumTransactions", switch state.query.maxNumTransactions {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
      ("maxNumLogs", switch state.query.maxNumLogs {
        | Some(value) => Js.Json.number(Int.toFloat(value))
        | None => Js.Json.null
      }),
    ]))),
    ("selectedChainId", switch state.selectedChainId {
      | Some(value) => Js.Json.number(Int.toFloat(value))
      | None => Js.Json.null
    }),
  ]))
  Js.Json.stringify(json)
}

let deserializeUrlState = (jsonString: string): option<urlState> => {
  switch Js.Json.parseExn(jsonString) {
  | json => {
    let obj = Js.Json.decodeObject(json)
    switch obj {
    | Some(obj) => {
      let getField = (fieldName: string) => Js.Dict.get(obj, fieldName)
      
      // Parse query object
      let queryJson = switch getField("query") {
      | Some(value) => value
      | None => Js.Json.null
      }
      
      let queryObj = switch Js.Json.decodeObject(queryJson) {
      | Some(queryObj) => queryObj
      | None => Js.Dict.empty()
      }
      
      let getQueryField = (fieldName: string) => Js.Dict.get(queryObj, fieldName)
      
      let fromBlock = switch getQueryField("fromBlock") {
      | Some(value) => switch Js.Json.decodeNumber(value) {
        | Some(num) => Float.toInt(num)
        | None => 0
        }
      | None => 0
      }
      
      let toBlock = switch getQueryField("toBlock") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumBlocks = switch getQueryField("maxNumBlocks") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumTransactions = switch getQueryField("maxNumTransactions") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumLogs = switch getQueryField("maxNumLogs") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let query = {
        fromBlock,
        toBlock,
        logs: None,
        transactions: None,
        traces: None,
        blocks: None,
        includeAllBlocks: None,
        fieldSelection: {
          block: [],
          transaction: [],
          log: [],
          trace: [],
        },
        maxNumBlocks,
        maxNumTransactions,
        maxNumLogs,
        maxNumTraces: None,
        joinMode: None,
      }
      
      // Parse selectedChainId
      let selectedChainId = switch getField("selectedChainId") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      Some({
        query,
        selectedChainId,
      })
    }
    | None => None
    }
  }
  | exception _ => None
  }
}

let encodeUrlStateToUrl = (state: urlState): string => {
  let jsonString = serializeUrlState(state)
  Js.Global.encodeURIComponent(jsonString)
}

let decodeUrlStateFromUrl = (encodedString: string): option<urlState> => {
  let decodedString = Js.Global.decodeURIComponent(encodedString)
  deserializeUrlState(decodedString)
}

let getUrlStateFromUrl = (): option<urlState> => {
  // Get the search string from window.location using proper bindings
  let locationObj = location(window)
  let searchStr = search(locationObj)
  // Simple URL parameter parsing without Js.Url
  if Js.String2.startsWith(searchStr, "?q=") {
    let encodedQuery = Js.String2.substring(searchStr, ~from=3, ~to_=Js.String2.length(searchStr))
    decodeUrlStateFromUrl(encodedQuery)
  } else {
    None
  }
}

let updateUrlWithState = (state: urlState) => {
  let encodedState = encodeUrlStateToUrl(state)
  let locationObj = location(window)
  let originStr = origin(locationObj)
  let pathnameStr = pathname(locationObj)
  let newUrl = originStr ++ pathnameStr ++ "?q=" ++ encodedState
  let historyObj = history(window)
  pushState(historyObj, null, "", newUrl)
}

// Backward compatibility functions for existing code
let serializeQuery = (query: query): string => {
  serializeUrlState({query, selectedChainId: None})
}

let deserializeQuery = (jsonString: string): option<query> => {
  switch deserializeUrlState(jsonString) {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let encodeQueryToUrl = (query: query): string => {
  encodeUrlStateToUrl({query, selectedChainId: None})
}

let decodeQueryFromUrl = (encodedString: string): option<query> => {
  switch decodeUrlStateFromUrl(encodedString) {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let getQueryFromUrl = (): option<query> => {
  switch getUrlStateFromUrl() {
  | Some(state) => Some(state.query)
  | None => None
  }
}

let updateUrlWithQuery = (query: query) => {
  updateUrlWithState({query, selectedChainId: None})
} 