@react.component
let make: (
  ~fieldSelection: QueryStructure.fieldSelection,
  ~onFieldSelectionChange: QueryStructure.fieldSelection => unit
) => React.element 
