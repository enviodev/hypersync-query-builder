// AuthToken module - manages bearer token state and localStorage persistence

let storageKey = "hypersync_bearer_token"

// Get token from localStorage
let getToken = () => {
  try {
    let getItem: string => Js.Nullable.t<string> = %raw(`(key) => localStorage.getItem(key)`)
    let value = getItem(storageKey)
    Js.Nullable.toOption(value)
  } catch {
  | _ => None
  }
}

// Save token to localStorage
let saveToken = (token: string) => {
  try {
    let setItem: (string, string) => unit = %raw(`(key, value) => localStorage.setItem(key, value)`)
    setItem(storageKey, token)
    true
  } catch {
  | _ => false
  }
}

// Clear token from localStorage
let clearToken = () => {
  try {
    let removeItem: string => unit = %raw(`(key) => localStorage.removeItem(key)`)
    removeItem(storageKey)
    true
  } catch {
  | _ => false
  }
}

// Validate that token is not empty
let isValidToken = (token: option<string>) => {
  switch token {
  | Some(t) => String.length(String.trim(t)) > 0
  | None => false
  }
}

