type blockFilterState = QueryStructure.blockSelection

// True when the filter's own fields are empty, ignoring any exclude filter.
let isEmptyBlockFields = (filterState: blockFilterState) => {
  let {hash, miner} = filterState
  Array.length(hash->Option.getOr([])) === 0 && Array.length(miner->Option.getOr([])) === 0
}

// Returns the exclude filter only when it actually has conditions.
let excludeContent = (filterState: blockFilterState): option<blockFilterState> =>
  switch filterState.exclude {
  | Some(ex) if !isEmptyBlockFields(ex) => Some(ex)
  | _ => None
  }

// Description of the filter's own fields, "" when empty.
let generateFieldsDescription = (filterState: blockFilterState) => {
  let {hash, miner} = filterState
  let hashArray = hash->Option.getOr([])
  let minerArray = miner->Option.getOr([])

  let parts = []

  // Hash condition
  if Array.length(hashArray) > 0 {
    let hashCondition = if Array.length(hashArray) === 1 {
      `the block hash is ${Array.getUnsafe(hashArray, 0)}`
    } else {
      let hashList = Array.join(hashArray, " OR ")
      `the block hash is ${hashList}`
    }
    parts->Array.push(hashCondition)->ignore
  }

  // Miner condition
  if Array.length(minerArray) > 0 {
    let minerCondition = if Array.length(minerArray) === 1 {
      `the miner address is ${Array.getUnsafe(minerArray, 0)}`
    } else {
      let minerList = Array.join(minerArray, " OR ")
      `the miner address is ${minerList}`
    }
    parts->Array.push(minerCondition)->ignore
  }

  Array.join(parts, " AND ")
}

let generateEnglishDescription = (filterState: blockFilterState) => {
  let include_ = generateFieldsDescription(filterState)
  switch excludeContent(filterState) {
  | Some(ex) =>
    let exclude = generateFieldsDescription(ex)
    `Match blocks where: ${BooleanLogicFormat.composeDescriptionWithNot(~include_, ~exclude)}`
  | None =>
    if include_ === "" {
      "No filters applied - will match all blocks"
    } else {
      `Match blocks where: ${include_}`
    }
  }
}

// Hierarchy of the filter's own fields, ignoring any exclude filter.
let generateFieldsHierarchy = (filterState: blockFilterState) => {
  let {hash, miner} = filterState
  let hashArray = hash->Option.getOr([])
  let minerArray = miner->Option.getOr([])

  let hasAnyFilter = Array.length(hashArray) > 0 || Array.length(minerArray) > 0

  if !hasAnyFilter {
    "No filters"
  } else {
    let lines = []

    let conditions = []
    if Array.length(hashArray) > 0 {
      conditions->Array.push("hash")->ignore
    }
    if Array.length(minerArray) > 0 {
      conditions->Array.push("miner")->ignore
    }

    let hasMultipleConditions = Array.length(conditions) > 1

    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }

    let conditionIndex = ref(0)

    // Hash
    if Array.length(hashArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(hashArray) === 1 {
        lines->Array.push(`${prefix}hash = ${Array.getUnsafe(hashArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (hash)`)->ignore
        Array.forEachWithIndex(hashArray, (h, i) => {
          let isLastHash = i === Array.length(hashArray) - 1
          let hashPrefix = if hasMultipleConditions {
            if isLast {
              isLastHash ? "    └── " : "    ├── "
            } else if isLastHash {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastHash {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${hashPrefix}${h}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Miner
    if Array.length(minerArray) > 0 {
      // let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? "└── " : ""

      if Array.length(minerArray) === 1 {
        lines->Array.push(`${prefix}miner = ${Array.getUnsafe(minerArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (miner)`)->ignore
        Array.forEachWithIndex(minerArray, (m, i) => {
          let isLastMiner = i === Array.length(minerArray) - 1
          let minerPrefix = if hasMultipleConditions {
            isLastMiner ? "    └── " : "    ├── "
          } else if isLastMiner {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${minerPrefix}${m}`)->ignore
        })
      }
    }

    Array.join(lines, "\n")
  }
}

let generateBooleanHierarchy = (filterState: blockFilterState) => {
  switch excludeContent(filterState) {
  | None => generateFieldsHierarchy(filterState)
  | Some(ex) =>
    let includeTree = isEmptyBlockFields(filterState)
      ? None
      : Some(generateFieldsHierarchy(filterState))
    BooleanLogicFormat.composeHierarchyWithNot(
      ~includeTree,
      ~excludeTree=generateFieldsHierarchy(ex),
    )
  }
}
