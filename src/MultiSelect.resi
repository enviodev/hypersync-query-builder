type selectOption<'a> = {
  value: 'a,
  label: string,
  description: string,
}

@react.component
let make: (
  ~options: array<selectOption<'a>>,
  ~selectedValues: array<'a>,
  ~onSelectionChange: array<'a> => unit,
  ~placeholder: string,
  ~title: string,
) => React.element
