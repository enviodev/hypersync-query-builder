%%raw("import './tailwind.css'")

ReactDOM.querySelector("#root")
->Belt.Option.getExn
->ReactDOM.Client.createRoot
->ReactDOM.Client.Root.render(
  <React.StrictMode>
    
      <div className="min-h-screen bg-gray-50">
    <header className="bg-white shadow-sm border-b">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <h1 className="text-xl font-semibold text-gray-900">
              {"HyperSync Query Builder"->React.string}
            </h1>
          </div>
          <div className="text-sm text-gray-500">
            {"Build blockchain queries with ease"->React.string}
          </div>
        </div>
      </div></header>
    <App />
    <footer className="bg-white border-t mt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex items-center justify-center space-x-4 text-sm text-gray-500">
          <span>
            {"Proudly made by Envio - the team behind the best blockchain indexing tool"->React.string}
          </span>
        </div>
      </div>
    </footer>
  </div>
  
  </React.StrictMode>,
)
