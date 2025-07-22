open QueryStructure

@react.component
let make = (~fieldSelection: fieldSelection, ~onFieldSelectionChange: fieldSelection => unit) => {
  <div className="bg-white rounded-lg shadow p-6 mb-8">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-gray-900 mb-2">
        {"Field Selection"->React.string}
      </h3>
      <p className="text-sm text-gray-500">
        {"Choose which fields to include in your query results"->React.string}
      </p>
    </div>

    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      // Block Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <h4 className="font-medium text-gray-900 mb-4">{"Block Fields"->React.string}</h4>
        <div className="text-sm text-gray-500">
          {`${Int.toString(Array.length(fieldSelection.block))} fields selected`->React.string}
        </div>
        <div className="mt-2 text-xs text-gray-400">
          {"Field selection UI coming soon..."->React.string}
        </div>
      </div>

      // Transaction Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <h4 className="font-medium text-gray-900 mb-4">{"Transaction Fields"->React.string}</h4>
        <div className="text-sm text-gray-500">
          {`${Int.toString(Array.length(fieldSelection.transaction))} fields selected`->React.string}
        </div>
        <div className="mt-2 text-xs text-gray-400">
          {"Field selection UI coming soon..."->React.string}
        </div>
      </div>

      // Log Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <h4 className="font-medium text-gray-900 mb-4">{"Log Fields"->React.string}</h4>
        <div className="text-sm text-gray-500">
          {`${Int.toString(Array.length(fieldSelection.log))} fields selected`->React.string}
        </div>
        <div className="mt-2 text-xs text-gray-400">
          {"Field selection UI coming soon..."->React.string}
        </div>
      </div>
    </div>
  </div>
} 
