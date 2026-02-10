#!/usr/bin/env node

/**
 * Fetches the latest chain list from the HyperSync API and writes it to
 * src/generated_chains.json.  Run with:
 *
 *   pnpm update-chains          (or npm run update-chains)
 *
 * The generated file is imported by ChainSelector.res at build time and used
 * as the fallback / default chain list.
 */

const API_URL = "https://chains.hyperquery.xyz/active_chains";
const OUT_PATH = new URL("../src/generated_chains.json", import.meta.url);

async function main() {
  console.log(`Fetching chains from ${API_URL} ...`);
  const res = await fetch(API_URL);
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}: ${await res.text()}`);
  }

  const raw = await res.json();
  if (!Array.isArray(raw) || raw.length === 0) {
    throw new Error("API returned no chains");
  }

  // Normalise each entry to the shape ChainSelector expects
  const chains = raw
    .filter((c) => c.name && c.chain_id)
    .map((c) => ({
      name: c.name,
      tier: c.tier ?? "STONE",
      chain_id: c.chain_id,
      ecosystem: c.ecosystem ?? "evm",
      additional_features: c.additional_features ?? inferFeatures(c.name),
    }))
    .sort((a, b) => a.name.localeCompare(b.name));

  const { writeFileSync } = await import("node:fs");
  const { fileURLToPath } = await import("node:url");
  const outFile = fileURLToPath(OUT_PATH);
  writeFileSync(outFile, JSON.stringify(chains, null, 2) + "\n");
  console.log(`Wrote ${chains.length} chains to ${outFile}`);
}

/** Infer additional_features from the chain name (e.g. "-traces" suffix). */
function inferFeatures(name) {
  if (name.endsWith("-traces")) return ["TRACES"];
  return null;
}

main().catch((err) => {
  console.error("update-chains failed:", err.message);
  process.exit(1);
});
