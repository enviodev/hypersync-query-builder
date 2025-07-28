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

let serializeQuery = (query: query): string => {
  let json = Js.Json.object_(Js.Dict.fromArray([
    ("fromBlock", Js.Json.number(Int.toFloat(query.fromBlock))),
    ("toBlock", switch query.toBlock {
      | Some(value) => Js.Json.number(Int.toFloat(value))
      | None => Js.Json.null
    }),
    ("maxNumBlocks", switch query.maxNumBlocks {
      | Some(value) => Js.Json.number(Int.toFloat(value))
      | None => Js.Json.null
    }),
    ("maxNumTransactions", switch query.maxNumTransactions {
      | Some(value) => Js.Json.number(Int.toFloat(value))
      | None => Js.Json.null
    }),
    ("maxNumLogs", switch query.maxNumLogs {
      | Some(value) => Js.Json.number(Int.toFloat(value))
      | None => Js.Json.null
    }),
  ]))
  Js.Json.stringify(json)
}

let deserializeQuery = (jsonString: string): option<query> => {
  switch Js.Json.parseExn(jsonString) {
  | json => {
    let obj = Js.Json.decodeObject(json)
    switch obj {
    | Some(obj) => {
      let getField = (fieldName: string) => Js.Dict.get(obj, fieldName)
      
      let fromBlock = switch getField("fromBlock") {
      | Some(value) => switch Js.Json.decodeNumber(value) {
        | Some(num) => Float.toInt(num)
        | None => 0
        }
      | None => 0
      }
      
      let toBlock = switch getField("toBlock") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumBlocks = switch getField("maxNumBlocks") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumTransactions = switch getField("maxNumTransactions") {
      | Some(value) => switch Js.Json.decodeNull(value) {
        | Some(_) => None
        | None => switch Js.Json.decodeNumber(value) {
          | Some(num) => Some(Float.toInt(num))
          | None => None
          }
        }
      | None => None
      }
      
      let maxNumLogs = switch getField("maxNumLogs") {
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
      })
    }
    | None => None
    }
  }
  | exception _ => None
  }
}

let encodeQueryToUrl = (query: query): string => {
  let jsonString = serializeQuery(query)
  Js.Global.encodeURIComponent(jsonString)
}

let decodeQueryFromUrl = (encodedString: string): option<query> => {
  let decodedString = Js.Global.decodeURIComponent(encodedString)
  deserializeQuery(decodedString)
}

let getQueryFromUrl = (): option<query> => {
  // Get the search string from window.location using proper bindings
  let locationObj = location(window)
  let searchStr = search(locationObj)
  // Simple URL parameter parsing without Js.Url
  if Js.String2.startsWith(searchStr, "?q=") {
    let encodedQuery = Js.String2.substring(searchStr, ~from=3, ~to_=Js.String2.length(searchStr))
    decodeQueryFromUrl(encodedQuery)
  } else {
    None
  }
}

let updateUrlWithQuery = (query: query) => {
  let encodedQuery = encodeQueryToUrl(query)
  let locationObj = location(window)
  let originStr = origin(locationObj)
  let pathnameStr = pathname(locationObj)
  let newUrl = originStr ++ pathnameStr ++ "?q=" ++ encodedQuery
  let historyObj = history(window)
  pushState(historyObj, null, "", newUrl)
} 