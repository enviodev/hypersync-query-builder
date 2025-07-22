let blockFieldToString: QueryStructure.blockField => string
let transactionFieldToString: QueryStructure.transactionField => string  
let logFieldToString: QueryStructure.logField => string

@react.component
let make: (
  ~fieldSelection: QueryStructure.fieldSelection,
  ~onFieldSelectionChange: QueryStructure.fieldSelection => unit
) => React.element 
