SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# ANSI color tokens
C_RESET   := \033[0m
C_BOLD    := \033[1m
C_DIM     := \033[2m
C_CYAN    := \033[1;36m
C_BLUE    := \033[1;34m
C_MAGENTA := \033[1;35m
C_GREEN   := \033[1;32m
C_YELLOW  := \033[1;33m

SERVICES := wonderlab central-gateway git-pulse
GATEWAY_SUBCMDS := install start start-client start-server stop db-generate sync-db migrate seed studio check lint typecheck test build format clean

.PHONY: help init install db-up db-down db-reset sync-db db-generate \
        start start-clients start-servers stop check lint typecheck test \
        build format git-sync status clean wonderlab-test-e2e

# ------------------------------------------------------------------------------
# Interactive Colored Help (Grouped by Repo)
# ------------------------------------------------------------------------------
help:
	@printf "$(C_BOLD)Prism Hub — Unified Ecosystem Orchestration CLI$(C_RESET)\n"
	@printf "$(C_DIM)Ports: Wonderlab (4100/4101) • Central Gateway (5100/5101) • Git Pulse (6100/6101) • Postgres (5432)$(C_RESET)\n\n"
	@printf "$(C_CYAN)━━━ Global & Shared Infrastructure ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(C_RESET)\n"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make init" "Init submodules on develop, create envs, start DB, install & sync-db"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make status" "Show Git branch, dirty files, Postgres status & active dev ports"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make git-sync" "Pull latest origin/develop across all clean submodules"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make install" "Run pnpm install across all 3 services"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make db-up | db-down | db-reset" "Manage shared PostgreSQL 16 (wonderlab, central_gateway, git_pulse)"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make sync-db | db-generate" "Generate Prisma clients & deploy local migrations across all services"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make start" "Start DB + all 6 dev apps concurrently (clients + servers)"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make start-clients | start-servers" "Start only all 3 Next.js clients OR only all 3 NestJS servers"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make stop" "Free dev ports (4100/4101, 5100/5101, 6100/6101)"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make check" "Run verification suite (no build) across Wonderlab, Central Gateway & Git Pulse"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make lint | typecheck | test | build" "Run verification/build script across all 3 services"
	@printf "  $(C_CYAN)%-44s$(C_RESET) %s\n" "make format | clean" "Format code or remove client/.next & server/dist caches"
	@printf "\n$(C_BLUE)━━━ Wonderlab (4100 / 4101) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(C_RESET)\n"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-start" "Start Wonderlab client (4100) + server (4101)"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-start-client | -server" "Start only Wonderlab client OR server"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-sync-db" "Generate Prisma client & deploy local migrations (+ initial seed)"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-migrate [NAME=...]" "Create/apply a new Prisma dev migration (local DB only)"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-seed | -studio | -db-generate" "Seed DB, open Prisma Studio, or regenerate Prisma Client"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-check | -test-e2e" "Run pnpm check (format, lint, typecheck, test, e2e) or E2E suite"
	@printf "  $(C_BLUE)%-44s$(C_RESET) %s\n" "make wonderlab-{install,lint,test,build}" "Also supports: -typecheck, -format, -clean, -stop"
	@printf "\n$(C_MAGENTA)━━━ Central Gateway (5100 / 5101) — short alias: gateway-* ━━━━━━━━━━━━━━━━━━━━━━━━━━━$(C_RESET)\n"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make central-gateway-start" "Start client (5100) + server (5101) [alias: make gateway-start]"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make gateway-start-client | -server" "Start only Central Gateway client OR server"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make central-gateway-sync-db" "Generate client & deploy local migrations [alias: gateway-sync-db]"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make gateway-migrate [NAME=...]" "Create/apply a new Prisma dev migration (local DB only)"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make gateway-seed | -studio | -db-generate" "Seed DB, open Prisma Studio, or regenerate Prisma Client"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make gateway-check" "Run pnpm check (format, lint, typecheck, test) in Central Gateway"
	@printf "  $(C_MAGENTA)%-44s$(C_RESET) %s\n" "make gateway-{install,lint,test,build}" "Also supports: -typecheck, -format, -clean, -stop (or central-gateway-*)"
	@printf "\n$(C_GREEN)━━━ Git Pulse (6100 / 6101) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(C_RESET)\n"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n" "make git-pulse-start" "Start Git Pulse client (6100) + server (6101)"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n" "make git-pulse-start-client | -server" "Start only Git Pulse client OR server"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n" "make git-pulse-sync-db" "Generate Prisma client & deploy local migrations (+ initial seed)"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n" "make git-pulse-migrate [NAME=...]" "Create/apply a new Prisma dev migration (local DB only)"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n" "make git-pulse-seed | -studio | -db-generate" "Seed DB, open Prisma Studio, or regenerate Prisma Client"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n" "make git-pulse-check" "Run pnpm check (format, lint, typecheck, test) in Git Pulse"
	@printf "  $(C_GREEN)%-44s$(C_RESET) %s\n\n" "make git-pulse-{install,lint,test,build}" "Also supports: -typecheck, -format, -clean, -stop"

# ------------------------------------------------------------------------------
# Global Commands
# ------------------------------------------------------------------------------
init:
	@./scripts/init.sh

git-sync:
	@./scripts/git-sync.sh

status:
	@./scripts/status.sh

db-up:
	@./scripts/db-up.sh

db-down:
	@docker compose down

db-reset:
	@./scripts/db-reset.sh

install: $(addsuffix -install,$(SERVICES))
sync-db: db-up $(addsuffix -sync-db,$(SERVICES))
db-generate: $(addsuffix -db-generate,$(SERVICES))
check: $(addsuffix -check,$(SERVICES))
lint: $(addsuffix -lint,$(SERVICES))
typecheck: $(addsuffix -typecheck,$(SERVICES))
test: $(addsuffix -test,$(SERVICES))
build: $(addsuffix -build,$(SERVICES))
format: $(addsuffix -format,$(SERVICES))
clean: $(addsuffix -clean,$(SERVICES))

start: db-up
	@node ./scripts/dev-all.mjs --mode=all

start-clients:
	@node ./scripts/dev-all.mjs --mode=clients

start-servers: db-up
	@node ./scripts/dev-all.mjs --mode=servers

stop:
	@./scripts/stop.sh

wonderlab-test-e2e:
	@./scripts/check-local-db.sh wonderlab
	@pnpm --dir services/wonderlab test:e2e

# ------------------------------------------------------------------------------
# Standardized Per-Service Target Generator
# ------------------------------------------------------------------------------
define SERVICE_TARGETS
.PHONY: $(1)-install $(1)-start $(1)-start-client $(1)-start-server $(1)-stop \
        $(1)-db-generate $(1)-sync-db $(1)-migrate $(1)-seed $(1)-studio \
        $(1)-check $(1)-lint $(1)-typecheck $(1)-test $(1)-build $(1)-format $(1)-clean

$(1)-install:
	@pnpm --dir services/$(1) install

$(1)-start: db-up
	@pnpm --dir services/$(1) dev

$(1)-start-client:
	@pnpm --dir services/$(1) dev:client

$(1)-start-server: db-up
	@pnpm --dir services/$(1) dev:server

$(1)-stop:
	@./scripts/stop.sh $(1)

$(1)-db-generate:
	@./scripts/db-run.sh $(1) generate

$(1)-sync-db: db-up
	@./scripts/db-run.sh $(1) sync

$(1)-migrate: db-up
	@./scripts/db-run.sh $(1) migrate

$(1)-seed: db-up
	@./scripts/db-run.sh $(1) seed

$(1)-studio: db-up
	@./scripts/db-run.sh $(1) studio

$(1)-check:
	@pnpm --dir services/$(1) check

$(1)-lint:
	@pnpm --dir services/$(1) lint

$(1)-typecheck:
	@pnpm --dir services/$(1) typecheck

$(1)-test:
	@pnpm --dir services/$(1) test

$(1)-build:
	@pnpm --dir services/$(1) build

$(1)-format:
	@pnpm --dir services/$(1) format

$(1)-clean:
	@rm -rf services/$(1)/client/.next services/$(1)/server/dist
endef

$(foreach svc,$(SERVICES),$(eval $(call SERVICE_TARGETS,$(svc))))

# Short gateway-* aliases mapping cleanly to central-gateway-*
define GATEWAY_ALIAS_TEMPLATE
.PHONY: gateway-$(1)
gateway-$(1): central-gateway-$(1)
endef

$(foreach cmd,$(GATEWAY_SUBCMDS),$(eval $(call GATEWAY_ALIAS_TEMPLATE,$(cmd))))
