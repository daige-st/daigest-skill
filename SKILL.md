---
name: daigest
description: Manage Daigest feeds - list, create, read, update, delete, and sync AI-powered digests from subscribed sources. Use when interacting with Daigest API.
allowed-tools: Bash
argument-hint: "[list | create | get <id> | sync <id>]"
---

# Daigest API

Daigest API를 통해 피드를 관리합니다. 모든 요청은 `curl`로 수행합니다.

## Setup

API key는 환경변수 `DAIGEST_API_KEY`에서 읽습니다.

```bash
# 키 확인
echo $DAIGEST_API_KEY
```

키가 없으면 사용자에게 https://daige.st/account 에서 API key 발급을 안내하세요.

## Base URL

```
https://daige.st/api/v1
```

## Authentication

모든 요청에 Bearer token 포함:

```bash
-H "Authorization: Bearer $DAIGEST_API_KEY"
```

## Endpoints

### List feeds

```bash
curl -s https://daige.st/api/v1/feeds \
  -H "Authorization: Bearer $DAIGEST_API_KEY" | jq .
```

Returns: `{ feeds: [{ id, name, schedule_enabled, scheduled_times, updated_at, source_count }] }`

### Get feed

피드 상세 조회. content, memory, sources 포함.

```bash
curl -s "https://daige.st/api/v1/feeds/{id}" \
  -H "Authorization: Bearer $DAIGEST_API_KEY" | jq .
```

`since` 파라미터로 변경분만 조회 (토큰 절약):

```bash
curl -s "https://daige.st/api/v1/feeds/{id}?since=2026-02-07T00:00:00Z" \
  -H "Authorization: Bearer $DAIGEST_API_KEY" | jq .
```

Returns: `{ id, name, schedule_enabled, scheduled_times, content, memory, has_changes, updated_at, sources: [{ id, type, name }] }`

`has_changes: false`이면 `content`는 빈 문자열.

### Create feed

```bash
curl -s -X POST https://daige.st/api/v1/feeds \
  -H "Authorization: Bearer $DAIGEST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "피드 이름",
    "memory": "AI 요약 지시사항",
    "schedule_enabled": true,
    "scheduled_times": [{ "time": "09:00", "days": ["mon","tue","wed","thu","fri"] }],
    "sources": [
      { "type": "rss", "url": "https://example.com/feed.xml" },
      { "type": "url", "url": "https://example.com/page" }
    ]
  }' | jq .
```

- API로 추가 가능한 소스: `rss`, `url`만
- OAuth 기반 소스(Slack, Notion, GitHub, Discord 등)는 https://daige.st 웹에서 연결 필요
- `scheduled_times`의 `days` 생략 시 매일 실행

### Update feed

변경할 필드만 전송:

```bash
curl -s -X PATCH "https://daige.st/api/v1/feeds/{id}" \
  -H "Authorization: Bearer $DAIGEST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "새 이름",
    "content": "# 수정된 내용\n\n...",
    "memory": "새로운 AI 지시사항",
    "schedule_enabled": true,
    "scheduled_times": [{ "time": "10:00", "days": ["mon"] }],
    "add_sources": [{ "type": "rss", "url": "https://new-feed.com/rss" }],
    "remove_source_ids": ["source-uuid"]
  }' | jq .
```

- `remove_source_ids`: GET /feeds/{id}의 `sources[].id` 참조
- `content` 변경 시 버전 자동 생성

### Delete feed

```bash
curl -s -X DELETE "https://daige.st/api/v1/feeds/{id}" \
  -H "Authorization: Bearer $DAIGEST_API_KEY" | jq .
```

### Sync feed

소스에서 최신 데이터를 가져와 AI가 다이제스트 갱신. 동기 처리 (30초~2분, 최대 5분).

```bash
curl -s -X POST "https://daige.st/api/v1/feeds/{id}/sync" \
  -H "Authorization: Bearer $DAIGEST_API_KEY" \
  --max-time 300 | jq .
```

AI quota를 소모합니다. quota 초과 시 429 에러.

## Rate Limits

- 일반: 60 req/min
- Sync: 10 req/min
- 초과 시 429 + `Retry-After` 헤더

## Field Limits

| Field | Max |
|-------|-----|
| name | 200자 |
| content | 2,000자 |
| memory | 1,500자 |

## Error Handling

에러 응답 형식: `{ "error": "message", "code": "ERROR_CODE" }`

- `401`: API key 누락/무효
- `404`: 피드 없음
- `429`: Rate limit 초과 → `Retry-After` 헤더 확인 후 재시도

## Arguments

`$ARGUMENTS`가 제공되면 해당 작업을 바로 수행합니다:

- `list` → 피드 목록 조회
- `create` → 사용자에게 이름, 소스 등을 물어본 후 생성
- `get <id>` → 특정 피드 조회
- `sync <id>` → 특정 피드 동기화
- 없으면 → 피드 목록부터 조회하여 상황 파악
