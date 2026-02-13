%%raw("import './tailwind.css'")

module AppWrapper = {
  @react.component
  let make = () => {
    // Token state management at the top level
    let (bearerToken, setBearerToken) = React.useState(() => AuthToken.getToken())

    let handleTokenUpdate = (token: string) => {
      if AuthToken.saveToken(token) {
        setBearerToken(_ => Some(token))
      }
    }

    let handleTokenClear = () => {
      if AuthToken.clearToken() {
        setBearerToken(_ => None)
      }
    }

    <div className="min-h-screen bg-slate-50 flex flex-col">
      <header className="bg-white/80 backdrop-blur border-b border-slate-200 sticky top-0 z-10">
        <div className="px-6 lg:px-4">
          <div className="flex items-center justify-between h-14">
            <div className="flex items-center">
              <h1 className="text-lg font-semibold tracking-tight text-slate-900">
                {"HyperSync Query Builder"->React.string}
              </h1>
            </div>
            <div className="flex items-center space-x-3">
              <TokenSettings
                token={bearerToken}
                onTokenUpdate={handleTokenUpdate}
                onTokenClear={handleTokenClear}
              />
              <a
                href="https://docs.envio.dev/docs/HyperSync/overview"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-3 py-1.5 bg-white hover:bg-slate-50 text-slate-700 hover:text-slate-900 text-xs font-medium rounded-lg transition-colors border border-slate-200"
              >
                <svg
                  className="w-3 h-3 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                {"Docs"->React.string}
              </a>
              <a
                href="https://envio.dev"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center px-3 py-1.5 bg-white hover:bg-slate-50 text-slate-700 hover:text-slate-900 text-xs font-medium rounded-lg transition-colors border border-slate-200"
              >
                <svg
                  className="w-3 h-3 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                  />
                </svg>
                {"Visit Envio"->React.string}
              </a>
            </div>
          </div>
        </div>
      </header>
      <App bearerToken onTokenSubmit={handleTokenUpdate} />
      <footer className="bg-white border-t border-slate-200 mt-auto">
        <div className="px-6 lg:px-8 py-3">
          <div className="flex items-center justify-center text-xs text-slate-500">
            <span>
              {"Proudly made by Envio - the team behind the best blockchain indexing tool"->React.string}
            </span>
          </div>
        </div>
      </footer>
    </div>
  }
}

ReactDOM.querySelector("#root")
->Belt.Option.getExn
->ReactDOM.Client.createRoot
->ReactDOM.Client.Root.render(
  <React.StrictMode>
    <AppWrapper />
  </React.StrictMode>,
)
