open QueryStructure

@val external window: 'a = "window"

@get external location: 'a => 'b = "location"
@get external search: 'a => string = "search"
@get external origin: 'a => string = "origin"
@get external pathname: 'a => string = "pathname"

@get external history: 'a => 'b = "history"
@send external pushState: ('a, 'b, string, string) => unit = "pushState"

type urlState = {
  query: query,
  selectedChainName: option<string>,
}

%%raw(`import * as pako from 'pako'`)

let compressToBase64Url: string => string = %raw(`
  function(jsonString) {
    const compressed = pako.deflate(jsonString);
    let binary = '';
    for (let i = 0; i < compressed.length; i++) {
      binary += String.fromCharCode(compressed[i]);
    }
    const base64 = btoa(binary);
    return base64
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
  }
`)

let decompressFromBase64Url: string => option<string> = %raw(`
  function(encoded) {
    try {
      let base64 = encoded
        .replace(/-/g, '+')
        .replace(/_/g, '/');
      while (base64.length % 4) {
        base64 += '=';
      }
      const binary = atob(base64);
      const bytes = new Uint8Array(binary.length);
      for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
      }
      const jsonString = pako.inflate(bytes, { to: 'string' });
      return jsonString;
    } catch (e) {
      return undefined;
    }
  }
`)

let isLegacyUrlEncoded: string => bool = %raw(`
  function(str) {
    return str.startsWith('%7B') || str.startsWith('%7b') || str.startsWith('{');
  }
`)

// Helper functions to serialize/deserialize field enums
let serializeBlockField = (field: blockField): string =>
  FieldSelector.blockFieldToCamelCaseString(field)

let deserializeBlockField = (str: string): option<blockField> => {
  let snake = FieldSelector.camelToSnake(str)
  Array.find(QueryStructure.allBlockFields, f =>
    FieldSelector.blockFieldToSnakeCaseString(f) == snake
  )
}

let serializeTransactionField = (field: transactionField): string =>
  FieldSelector.transactionFieldToCamelCaseString(field)

let deserializeTransactionField = (str: string): option<transactionField> => {
  let snake = FieldSelector.camelToSnake(str)
  Array.find(QueryStructure.allTransactionFields, f =>
    FieldSelector.transactionFieldToSnakeCaseString(f) == snake
  )
}

let serializeInstructionField = (field: instructionField): string =>
  FieldSelector.instructionFieldToCamelCaseString(field)

let deserializeInstructionField = (str: string): option<instructionField> => {
  let snake = FieldSelector.camelToSnake(str)
  Array.find(QueryStructure.allInstructionFields, f =>
    FieldSelector.instructionFieldToSnakeCaseString(f) == snake
  )
}

let serializeUrlState = (state: urlState): string => {
  let json = JSON.Encode.object(
    Dict.fromArray([
      (
        "query",
        JSON.Encode.object(
          Dict.fromArray([
            ("fromSlot", JSON.Encode.float(Int.toFloat(state.query.fromSlot))),
            (
              "toSlot",
              switch state.query.toSlot {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "maxNumBlocks",
              switch state.query.maxNumBlocks {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "maxNumTransactions",
              switch state.query.maxNumTransactions {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "maxNumInstructions",
              switch state.query.maxNumInstructions {
              | Some(value) => JSON.Encode.float(Int.toFloat(value))
              | None => JSON.Encode.null
              },
            ),
            (
              "includeAllBlocks",
              switch state.query.includeAllBlocks {
              | Some(value) => JSON.Encode.bool(value)
              | None => JSON.Encode.null
              },
            ),
            (
              "instructions",
              switch state.query.instructions {
              | Some(instructions) =>
                JSON.Encode.array(
                  instructions->Array.map(instr => {
                    let programIdJson = switch instr.program_id {
                    | Some(ids) => JSON.Encode.array(ids->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let d1Json = switch instr.d1 {
                    | Some(vals) => JSON.Encode.array(vals->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let d8Json = switch instr.d8 {
                    | Some(vals) => JSON.Encode.array(vals->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let a0Json = switch instr.a0 {
                    | Some(vals) => JSON.Encode.array(vals->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let isInnerJson = switch instr.is_inner {
                    | Some(value) => JSON.Encode.bool(value)
                    | None => JSON.Encode.null
                    }
                    JSON.Encode.object(
                      Dict.fromArray([
                        ("program_id", programIdJson),
                        ("d1", d1Json),
                        ("d8", d8Json),
                        ("a0", a0Json),
                        ("is_inner", isInnerJson),
                      ]),
                    )
                  }),
                )
              | None => JSON.Encode.null
              },
            ),
            (
              "transactions",
              switch state.query.transactions {
              | Some(transactions) =>
                JSON.Encode.array(
                  transactions->Array.map(txn => {
                    let feePayerJson = switch txn.fee_payer {
                    | Some(payers) => JSON.Encode.array(payers->Array.map(JSON.Encode.string))
                    | None => JSON.Encode.null
                    }
                    let successJson = switch txn.success {
                    | Some(value) => JSON.Encode.bool(value)
                    | None => JSON.Encode.null
                    }
                    JSON.Encode.object(
                      Dict.fromArray([("fee_payer", feePayerJson), ("success", successJson)]),
                    )
                  }),
                )
              | None => JSON.Encode.null
              },
            ),
            (
              "fieldSelection",
              JSON.Encode.object(
                Dict.fromArray([
                  (
                    "block",
                    JSON.Encode.array(
                      state.query.fieldSelection.block
                      ->Array.map(serializeBlockField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                  (
                    "transaction",
                    JSON.Encode.array(
                      state.query.fieldSelection.transaction
                      ->Array.map(serializeTransactionField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                  (
                    "instruction",
                    JSON.Encode.array(
                      state.query.fieldSelection.instruction
                      ->Array.map(serializeInstructionField)
                      ->Array.map(JSON.Encode.string),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
      (
        "selectedChainName",
        switch state.selectedChainName {
        | Some(value) => JSON.Encode.string(value)
        | None => JSON.Encode.null
        },
      ),
    ]),
  )
  JSON.stringify(json)
}

// Helper to decode an optional string array from JSON
let decodeOptionalStringArray = (obj: dict<JSON.t>, key: string): option<array<string>> => {
  switch Dict.get(obj, key) {
  | Some(value) =>
    switch JSON.Decode.null(value) {
    | Some(_) => None
    | None =>
      switch JSON.Decode.array(value) {
      | Some(arr) => Some(arr->Array.map(JSON.Decode.string)->Array.filterMap(x => x))
      | None => None
      }
    }
  | None => None
  }
}

// Helper to decode an optional bool from JSON
let decodeOptionalBool = (obj: dict<JSON.t>, key: string): option<bool> => {
  switch Dict.get(obj, key) {
  | Some(value) =>
    switch JSON.Decode.null(value) {
    | Some(_) => None
    | None =>
      switch JSON.Decode.bool(value) {
      | Some(b) => Some(b)
      | None => None
      }
    }
  | None => None
  }
}

// Helper to decode an optional number from JSON
let decodeOptionalInt = (obj: dict<JSON.t>, key: string): option<int> => {
  switch Dict.get(obj, key) {
  | Some(value) =>
    switch JSON.Decode.null(value) {
    | Some(_) => None
    | None =>
      switch JSON.Decode.float(value) {
      | Some(num) => Some(Float.toInt(num))
      | None => None
      }
    }
  | None => None
  }
}

let deserializeUrlState = (jsonString: string): option<urlState> => {
  switch JSON.parseOrThrow(jsonString) {
  | json => {
      let obj = JSON.Decode.object(json)
      switch obj {
      | Some(obj) => {
          let getField = (fieldName: string) => Dict.get(obj, fieldName)

          let queryJson = switch getField("query") {
          | Some(value) => value
          | None => JSON.Encode.null
          }

          let queryObj = switch JSON.Decode.object(queryJson) {
          | Some(queryObj) => queryObj
          | None => Dict.make()
          }

          let fromSlot = switch Dict.get(queryObj, "fromSlot") {
          | Some(value) =>
            switch JSON.Decode.float(value) {
            | Some(num) => Float.toInt(num)
            | None => 0
            }
          | None => 0
          }

          let toSlot = decodeOptionalInt(queryObj, "toSlot")
          let maxNumBlocks = decodeOptionalInt(queryObj, "maxNumBlocks")
          let maxNumTransactions = decodeOptionalInt(queryObj, "maxNumTransactions")
          let maxNumInstructions = decodeOptionalInt(queryObj, "maxNumInstructions")
          let includeAllBlocks = decodeOptionalBool(queryObj, "includeAllBlocks")

          let instructions = switch Dict.get(queryObj, "instructions") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.array(value) {
              | Some(array) => {
                  let decoded =
                    array
                    ->Array.map(JSON.Decode.object)
                    ->Array.filterMap(x => x)
                    ->Array.map(instr => {
                      let program_id = decodeOptionalStringArray(instr, "program_id")
                      let d1 = decodeOptionalStringArray(instr, "d1")
                      let d8 = decodeOptionalStringArray(instr, "d8")
                      let a0 = decodeOptionalStringArray(instr, "a0")
                      let is_inner = decodeOptionalBool(instr, "is_inner")
                      {program_id, d1, d8, a0, is_inner}
                    })
                  Some(decoded)
                }
              | None => None
              }
            }
          | None => None
          }

          let transactions = switch Dict.get(queryObj, "transactions") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.array(value) {
              | Some(array) => {
                  let decoded =
                    array
                    ->Array.map(JSON.Decode.object)
                    ->Array.filterMap(x => x)
                    ->Array.map(txn => {
                      let fee_payer = decodeOptionalStringArray(txn, "fee_payer")
                      let success = decodeOptionalBool(txn, "success")
                      {fee_payer, success}
                    })
                  Some(decoded)
                }
              | None => None
              }
            }
          | None => None
          }

          let fieldSelectionJson = switch Dict.get(queryObj, "fieldSelection") {
          | Some(value) => value
          | None => JSON.Encode.null
          }

          let fieldSelectionObj = switch JSON.Decode.object(fieldSelectionJson) {
          | Some(fieldSelectionObj) => fieldSelectionObj
          | None => Dict.make()
          }

          let getFieldSelectionField = (fieldName: string) => Dict.get(fieldSelectionObj, fieldName)

          let blockFields = switch getFieldSelectionField("block") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) =>
              Some(
                array
                ->Array.map(JSON.Decode.string)
                ->Array.filterMap(x => x)
                ->Array.map(deserializeBlockField)
                ->Array.filterMap(x => x),
              )
            | None => None
            }
          | None => None
          }

          let transactionFields = switch getFieldSelectionField("transaction") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) =>
              Some(
                array
                ->Array.map(JSON.Decode.string)
                ->Array.filterMap(x => x)
                ->Array.map(deserializeTransactionField)
                ->Array.filterMap(x => x),
              )
            | None => None
            }
          | None => None
          }

          let instructionFields = switch getFieldSelectionField("instruction") {
          | Some(value) =>
            switch JSON.Decode.array(value) {
            | Some(array) =>
              Some(
                array
                ->Array.map(JSON.Decode.string)
                ->Array.filterMap(x => x)
                ->Array.map(deserializeInstructionField)
                ->Array.filterMap(x => x),
              )
            | None => None
            }
          | None => None
          }

          let fieldSelection = {
            block: blockFields->Option.getOr([]),
            transaction: transactionFields->Option.getOr([]),
            instruction: instructionFields->Option.getOr([]),
          }

          let query = {
            fromSlot,
            toSlot,
            instructions,
            transactions,
            includeAllBlocks,
            fieldSelection,
            maxNumBlocks,
            maxNumTransactions,
            maxNumInstructions,
          }

          let selectedChainName = switch getField("selectedChainName") {
          | Some(value) =>
            switch JSON.Decode.null(value) {
            | Some(_) => None
            | None =>
              switch JSON.Decode.string(value) {
              | Some(name) => Some(name)
              | None => None
              }
            }
          | None => None
          }

          Some({
            query,
            selectedChainName,
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
  compressToBase64Url(jsonString)
}

let decodeUrlStateFromUrl = (encodedString: string): option<urlState> => {
  switch decompressFromBase64Url(encodedString) {
  | Some(jsonString) => deserializeUrlState(jsonString)
  | None =>
    if isLegacyUrlEncoded(encodedString) {
      try {
        let decodedString = decodeURIComponent(encodedString)
        deserializeUrlState(decodedString)
      } catch {
      | _ => None
      }
    } else {
      None
    }
  }
}

let getUrlStateFromUrl = (): option<urlState> => {
  let locationObj = location(window)
  let searchStr = search(locationObj)

  if String.startsWith(searchStr, "?q=") {
    let encodedQuery = String.substring(searchStr, ~start=3, ~end=String.length(searchStr))
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
