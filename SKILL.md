---
name: daigest
description: Manage Daigest feeds - list, create, read, update, delete, and sync AI-powered digests from subscribed sources. Use when interacting with Daigest API.
allowed-tools: Bash
argument-hint: "[list | create | get <id> | sync <id>]"
---

# Daigest — AI Source Monitoring API

> Create feeds that monitor RSS, web pages, and more. AI summarizes what matters.

Daigest watches your chosen sources and delivers AI-powered digests. This API lets you create feeds, manage sources, trigger AI sync, and read the results.

## Authentication

```
Authorization: Bearer dk_live_xxxxxxxxxxxx
```

API keys are issued at https://daige.st/account/api-keys

## Base URL

```
https://daige.st/api/v1
```

## OpenAPI Spec

```
GET https://daige.st/api/v1/openapi.json
```

Use this to auto-generate tools for your agent framework (GPTs, LangChain, CrewAI, Dify, n8n, etc.).

## Quick Start

### 1. Create a feed with sources

```
POST /feeds
{
  "name": "AI News Digest",
  "memory": "Summarize the latest AI news. Highlight new model releases and benchmark results.",
  "sources": [
    { "type": "rss", "url": "https://example.com/ai-feed.xml" },
    { "type": "url", "url": "https://example.com/blog" }
  ]
}
→ 201 { "id": "feed-uuid", "name": "AI News Digest", ... }
```

### 2. Sync to generate content

```
POST /feeds/{id}/sync
→ 200 { "content": "# AI News\n\n...", "has_changes": true, ... }
```

This triggers AI to fetch all sources and generate a digest. Synchronous — takes 30s to 5min depending on source count.

### 3. Read the digest later

```
GET /feeds/{id}
→ 200 { "content": "# AI News\n\n...", "has_changes": true, ... }
```

Use `?since=2026-02-09T00:00:00Z` to check if content changed. If nothing changed, returns `has_changes: false` with empty content to save tokens.

## Endpoints

### List feeds

```
GET /feeds
→ 200 { "feeds": [{ "id", "name", "source_count", "updated_at", ... }] }
```

### Create a feed

```
POST /feeds
{
  "name": "Feed Name",                          // required, max 200 chars
  "memory": "Instructions for AI summarizer",   // optional, max 1500 chars
  "schedule_enabled": true,                     // optional
  "scheduled_times": [{ "time": "09:00", "days": ["mon", "fri"] }],  // optional
  "sources": [{ "type": "rss", "url": "..." }] // optional
}
→ 201 { "id", "name", "schedule_enabled", "source_count", "created_at" }
```

### Get feed details

```
GET /feeds/{id}
GET /feeds/{id}?since=2026-02-09T00:00:00Z
→ 200 {
  "id", "name", "schedule_enabled", "scheduled_times",
  "content",      // markdown, max 2000 chars. Empty when has_changes is false.
  "memory",       // AI instructions, max 1500 chars
  "has_changes",  // false if nothing changed since `since`
  "updated_at",
  "sources": [{ "id", "type", "name" }]
}
```

### Update a feed

```
PATCH /feeds/{id}
{
  "name": "New Name",                           // optional
  "content": "# Updated content",               // optional, max 2000 chars
  "memory": "New AI instructions",              // optional, max 1500 chars
  "schedule_enabled": true,                     // optional
  "scheduled_times": [{ "time": "10:00" }],     // optional
  "add_sources": [{ "type": "rss", "url": "..." }],   // optional, max 20
  "remove_source_ids": ["source-uuid"],                // optional, max 20
  "create_version": true                        // optional, default false
}
→ 200 { "id", "name", "content", "memory", "sources", "updated_at", ... }
```

- `create_version: true` saves a snapshot before overwriting. Use when you want to preserve history.
- `remove_source_ids`: Get IDs from `GET /feeds/{id}` response `sources[].id`.

### Delete a feed

```
DELETE /feeds/{id}
→ 200 { "deleted": true }
```

### Sync a feed

```
POST /feeds/{id}/sync
→ 200 { "id", "name", "content", "has_changes": true, "sources", ... }
```

Fetches latest data from all sources, then AI generates/updates the digest. Synchronous — waits until completion. Consumes AI quota.

## Source Types

| Type | Via API | Notes |
|------|---------|-------|
| `rss` | Yes | RSS/Atom feed URL |
| `url` | Yes | Any web page URL |
| `slack` | No | Requires OAuth in web app |
| `notion` | No | Requires OAuth in web app |
| `github` | No | Requires OAuth in web app |
| `discord` | No | Pro plan, OAuth in web app |
| `youtube` | No | Pro plan, configured in web app |
| `x` | No | Pro plan, configured in web app |
| `reddit` | No | Pro plan, configured in web app |
| `substack` | No | Pro plan, configured in web app |
| `threads` | No | Pro plan, configured in web app |

To use OAuth or premium sources, set them up in the web app first. The API can then read and sync feeds that include these sources.

## Rate Limits

| Scope | Limit |
|-------|-------|
| General | 60 requests/min per API key |
| Sync | 10 requests/min per API key |

Exceeding limits returns `429` with `Retry-After` header (seconds).

## Error Responses

```json
{ "error": "description", "code": "ERROR_CODE" }
```

| Status | Meaning |
|--------|---------|
| 400 | Validation error (bad input) |
| 401 | Missing or invalid API key |
| 404 | Feed not found |
| 429 | Rate limit exceeded |

## Tips

- **Memory is powerful.** Use it to control AI behavior per feed: language, focus areas, output format, what to highlight or ignore.
- **Use `since` to poll efficiently.** Pass the last `updated_at` value. If `has_changes` is false, skip processing.
- **Sync costs quota.** Each sync consumes an AI request from the user's plan. Don't over-sync.
- **Combine RSS + URL sources** for comprehensive monitoring. RSS for regular updates, URL for specific pages.
- **Schedule vs manual sync.** Set `schedule_enabled: true` with `scheduled_times` for automatic updates, or call `/sync` manually when needed.

## Links

- Website: https://daige.st
- OpenAPI spec: https://daige.st/api/v1/openapi.json
- API keys: https://daige.st/account/api-keys
- Support: help@daige.st
