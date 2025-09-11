type selectOption<'a> = {
  value: 'a,
  label: string,
}

@react.component
let make: (
  ~options: array<selectOption<'a>>,
  ~selectedValues: array<'a>,
  ~onSelectionChange: array<'a> => unit,
  ~placeholder: string,
  ~title: string,
  ~onOpen: (unit => unit)=?,
  ~onClose: (unit => unit)=?,
) => React.element
