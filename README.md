# HyperSync Query Builder Component

A React component library for building blockchain queries with HyperSync. This interactive query builder provides an intuitive UI for constructing complex blockchain queries with support for logs, transactions, and blocks filtering.

## Features

- 🎯 **Interactive Query Building**: Build complex blockchain queries through an intuitive UI
- 🔗 **Multi-Chain Support**: Query data from different blockchain networks
- 🔍 **Advanced Filtering**: Filter logs, transactions, and blocks with granular control
- 📊 **Field Selection**: Choose exactly which fields to return in your queries
- ⚙️ **Advanced Options**: Configure query limits, join modes, and more
- 📋 **Query Export**: Generate ready-to-use cURL commands and JSON queries
- 🚀 **Real-time Execution**: Execute queries directly from the UI

## Use as standalone website

```bash
pnpm i
pnpm dev
```

Other useful commands:
- `pnpm res:build` - build the ReScript code
- `pnpm res:clean` - clean the ReScript build
- `pnpm res:dev` - watch for changes in the ReScript code and rebuild
- `pnpm dev` - run the development server
- `pnpm build:site` - build the site

## Installation (as library)

```bash
npm install hypersync-query-builder-component
```

## Basic Usage In React

```jsx
import React from 'react';
import { HyperSyncQueryBuilder } from 'hypersync-query-builder-component';
import 'hypersync-query-builder-component/styles';

function App() {
  return (
    <div className="App">
      <HyperSyncQueryBuilder />
    </div>
  );
}

export default App;
```

## Advanced Usage

### Using Individual Components

```jsx
import React, { useState } from 'react';
import {
  ChainSelector,
  QueryResults,
  LogFilter,
  TransactionFilter,
  FieldSelector
} from 'hypersync-query-builder-component';

function CustomQueryBuilder() {
  const [selectedChainId, setSelectedChainId] = useState(null);
  const [query, setQuery] = useState({
    fromBlock: 0,
    toBlock: null,
    logs: [],
    transactions: [],
    blocks: [],
    fieldSelection: {
      block: [],
      transaction: [],
      log: [],
      trace: []
    }
  });

  return (
    <div>
      <ChainSelector 
        selectedChainId={selectedChainId}
        onChainSelect={setSelectedChainId}
      />
      
      <FieldSelector 
        fieldSelection={query.fieldSelection}
        onFieldSelectionChange={(newFieldSelection) => 
          setQuery(prev => ({ ...prev, fieldSelection: newFieldSelection }))
        }
      />
      
      <QueryResults 
        query={query}
        selectedChainId={selectedChainId}
      />
    </div>
  );
}
```

### Working with Query Data

```jsx
import React, { useState } from 'react';
import { HyperSyncQueryBuilder, QueryResults } from 'hypersync-query-builder-component';

function QueryWithCallback() {
  const [generatedQuery, setGeneratedQuery] = useState(null);

  // The component provides the query structure via its internal state
  // Access to query data is available through the QueryResults component
  
  return (
    <div>
      <HyperSyncQueryBuilder />
      {/* The query structure and results are managed internally */}
    </div>
  );
}
```

## Component API

### HyperSyncQueryBuilder (Main Component)

The main component that includes the full query building interface.

```jsx
<HyperSyncQueryBuilder />
```

**Props**: None (manages all state internally)

### ChainSelector

Component for selecting blockchain networks.

```jsx
<ChainSelector 
  selectedChainId={number}
  onChainSelect={(chainId) => void}
/>
```

### QueryResults

Component for displaying query JSON and execution results.

```jsx
<QueryResults 
  query={QueryObject}
  selectedChainId={number}
/>
```

### LogFilter

Component for configuring log filtering.

```jsx
<LogFilter
  filterState={LogSelection}
  onFilterChange={(filter) => void}
  onRemove={() => void}
  filterIndex={number}
/>
```

### TransactionFilter

Component for configuring transaction filtering.

```jsx
<TransactionFilter
  filterState={TransactionSelection}
  onFilterChange={(filter) => void}
  onRemove={() => void}
  filterIndex={number}
/>
```

### BlockFilter

Component for configuring block filtering.

```jsx
<BlockFilter
  filterState={BlockSelection}
  onFilterChange={(filter) => void}
  onRemove={() => void}
  filterIndex={number}
/>
```

### FieldSelector

Component for selecting which fields to return.

```jsx
<FieldSelector
  fieldSelection={FieldSelection}
  onFieldSelectionChange={(fieldSelection) => void}
/>
```

## Type Definitions

The package includes comprehensive TypeScript definitions:

```typescript
interface Query {
  fromBlock: number;
  toBlock?: number;
  logs?: LogSelection[];
  transactions?: TransactionSelection[];
  traces?: TraceSelection[];
  blocks?: BlockSelection[];
  includeAllBlocks?: boolean;
  fieldSelection: FieldSelection;
  maxNumBlocks?: number;
  maxNumTransactions?: number;
  maxNumLogs?: number;
  maxNumTraces?: number;
  joinMode?: JoinMode;
}

interface LogSelection {
  address?: string[];
  topics?: string[][];
}

interface TransactionSelection {
  from_?: string[];
  to_?: string[];
  sighash?: string[];
  status?: number;
  kind?: number[];
  contractAddress?: string[];
  authorizationList?: AuthorizationSelection[];
}

// ... and many more
```

## Styling

The component comes with built-in Tailwind CSS styles. Import the styles in your application:

```jsx
import 'hypersync-query-builder-component/styles';
```

## Supported Chains

The component supports all chains available through HyperSync, including:
- Ethereum
- Polygon
- BSC
- Avalanche
- Arbitrum
- Optimism
- And many more...

## Integration with Docusaurus

This component is perfect for interactive documentation. Here's how to integrate it with Docusaurus:

```jsx
// In your MDX file or React component
import { HyperSyncQueryBuilder } from 'hypersync-query-builder-component';
import 'hypersync-query-builder-component/styles';

export default function InteractiveQueryBuilder() {
  return (
    <div style={{ margin: '20px 0' }}>
      <h2>Try the Query Builder</h2>
      <HyperSyncQueryBuilder />
    </div>
  );
}
```

## Requirements

- React 16.8+ (hooks support required)
- Modern browser with ES6 support

## Contributing

This component is built with ReScript and compiled to JavaScript. The source code uses:
- ReScript for type-safe functional programming
- React for the UI layer
- Tailwind CSS for styling
- Vite for building and bundling

## License

MIT

## About HyperSync

HyperSync is a high-performance blockchain indexing solution by Envio. Learn more at [envio.dev](https://envio.dev).

---

Built with ❤️ by the Envio team
