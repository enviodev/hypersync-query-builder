# HyperSync Query Builder

[![Discord](https://img.shields.io/badge/Discord-Join%20Chat-7289da?logo=discord&logoColor=white)](https://discord.com/invite/envio)

A React component library and standalone web app for visually building [HyperSync](https://docs.envio.dev/docs/HyperSync/overview) queries. Construct complex blockchain data queries through an intuitive UI without writing code.

Live at [builder.hypersync.xyz](https://builder.hypersync.xyz).

## What is HyperSync?

[HyperSync](https://docs.envio.dev/docs/HyperSync/overview) is Envio's high-performance blockchain data retrieval layer - a purpose-built alternative to JSON-RPC endpoints that offers up to 2000x faster data access across 70+ EVM-compatible networks.

## Features

- **Visual query building**: Construct HyperSync queries through a UI instead of writing JSON by hand
- **Multi-chain support**: Select from all networks supported by HyperSync
- **Log, transaction, and block filtering**: Configure filters for any combination of data types
- **Field selection**: Choose exactly which fields to return in your queries
- **Query export**: Generate ready-to-use cURL commands and JSON queries to copy into your code
- **Real-time execution**: Run queries directly from the UI and inspect the response

## Use as Standalone Website

```bash
pnpm i
pnpm dev
```

Other commands:
- `pnpm res:build` - build the ReScript source
- `pnpm res:dev` - watch and rebuild ReScript on changes
- `pnpm build:site` - build the production site

## Use as a React Library

### Installation

```bash
npm install hypersync-query-builder-component
```

### Basic Usage

```jsx
import { HyperSyncQueryBuilder } from 'hypersync-query-builder-component';
import 'hypersync-query-builder-component/styles';

function App() {
  return <HyperSyncQueryBuilder />;
}
```

### Individual Components

```jsx
import {
  ChainSelector,
  QueryResults,
  LogFilter,
  TransactionFilter,
  FieldSelector
} from 'hypersync-query-builder-component';
```

See the full component API in the [source README](./README.md).

## Requirements

- React 16.8 or newer
- Modern browser with ES6 support

## Built With

- [ReScript](https://rescript-lang.org) - type-safe functional source language
- React - UI layer
- Tailwind CSS - styling
- Vite - build tooling

## Documentation

- [HyperSync Docs](https://docs.envio.dev/docs/HyperSync/overview)
- [Query Reference](https://docs.envio.dev/docs/HyperSync/hypersync-query)
- [Supported Networks](https://docs.envio.dev/docs/HyperSync/hypersync-supported-networks)
- [Live Query Builder](https://builder.hypersync.xyz)

## License

MIT

## Support

- [Discord community](https://discord.com/invite/envio)
- [Envio Docs](https://docs.envio.dev)
