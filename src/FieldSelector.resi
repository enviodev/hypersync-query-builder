let snakeToCamel: string => string
let camelToSnake: string => string
let snakeToTitle: string => string
let blockFieldToSnakeCaseString: QueryStructure.blockField => string
let transactionFieldToSnakeCaseString: QueryStructure.transactionField => string
let logFieldToSnakeCaseString: QueryStructure.logField => string
let traceFieldToSnakeCaseString: QueryStructure.traceField => string
let blockFieldToCamelCaseString: QueryStructure.blockField => string
let transactionFieldToCamelCaseString: QueryStructure.transactionField => string
let logFieldToCamelCaseString: QueryStructure.logField => string
let traceFieldToCamelCaseString: QueryStructure.traceField => string
let blockFieldToDisplayString: QueryStructure.blockField => string
let transactionFieldToDisplayString: QueryStructure.transactionField => string
let logFieldToDisplayString: QueryStructure.logField => string
let traceFieldToDisplayString: QueryStructure.traceField => string

@react.component
let make: (
  ~fieldSelection: QueryStructure.fieldSelection,
  ~onFieldSelectionChange: QueryStructure.fieldSelection => unit,
  ~tracesSupported: bool,
) => React.element
