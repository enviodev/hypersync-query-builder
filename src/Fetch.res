// Modern Fetch API bindings for ReScript v12
// This replaces @glennsl/rescript-fetch which is incompatible with ReScript v12

type response

type headers

type requestInit

@val
external fetch: (string, requestInit) => promise<response> = "fetch"

@val
external fetchSimple: string => promise<response> = "fetch"

let makeRequestInit: {..} => requestInit = %raw(`(obj) => obj`)

module Headers = {
  @new external make: unit => headers = "Headers"

  @new external fromObject: {..} => headers = "Headers"

  @send external append: (headers, string, string) => unit = "append"
  @send external delete: (headers, string) => unit = "delete"
  @send external get: (headers, string) => Nullable.t<string> = "get"
  @send external has: (headers, string) => bool = "has"
  @send external set: (headers, string, string) => unit = "set"
}

module Body = {
  let string = (s: string) => s
}

module Response = {
  @send external text: response => promise<string> = "text"
  @send external json: response => promise<JSON.t> = "json"
  @send external arrayBuffer: response => promise<Js.TypedArray2.ArrayBuffer.t> = "arrayBuffer"
  @send external blob: response => promise<'a> = "blob"

  @get external ok: response => bool = "ok"
  @get external status: response => int = "status"
  @get external statusText: response => string = "statusText"
  @get external headers: response => headers = "headers"
  @get external url: response => string = "url"
}
