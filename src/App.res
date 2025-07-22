@module("./logo.svg") external logo: string = "default"
%%raw(`import './App.css'`)
%%raw(`import './tailwind.css'`)

@react.component
let make = () => {
  <div className="min-h-screen bg-gray-50">
    <header className="bg-white shadow-sm border-b">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <img src={logo} className="h-8 w-8 mr-3" alt="logo" />
            <h1 className="text-xl font-semibold text-gray-900">
              {"HyperSync Query Builder"->React.string}
            </h1>
          </div>
          <div className="text-sm text-gray-500">
            {"Build blockchain queries with ease"->React.string}
          </div>
        </div>
      </div>
    </header>
    <main className="py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            {"Create Your Query"->React.string}
          </h2>
          <p className="text-gray-600">
            {"Start by adding filters for logs, transactions, and blocks. Configure your query parameters below."->React.string}
          </p>
        </div>
        <div className="space-y-8">
          <LogFilter />
          // Placeholder for future components
          <div className="bg-white rounded-lg shadow p-6 border-2 border-dashed border-gray-200">
            <h3 className="text-lg font-medium text-gray-500 mb-2">
              {"Transaction Filters"->React.string}
            </h3>
            <p className="text-gray-400">
              {"Coming soon - Add transaction filters here"->React.string}
            </p>
          </div>
          <div className="bg-white rounded-lg shadow p-6 border-2 border-dashed border-gray-200">
            <h3 className="text-lg font-medium text-gray-500 mb-2">
              {"Block Filters"->React.string}
            </h3>
            <p className="text-gray-400">
              {"Coming soon - Add block filters here"->React.string}
            </p>
          </div>
        </div>
      </div>
    </main>
    <footer className="bg-white border-t mt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex items-center justify-center space-x-4 text-sm text-gray-500">
          <a
            className="hover:text-blue-600 transition-colors"
            href="https://rescript-lang.org"
            target="_blank"
            rel="noopener noreferrer">
            {"ReScript"->React.string}
          </a>
          <span> {"•"->React.string} </span>
          <a
            className="hover:text-blue-600 transition-colors"
            href="https://reactjs.org"
            target="_blank"
            rel="noopener noreferrer">
            {"React"->React.string}
          </a>
          <span> {"•"->React.string} </span>
          <a
            className="hover:text-blue-600 transition-colors"
            href="https://vitejs.dev"
            target="_blank"
            rel="noopener noreferrer">
            {"Vite"->React.string}
          </a>
        </div>
      </div>
    </footer>
  </div>
}
