---
name: gateway-auth-sso
description: Central Gateway OAuth2 Authorization Code + PKCE (S256) SSO protocol, session cookies, and IAM rules.
---

# Central Gateway SSO & IAM Architecture

Applies to `services/central-gateway/` and child app OAuth2 integrations.

## 1. OAuth2 Authorization Code Flow + PKCE (`S256`)

1. **Authorize (`GET /api/v1/auth/oauth/authorize`)**:
   - Params: `client_id`, `redirect_uri` (must exact-match registered whitelist), `response_type=code`, `state` (CSRF token), `code_challenge` (base64url SHA-256), `code_challenge_method=S256`.
   - Active `gateway_session` auto-issues single-use code and redirects to `redirect_uri`; otherwise renders Cosmic Violet Login first.
2. **Token Exchange (`POST /api/v1/auth/oauth/token`)**:
   - Payload: `grant_type=authorization_code`, `code` (5-min TTL, single-use), `client_id`, `code_verifier`.
   - Verifies `SHA256(code_verifier) === code_challenge`, sets `usedAt`, returns `{ access_token, user: { id, username, email, role, avatarUrl } }`.

## 2. Session Cookie & Isolation Policy

- **Gateway Cookie (`gateway_session`)**: Scoped to Gateway domain, `HttpOnly: true`, `SameSite: Lax`, `Secure: true` in production.
- **Child Apps**: Never share cookie domains with Gateway; exchange code via S2S and issue independent local session cookies. Child logout does not revoke Gateway session unless explicit SLO is called.

## 3. Fail-Fast Error Codes

- `invalid_client` (unknown/inactive `client_id`), `invalid_redirect_uri` (whitelist mismatch), `invalid_grant` (expired or `usedAt != null` code), `invalid_verification` (PKCE hash mismatch).
