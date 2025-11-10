// TokenSettings - Small settings panel for managing the bearer token

@react.component
let make = (~token: option<string>, ~onTokenUpdate: string => unit, ~onTokenClear: unit => unit) => {
  let (isOpen, setIsOpen) = React.useState(() => false)
  let (showToken, setShowToken) = React.useState(() => false)
  let (newToken, setNewToken) = React.useState(() => "")
  let (isEditing, setIsEditing) = React.useState(() => false)

  let handleUpdate = () => {
    let trimmedToken = String.trim(newToken)
    if String.length(trimmedToken) > 0 {
      onTokenUpdate(trimmedToken)
      setIsEditing(_ => false)
      setNewToken(_ => "")
      setIsOpen(_ => false)
    }
  }

  let handleClear = () => {
    onTokenClear()
    setIsOpen(_ => false)
    setShowToken(_ => false)
  }

  let maskToken = (t: string) => {
    let len = String.length(t)
    if len <= 8 {
      String.repeat("•", len)
    } else {
      let start = Js.String2.substring(t, ~from=0, ~to_=4)
      let end = Js.String2.substringToEnd(t, ~from=len - 4)
      start ++ String.repeat("•", len - 8) ++ end
    }
  }

  <div className="relative">
    <button
      onClick={_ => setIsOpen(prev => !prev)}
      className="inline-flex items-center px-3 py-1.5 bg-white hover:bg-slate-50 text-slate-700 hover:text-slate-900 text-xs font-medium rounded-lg transition-colors border border-slate-200"
      title="Token Settings">
      <svg className="w-3 h-3 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
        />
        <path
          strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
        />
      </svg>
      {"Token"->React.string}
    </button>

    {isOpen
      ? <div
          className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-slate-200 p-4 z-50">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-semibold text-slate-900">
              {"API Token Settings"->React.string}
            </h3>
            <button
              onClick={_ => setIsOpen(_ => false)}
              className="text-slate-400 hover:text-slate-600 transition-colors">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>

          {switch token {
          | Some(t) if !isEditing =>
            <div>
              <div className="mb-4">
                <label className="block text-xs font-medium text-slate-700 mb-2">
                  {"Current Token"->React.string}
                </label>
                <div className="flex items-center gap-2">
                  <div
                    className="flex-1 px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-mono text-slate-800 overflow-hidden">
                    {(showToken ? t : maskToken(t))->React.string}
                  </div>
                  <button
                    onClick={_ => setShowToken(prev => !prev)}
                    className="p-2 text-slate-500 hover:text-slate-700 transition-colors"
                    title={showToken ? "Hide token" : "Show token"}>
                    {showToken
                      ? <svg
                          className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"
                          />
                        </svg>
                      : <svg
                          className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                          />
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                          />
                        </svg>}
                  </button>
                </div>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={_ => setIsEditing(_ => true)}
                  className="flex-1 px-3 py-2 bg-slate-100 text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                  {"Update Token"->React.string}
                </button>
                <button
                  onClick={_ => handleClear()}
                  className="flex-1 px-3 py-2 bg-red-50 text-red-700 text-xs font-medium rounded-lg hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-red-500 transition-colors">
                  {"Clear Token"->React.string}
                </button>
              </div>

              <div className="mt-3 pt-3 border-t border-slate-200">
                <a
                  href="https://envio.dev/app/api-tokens"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center text-xs text-slate-600 hover:text-slate-900 transition-colors">
                  {"Manage tokens at Envio"->React.string}
                  <svg className="w-3 h-3 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

          | _ =>
            <div>
              <div className="mb-4">
                <label htmlFor="new-token-input" className="block text-xs font-medium text-slate-700 mb-2">
                  {(isEditing ? "New Token" : "Bearer Token")->React.string}
                </label>
                <input
                  id="new-token-input"
                  type_="password"
                  value={newToken}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    setNewToken(_ => target["value"])
                  }}
                  onKeyDown={e => {
                    if ReactEvent.Keyboard.key(e) === "Enter" {
                      handleUpdate()
                    }
                  }}
                  placeholder="Enter your token"
                  className="w-full px-3 py-2 rounded-lg border border-slate-300 focus:border-slate-500 focus:ring-2 focus:ring-slate-500 focus:outline-none transition-colors text-xs"
                  autoFocus={true}
                />
              </div>

              <div className="flex gap-2">
                <button
                  onClick={_ => handleUpdate()}
                  className="flex-1 px-3 py-2 bg-slate-900 text-white text-xs font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                  {(isEditing ? "Update" : "Save")->React.string}
                </button>
                {isEditing
                  ? <button
                      onClick={_ => {
                        setIsEditing(_ => false)
                        setNewToken(_ => "")
                      }}
                      className="flex-1 px-3 py-2 bg-slate-100 text-slate-700 text-xs font-medium rounded-lg hover:bg-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                      {"Cancel"->React.string}
                    </button>
                  : React.null}
              </div>
            </div>
          }}
        </div>
      : React.null}
  </div>
}

