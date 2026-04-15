# Linux Observability & Healthcheck Agent (Ansible Role)

This repository contains a lightweight, JSON-based observability agent designed for Linux environments. It is structured as an **Ansible Role** to be easily deployed across distributed clusters.

This module is a core component of the [ansible-homelab-deployment](https://github.com/aldomendoza-portfolio/ansible-homelab-deployment) ecosystem.

## 🚀 Overview

The agent consists of a specialized Bash script that collects high-level system metrics and container status, exporting the results in a structured JSON format. This approach allows for easy integration with log aggregators, SIEMs, or custom monitoring dashboards.

## ✨ Key Features

* **System Health:** Collects CPU load averages, RAM utilization, and Disk I/O metrics.
* **Network Mapping:** Identifies all active listening ports (TCP/UDP) using modern `ss` socket statistics.
* **Container Discovery:** Automatically detects the Docker engine status and lists active containers with their respective port mappings.
* **Structured Output:** Generates standard JSON payloads for machine-readable telemetría.
* **Automated Deployment:** Includes an Ansible role to handle script distribution, permissions, and Cron-job scheduling.

## 🛠️ Role Variables

The following variables can be adjusted in `defaults/main.yml`:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `agent_install_path` | `/opt/homelab/scripts` | Target directory for the script. |
| `agent_log_path` | `/var/log/homelab_health.json` | Path where the JSON output is stored. |
| `agent_cron_interval` | `*/5` | Execution frequency (Cron syntax). |

## 📦 Installation via Orchestrator

To use this role in your infrastructure, add it to your `requirements.yml`:

```yaml
- name: linux-observability-agent
  src: git@github.com:aldomendoza-portfolio/linux-observability-agent.git
  scm: git
  version: main
```
Then, include it in your main playbook:

```yaml
- hosts: all
  roles:
    - role: linux-observability-agent
```
## 📊 Sample Output

The agent generates a payload similar to the following:

```json
{
  "timestamp": "2026-04-15T14:00:01Z",
  "node": {
    "hostname": "app-node-01",
    "os": "Ubuntu 22.04.4 LTS"
  },
  "metrics": {
    "cpu_load_1m": 0.45,
    "ram_mb": { "total": 4096, "used": 1024 }
  },
  "containers": {
    "docker_engine": "running",
    "running_instances": [
      { "name": "nextcloud", "ports": "80/tcp" }
    ]
  }
}
```

## 🛡️ Security & Governance

This script requires root or sudo privileges to access certain system metrics and Docker socket information. The Ansible role ensures that the script is owned by root:root with 0755 permissions to prevent unauthorized tampering.
