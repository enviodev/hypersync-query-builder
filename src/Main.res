%%raw("import './tailwind.css'")

ReactDOM.querySelector("#root")
->Belt.Option.getExn
->ReactDOM.Client.createRoot
->ReactDOM.Client.Root.render(
  <React.StrictMode>
    <div className="min-h-screen bg-slate-50">
      <header className="bg-white border-b border-slate-200">
        <div className="px-6 lg:px-8">
          <div className="flex items-center justify-between h-14">
            <div className="flex items-center">
              <h1 className="text-lg font-medium text-slate-900">
                {"HyperSync Query Builder"->React.string}
              </h1>
            </div>
            <div className="text-xs font-medium text-slate-500 uppercase tracking-wider">
              {"Build blockchain queries with ease"->React.string}
            </div>
          </div>
        </div>
      </header>
      <App />
      <footer className="bg-slate-50 border-t border-slate-200">
        <div className="px-6 lg:px-8 py-3">
          <div className="flex items-center justify-center text-xs text-slate-500">
            <span>
              {"Proudly made by Envio - the team behind the best blockchain indexing tool"->React.string}
            </span>
          </div>
        </div>
      </footer>
    </div>
  </React.StrictMode>,
)
