# daigest-skill

Agent skill for the [Daigest](https://daige.st) API. Works with [Claude Code](https://claude.ai/code), Cursor, Codex, and [35+ agents](https://github.com/vercel-labs/skills).

## Installation

```bash
npx skills add daige-st/daigest-skill
```

<details>
<summary>Manual installation</summary>

```bash
git clone https://github.com/daigest/daigest-skill
cd daigest-skill
./install.sh
```

</details>

## Setup

Set your API key:

```bash
export DAIGEST_API_KEY=dk_live_xxxxxxxxxxxx
```

Get your API key at [daige.st/account](https://daige.st/account).

## Usage

```
/daigest list          # List all feeds
/daigest get <id>      # Get feed details
/daigest create        # Create a new feed
/daigest sync <id>     # Sync feed with AI
```

## Update

```bash
npx skills update
```

## API Reference

Full OpenAPI spec: [daige.st/api/v1/openapi.json](https://daige.st/api/v1/openapi.json)
