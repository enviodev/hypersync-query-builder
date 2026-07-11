open QueryStructure

type traceFilterState = QueryStructure.traceSelection

// True when the filter's own fields are empty, ignoring any exclude filter.
let isEmptyTraceFields = (filterState: traceFilterState) => {
  let {from_, to_, address, callType, rewardType, type_, sighash} = filterState
  Array.length(from_->Option.getOr([])) === 0 &&
  Array.length(to_->Option.getOr([])) === 0 &&
  Array.length(address->Option.getOr([])) === 0 &&
  Array.length(callType->Option.getOr([])) === 0 &&
  Array.length(rewardType->Option.getOr([])) === 0 &&
  Array.length(type_->Option.getOr([])) === 0 &&
  Array.length(sighash->Option.getOr([])) === 0
}

// Returns the exclude filter only when it actually has conditions.
let excludeContent = (filterState: traceFilterState): option<traceFilterState> =>
  switch filterState.exclude {
  | Some(ex) if !isEmptyTraceFields(ex) => Some(ex)
  | _ => None
  }

// Description of the filter's own fields, "" when empty.
let generateFieldsDescription = (filterState: traceFilterState) => {
  let {from_, to_, address, callType, rewardType, type_, sighash} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let addressArray = address->Option.getOr([])
  let callTypeArray = callType->Option.getOr([])
  let rewardTypeArray = rewardType->Option.getOr([])
  let typeArray = type_->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])

  let parts = []

  // From condition
  if Array.length(fromArray) > 0 {
    let fromCondition = if Array.length(fromArray) === 1 {
      `the sender address is ${Array.getUnsafe(fromArray, 0)}`
    } else {
      let fromList = Array.join(fromArray, " OR ")
      `the sender address is ${fromList}`
    }
    parts->Array.push(fromCondition)->ignore
  }

  // To condition
  if Array.length(toArray) > 0 {
    let toCondition = if Array.length(toArray) === 1 {
      `the recipient address is ${Array.getUnsafe(toArray, 0)}`
    } else {
      let toList = Array.join(toArray, " OR ")
      `the recipient address is ${toList}`
    }
    parts->Array.push(toCondition)->ignore
  }

  // Address condition
  if Array.length(addressArray) > 0 {
    let addressCondition = if Array.length(addressArray) === 1 {
      `the address is ${Array.getUnsafe(addressArray, 0)}`
    } else {
      let addressList = Array.join(addressArray, " OR ")
      `the address is ${addressList}`
    }
    parts->Array.push(addressCondition)->ignore
  }

  // Call type condition
  if Array.length(callTypeArray) > 0 {
    let callTypeCondition = if Array.length(callTypeArray) === 1 {
      `the call type is ${Array.getUnsafe(callTypeArray, 0)}`
    } else {
      let callTypeList = Array.join(callTypeArray, " OR ")
      `the call type is ${callTypeList}`
    }
    parts->Array.push(callTypeCondition)->ignore
  }

  // Reward type condition
  if Array.length(rewardTypeArray) > 0 {
    let rewardTypeCondition = if Array.length(rewardTypeArray) === 1 {
      `the reward type is ${Array.getUnsafe(rewardTypeArray, 0)}`
    } else {
      let rewardTypeList = Array.join(rewardTypeArray, " OR ")
      `the reward type is ${rewardTypeList}`
    }
    parts->Array.push(rewardTypeCondition)->ignore
  }

  // Type condition
  if Array.length(typeArray) > 0 {
    let typeCondition = if Array.length(typeArray) === 1 {
      `the type is ${Array.getUnsafe(typeArray, 0)}`
    } else {
      let typeList = Array.join(typeArray, " OR ")
      `the type is ${typeList}`
    }
    parts->Array.push(typeCondition)->ignore
  }

  // Sighash condition
  if Array.length(sighashArray) > 0 {
    let sighashCondition = if Array.length(sighashArray) === 1 {
      `the function signature is ${Array.getUnsafe(sighashArray, 0)}`
    } else {
      let sighashList = Array.join(sighashArray, " OR ")
      `the function signature is ${sighashList}`
    }
    parts->Array.push(sighashCondition)->ignore
  }

  Array.join(parts, " AND ")
}

let generateEnglishDescription = (filterState: traceFilterState) => {
  let include_ = generateFieldsDescription(filterState)
  switch excludeContent(filterState) {
  | Some(ex) =>
    let exclude = generateFieldsDescription(ex)
    `Match traces where: ${BooleanLogicFormat.composeDescriptionWithNot(~include_, ~exclude)}`
  | None =>
    if include_ === "" {
      "No filters applied - will match all traces"
    } else {
      `Match traces where: ${include_}`
    }
  }
}

// Hierarchy of the filter's own fields, ignoring any exclude filter.
let generateFieldsHierarchy = (filterState: traceFilterState) => {
  let {from_, to_, address, callType, rewardType, type_, sighash} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let addressArray = address->Option.getOr([])
  let callTypeArray = callType->Option.getOr([])
  let rewardTypeArray = rewardType->Option.getOr([])
  let typeArray = type_->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])

  let hasAnyFilter =
    Array.length(fromArray) > 0 ||
    Array.length(toArray) > 0 ||
    Array.length(addressArray) > 0 ||
    Array.length(callTypeArray) > 0 ||
    Array.length(rewardTypeArray) > 0 ||
    Array.length(typeArray) > 0 ||
    Array.length(sighashArray) > 0

  if !hasAnyFilter {
    "No filters"
  } else {
    let lines = []

    let conditions = []
    if Array.length(fromArray) > 0 {
      conditions->Array.push("from")->ignore
    }
    if Array.length(toArray) > 0 {
      conditions->Array.push("to")->ignore
    }
    if Array.length(addressArray) > 0 {
      conditions->Array.push("address")->ignore
    }
    if Array.length(callTypeArray) > 0 {
      conditions->Array.push("callType")->ignore
    }
    if Array.length(rewardTypeArray) > 0 {
      conditions->Array.push("rewardType")->ignore
    }
    if Array.length(typeArray) > 0 {
      conditions->Array.push("type")->ignore
    }
    if Array.length(sighashArray) > 0 {
      conditions->Array.push("sighash")->ignore
    }

    let hasMultipleConditions = Array.length(conditions) > 1

    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }

    let conditionIndex = ref(0)

    // From addresses
    if Array.length(fromArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(fromArray) === 1 {
        lines->Array.push(`${prefix}from = ${Array.getUnsafe(fromArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (from)`)->ignore
        Array.forEachWithIndex(fromArray, (addr, i) => {
          let isLastAddr = i === Array.length(fromArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else if isLastAddr {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastAddr {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // To addresses
    if Array.length(toArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(toArray) === 1 {
        lines->Array.push(`${prefix}to = ${Array.getUnsafe(toArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (to)`)->ignore
        Array.forEachWithIndex(toArray, (addr, i) => {
          let isLastAddr = i === Array.length(toArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else if isLastAddr {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastAddr {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Addresses
    if Array.length(addressArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(addressArray) === 1 {
        lines->Array.push(`${prefix}address = ${Array.getUnsafe(addressArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (address)`)->ignore
        Array.forEachWithIndex(addressArray, (addr, i) => {
          let isLastAddr = i === Array.length(addressArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else if isLastAddr {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastAddr {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Call types
    if Array.length(callTypeArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(callTypeArray) === 1 {
        lines->Array.push(`${prefix}callType = ${Array.getUnsafe(callTypeArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (callType)`)->ignore
        Array.forEachWithIndex(callTypeArray, (callType, i) => {
          let isLastCallType = i === Array.length(callTypeArray) - 1
          let callTypePrefix = if hasMultipleConditions {
            if isLast {
              isLastCallType ? "    └── " : "    ├── "
            } else if isLastCallType {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastCallType {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${callTypePrefix}${callType}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Reward types
    if Array.length(rewardTypeArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(rewardTypeArray) === 1 {
        lines->Array.push(`${prefix}rewardType = ${Array.getUnsafe(rewardTypeArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (rewardType)`)->ignore
        Array.forEachWithIndex(rewardTypeArray, (rewardType, i) => {
          let isLastRewardType = i === Array.length(rewardTypeArray) - 1
          let rewardTypePrefix = if hasMultipleConditions {
            if isLast {
              isLastRewardType ? "    └── " : "    ├── "
            } else if isLastRewardType {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastRewardType {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${rewardTypePrefix}${rewardType}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Types
    if Array.length(typeArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(typeArray) === 1 {
        lines->Array.push(`${prefix}type = ${Array.getUnsafe(typeArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (type)`)->ignore
        Array.forEachWithIndex(typeArray, (k, i) => {
          let isLastType = i === Array.length(typeArray) - 1
          let typePrefix = if hasMultipleConditions {
            if isLast {
              isLastType ? "    └── " : "    ├── "
            } else if isLastType {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastType {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${typePrefix}${k}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Sighash
    if Array.length(sighashArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(sighashArray) === 1 {
        lines->Array.push(`${prefix}sighash = ${Array.getUnsafe(sighashArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (sighash)`)->ignore
        Array.forEachWithIndex(sighashArray, (sig, i) => {
          let isLastSig = i === Array.length(sighashArray) - 1
          let sigPrefix = if hasMultipleConditions {
            if isLast {
              isLastSig ? "    └── " : "    ├── "
            } else if isLastSig {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastSig {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${sigPrefix}${sig}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    Array.join(lines, "\n")
  }
}

let generateBooleanHierarchy = (filterState: traceFilterState) => {
  switch excludeContent(filterState) {
  | None => generateFieldsHierarchy(filterState)
  | Some(ex) =>
    let includeTree = isEmptyTraceFields(filterState)
      ? None
      : Some(generateFieldsHierarchy(filterState))
    BooleanLogicFormat.composeHierarchyWithNot(
      ~includeTree,
      ~excludeTree=generateFieldsHierarchy(ex),
    )
  }
}
