// TokenPrompt - Modal/banner that prompts users to enter their bearer token

@react.component
let make = (~onTokenSubmit: string => unit) => {
  let (tokenInput, setTokenInput) = React.useState(() => "")
  let (showError, setShowError) = React.useState(() => false)

  let handleSubmit = () => {
    let trimmedToken = String.trim(tokenInput)
    if String.length(trimmedToken) > 0 {
      onTokenSubmit(trimmedToken)
      setShowError(_ => false)
    } else {
      setShowError(_ => true)
    }
  }

  let handleKeyDown = (e: ReactEvent.Keyboard.t) => {
    if ReactEvent.Keyboard.key(e) === "Enter" {
      handleSubmit()
    }
  }

  <div
    className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
  >
    <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-8 border border-slate-200">
      <div className="mb-6 text-center">
        <div
          className="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4"
        >
          <svg
            className="w-8 h-8 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
            />
          </svg>
        </div>
        <h2 className="text-2xl font-bold text-slate-900 mb-2">
          {"Authentication Required"->React.string}
        </h2>
        <p className="text-sm text-slate-600">
          {"HyperSync requires a bearer token to execute queries."->React.string}
        </p>
      </div>

      <div className="mb-6">
        <label htmlFor="token-input" className="block text-sm font-medium text-slate-700 mb-2">
          {"Bearer Token"->React.string}
        </label>
        <input
          id="token-input"
          type_="password"
          value={tokenInput}
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            setTokenInput(_ => target["value"])
            setShowError(_ => false)
          }}
          onKeyDown={handleKeyDown}
          placeholder="Enter your HyperSync API token"
          className={`w-full px-4 py-3 rounded-lg border ${showError
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-slate-300 focus:border-slate-500 focus:ring-slate-500"} focus:outline-none focus:ring-2 transition-colors text-sm`}
          autoFocus={true}
        />
        {showError
          ? <p className="mt-2 text-sm text-red-600">
              {"Please enter a valid token"->React.string}
            </p>
          : React.null}
      </div>

      <button
        onClick={_ => handleSubmit()}
        className="w-full bg-slate-900 text-white py-3 px-4 rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 focus:ring-offset-2 transition-colors font-medium text-sm mb-4"
      >
        {"Continue"->React.string}
      </button>

      <div className="bg-slate-50 rounded-lg p-4 border border-slate-200">
        <p className="text-xs text-slate-600 mb-2"> {"Don't have a token yet?"->React.string} </p>
        <a
          href="https://envio.dev/app/api-tokens"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center text-sm font-medium text-slate-900 hover:text-slate-700 transition-colors"
        >
          {"Get your token from Envio"->React.string}
          <svg className="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
            />
          </svg>
        </a>
      </div>
    </div>
  </div>
}
