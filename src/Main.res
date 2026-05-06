%%raw("import './tailwind.css'")

type ecosystem = Evm | Solana

@val external windowLocation: 'a = "window"
@get external locationOf: 'a => 'b = "location"
@get external hashOf: 'a => string = "hash"
@send external setHash: ('a, string) => unit = "replace"

let getInitialEcosystem = (): ecosystem => {
  let getHash: unit => string = %raw(`() => (typeof window !== 'undefined' ? window.location.hash : '')`)
  let h = getHash()
  if String.includes(h, "solana") {
    Solana
  } else {
    Evm
  }
}

let setHashFor = (e: ecosystem) => {
  let setH: string => unit = %raw(`(s) => { if (typeof window !== 'undefined') window.location.hash = s }`)
  switch e {
  | Solana => setH("solana")
  | Evm => setH("")
  }
}

module AppWrapper = {
  @react.component
  let make = () => {
    let (bearerToken, setBearerToken) = React.useState(() => AuthToken.getToken())
    let (ecosystem, setEcosystem) = React.useState(getInitialEcosystem)

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

    let switchEcosystem = (e: ecosystem) => {
      setEcosystem(_ => e)
      setHashFor(e)
    }

    let title = switch ecosystem {
    | Evm => "HyperSync Query Builder"
    | Solana => "HyperSync Query Builder · Solana"
    }

    <div className="min-h-screen bg-slate-50 flex flex-col">
      <header className="bg-white/80 backdrop-blur border-b border-slate-200 sticky top-0 z-10">
        <div className="px-6 lg:px-4">
          <div className="flex items-center justify-between h-14">
            <div className="flex items-center space-x-4">
              <h1 className="text-lg font-semibold tracking-tight text-slate-900">
                {title->React.string}
              </h1>
              <div
                className="inline-flex items-center rounded-lg border border-slate-200 bg-slate-50 p-0.5"
              >
                <button
                  onClick={_ => switchEcosystem(Evm)}
                  className={`px-3 py-1 text-xs font-medium rounded-md transition-colors ${ecosystem ===
                      Evm
                      ? "bg-white text-slate-900 shadow-sm"
                      : "text-slate-600 hover:text-slate-900"}`}
                >
                  {"EVM"->React.string}
                </button>
                <button
                  onClick={_ => switchEcosystem(Solana)}
                  className={`px-3 py-1 text-xs font-medium rounded-md transition-colors ${ecosystem ===
                      Solana
                      ? "bg-white text-slate-900 shadow-sm"
                      : "text-slate-600 hover:text-slate-900"}`}
                >
                  {"Solana"->React.string}
                  <span
                    className="ml-1.5 inline-flex items-center px-1.5 py-0 rounded text-[10px] font-semibold bg-amber-100 text-amber-800"
                  >
                    {"BETA"->React.string}
                  </span>
                </button>
              </div>
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
      {switch ecosystem {
      | Evm => <App bearerToken onTokenSubmit={handleTokenUpdate} />
      | Solana => <SolanaApp bearerToken onTokenSubmit={handleTokenUpdate} />
      }}
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
