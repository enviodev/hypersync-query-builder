// AuthToken interface

// Get token from localStorage
let getToken: unit => option<string>

// Save token to localStorage
let saveToken: string => bool

// Clear token from localStorage
let clearToken: unit => bool

// Validate that token is not empty
let isValidToken: option<string> => bool
