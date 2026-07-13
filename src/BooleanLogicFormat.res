// Shared helpers for folding a selection's `exclude` filter into the English
// descriptions and ASCII boolean-logic trees produced by the *BooleanLogicGenerator
// modules.

let needsParens = (desc: string) => String.includes(desc, " AND ") || String.includes(desc, " OR ")

// Compose "include AND NOT (exclude)". `include_` is "" when the filter has no
// include conditions (i.e. it matches everything except the exclusions).
let composeDescriptionWithNot = (~include_: string, ~exclude: string) =>
  if include_ === "" {
    `NOT (${exclude})`
  } else {
    let includePart = needsParens(include_) ? `(${include_})` : include_
    `${includePart} AND NOT (${exclude})`
  }

// Prefix the first line of a rendered sub-tree and indent its remaining lines.
let indentSubTree = (tree: string, ~firstPrefix: string, ~restPrefix: string) =>
  String.split(tree, "\n")->Array.mapWithIndex((line, i) =>
    i === 0 ? `${firstPrefix}${line}` : `${restPrefix}${line}`
  )

// Compose a hierarchy with a NOT branch for the exclude filter. `includeTree`
// is None when the filter has no include conditions.
let composeHierarchyWithNot = (~includeTree: option<string>, ~excludeTree: string) => {
  let lines = switch includeTree {
  | Some(include_) =>
    ["AND"]
    ->Array.concat(indentSubTree(include_, ~firstPrefix="├── ", ~restPrefix="│   "))
    ->Array.concat(["└── NOT"])
    ->Array.concat(
      indentSubTree(excludeTree, ~firstPrefix="    └── ", ~restPrefix="        "),
    )
  | None =>
    ["NOT"]->Array.concat(indentSubTree(excludeTree, ~firstPrefix="└── ", ~restPrefix="    "))
  }
  Array.join(lines, "\n")
}
