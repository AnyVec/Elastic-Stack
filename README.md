# ELK 9.x Stack with Docker Compose

Configuration files for the blog post **[ELK 9.x Stack with Docker Compose](https://blog.anyvec.com/posts/elastic-stack-9-x/)**: a step-by-step guide to deploying a secured Elastic Stack 9.x (Elasticsearch, Logstash, Kibana) with Docker Compose.

The post explains every file here: TLS between services, authentication, memory tuning, firewall rules, network isolation and a Caddy reverse proxy. **Read it before deploying.** This repository holds only the files; the post explains them.

> **ELK version:** 9.5.5 · **Tested on:** Debian 13, Arch Linux

## What's inside

| Path                          | Purpose                                              |
|-------------------------------|------------------------------------------------------|
| `.env`                        | Versions, credentials, ports and memory limits       |
| `docker-compose.yml`          | Stack definition                                     |
| `setup/create-certs.sh`       | Generates the internal CA and service certificates   |
| `elasticsearch/config/`       | `elasticsearch.yml`                                  |
| `logstash/config/`            | `logstash.yml`                                       |
| `logstash/pipeline/`          | `logstash.conf` (Beats + TCP inputs)                 |
| `kibana/config/`              | `kibana.yml`                                         |
| `caddy/Caddyfile`             | Reverse proxy with public TLS (production setup)     |

## Quick start

1. Replace every `changeme` and encryption key in `.env`. See [Step 1 - Environment Variables](https://blog.anyvec.com/posts/elastic-stack-9-x/#step-1-environment-variables) for how to generate them.
2. Set `vm.max_map_count` on the host (see Prerequisites).
3. Follow the deployment order in [Step 7 - Deploy](https://blog.anyvec.com/posts/elastic-stack-9-x/#step-7-deploy) of the post.

> ⚠️  Never commit your real `.env`. Don't expose the stack publicly before applying the **Deployment Hardening** section (firewall rules, secrets manager, reverse proxy).

## Feedback

Found an issue or something outdated with a newer Elastic release? Open an issue or a pull request.
