# Makefile

COMPOSE  = docker compose
VAULT    = vault
AWS      = aws

# ── Colors ─────────────────────────────────────────────────────────────────
RED    = \033[0;31m
GREEN  = \033[0;32m
YELLOW = \033[0;33m
BLUE   = \033[0;34m
RESET  = \033[0m

# ──────────────────────────────────────────────────────────────────────────
# Help
# ──────────────────────────────────────────────────────────────────────────

.PHONY: help
help:
	@echo ""
	@echo -e "$(BLUE)ELK Stack — Available Commands$(RESET)"
	@echo "──────────────────────────────────────────"
	@echo -e "$(GREEN)Secrets$(RESET)"
	@echo "  make secrets-vault      Fetch secrets from HashiCorp Vault"
	@echo "  make secrets-aws        Fetch secrets from AWS Secrets Manager"
	@echo ""
	@echo -e "$(GREEN)Deploy$(RESET)"
	@echo "  make deploy-vault       Fetch from Vault then deploy"
	@echo "  make deploy-aws         Fetch from AWS then deploy"
	@echo ""
	@echo -e "$(GREEN)Stack$(RESET)"
	@echo "  make up                 Start all services"
	@echo "  make down               Stop all services"
	@echo "  make restart            Restart all services"
	@echo "  make ps                 Show running containers"
	@echo "  make logs               Follow all logs"
	@echo ""
	@echo -e "$(GREEN)Maintenance$(RESET)"
	@echo "  make purge              Stop and remove all volumes (DESTRUCTIVE)"
	@echo "  make backup             Backup Elasticsearch data volume"
	@echo "──────────────────────────────────────────"
	@echo ""

# ──────────────────────────────────────────────────────────────────────────
# Secrets — HashiCorp Vault
# ──────────────────────────────────────────────────────────────────────────

.PHONY: secrets-vault
secrets-vault:
	@echo -e "$(YELLOW)Fetching secrets from Vault...$(RESET)"
	@$(VAULT) kv get -field=elastic_password    secret/elk > /dev/null 2>&1 || \
	    (echo -e "$(RED)ERROR: Could not reach Vault$(RESET)" && exit 1)
	$(eval export ELASTIC_PASSWORD    := $(shell $(VAULT) kv get -field=elastic_password    secret/elk))
	$(eval export KIBANA_PASSWORD     := $(shell $(VAULT) kv get -field=kibana_password     secret/elk))
	$(eval export LOGSTASH_PASSWORD   := $(shell $(VAULT) kv get -field=logstash_password   secret/elk))
	$(eval export KIBANA_ENCRYPTION_KEY := $(shell $(VAULT) kv get -field=kibana_encryption_key secret/elk))
	$(eval export KIBANA_REPORTING_KEY  := $(shell $(VAULT) kv get -field=kibana_reporting_key  secret/elk))
	$(eval export KIBANA_SECURITY_KEY   := $(shell $(VAULT) kv get -field=kibana_security_key   secret/elk))
	@echo -e "$(GREEN)Secrets fetched from Vault$(RESET)"

# ──────────────────────────────────────────────────────────────────────────
# Secrets — AWS Secrets Manager
# ──────────────────────────────────────────────────────────────────────────

.PHONY: secrets-aws
secrets-aws:
	@echo -e "$(YELLOW)Fetching secrets from AWS Secrets Manager...$(RESET)"
	@$(AWS) secretsmanager get-secret-value --secret-id elk/elastic_password > /dev/null 2>&1 || \
	    (echo -e "$(RED)ERROR: Could not reach AWS Secrets Manager$(RESET)" && exit 1)
	$(eval export ELASTIC_PASSWORD      := $(shell $(AWS) secretsmanager get-secret-value --secret-id elk/elastic_password      --query SecretString --output text))
	$(eval export KIBANA_PASSWORD       := $(shell $(AWS) secretsmanager get-secret-value --secret-id elk/kibana_password       --query SecretString --output text))
	$(eval export LOGSTASH_PASSWORD     := $(shell $(AWS) secretsmanager get-secret-value --secret-id elk/logstash_password     --query SecretString --output text))
	$(eval export KIBANA_ENCRYPTION_KEY := $(shell $(AWS) secretsmanager get-secret-value --secret-id elk/kibana_encryption_key --query SecretString --output text))
	$(eval export KIBANA_REPORTING_KEY  := $(shell $(AWS) secretsmanager get-secret-value --secret-id elk/kibana_reporting_key  --query SecretString --output text))
	$(eval export KIBANA_SECURITY_KEY   := $(shell $(AWS) secretsmanager get-secret-value --secret-id elk/kibana_security_key   --query SecretString --output text))
	@echo -e "$(GREEN)Secrets fetched from AWS$(RESET)"

# ──────────────────────────────────────────────────────────────────────────
# Deploy
# ──────────────────────────────────────────────────────────────────────────

.PHONY: deploy-vault
deploy-vault: secrets-vault
	@echo -e "$(YELLOW)Deploying ELK stack with Vault secrets...$(RESET)"
	@$(MAKE) up
	@echo -e "$(GREEN)ELK stack deployed$(RESET)"

.PHONY: deploy-aws
deploy-aws: secrets-aws
	@echo -e "$(YELLOW)Deploying ELK stack with AWS secrets...$(RESET)"
	@$(MAKE) up
	@echo -e "$(GREEN)ELK stack deployed$(RESET)"

# ──────────────────────────────────────────────────────────────────────────
# Stack
# ──────────────────────────────────────────────────────────────────────────

.PHONY: up
up:
	@echo -e "$(YELLOW)Starting ELK stack...$(RESET)"
	@$(COMPOSE) up -d
	@echo -e "$(GREEN)ELK stack started$(RESET)"

.PHONY: down
down:
	@echo -e "$(YELLOW)Stopping ELK stack...$(RESET)"
	@$(COMPOSE) down
	@echo -e "$(GREEN)ELK stack stopped$(RESET)"

.PHONY: restart
restart:
	@echo -e "$(YELLOW)Restarting ELK stack...$(RESET)"
	@$(COMPOSE) restart
	@echo -e "$(GREEN)ELK stack restarted$(RESET)"

.PHONY: ps
ps:
	@$(COMPOSE) ps

.PHONY: logs
logs:
	@$(COMPOSE) logs -f

# ──────────────────────────────────────────────────────────────────────────
# Maintenance
# ──────────────────────────────────────────────────────────────────────────

.PHONY: purge
purge:
	@echo -e "$(RED)WARNING: This will destroy all data. Press Ctrl+C to cancel...$(RESET)"
	@sleep 5
	@$(COMPOSE) down -v
	@echo -e "$(GREEN)Stack purged$(RESET)"


.PHONY: backup
backup:
	@echo -e "$(YELLOW)Backing up Elasticsearch data...$(RESET)"
	@mkdir -p backup
	@docker run --rm \
	    -v elk-stack_esdata:/data \
	    -v $(PWD)/backup:/backup \
	    alpine tar czf /backup/$(shell date -I)-es-backup.tar.gz /data
	@echo -e "$(GREEN)Backup saved to ./backup/$(RESET)"

