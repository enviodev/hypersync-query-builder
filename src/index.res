%%raw("import './style.css'")
switch ReactDOM.querySelector("#root") {
| Some(el) =>
  let root = ReactDOM.Client.createRoot(el)
  ReactDOM.Client.Root.render(root, <App title="Hello from ReScript!" />)
| None => Js.Console.error("No #root found")
}
