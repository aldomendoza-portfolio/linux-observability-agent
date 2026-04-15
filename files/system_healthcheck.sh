#!/bin/bash

# ==============================================================================
# Script: system_healthcheck.sh
# Descripción: Agente de observabilidad ligero para nodos Linux.
# Salida: JSON estándar por salida estándar (stdout).
# ==============================================================================

# Asegurar que los comandos básicos estén disponibles o fallar con gracia
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 1. Información General del Sistema
HOSTNAME=$(hostname)
UPTIME=$(uptime -p | sed 's/up //')
OS_VERSION=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)

# 2. Métricas de Consumo
# CPU: Promedio de carga a 1 minuto
CPU_LOAD=$(cat /proc/loadavg | awk '{print $1}')

# RAM: Uso de memoria en MB
RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
RAM_USED=$(free -m | awk '/^Mem:/{print $3}')

# Disco: Uso de la partición raíz (/)
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED_PCT=$(df -h / | awk 'NR==2 {print $5}')

# 3. Red: Puertos a la escucha (TCP/UDP)
# Usamos 'ss' en lugar de 'netstat' por ser el estándar moderno
PORTS_LIST=$(ss -tuln | awk 'NR>1 {print "\""$5"\""}' | paste -sd "," -)

# 4. Contenedores (Docker)
DOCKER_STATUS="\"not_installed\""
CONTAINERS_LIST=""

if command -v docker &> /dev/null; then
    if systemctl is-active --quiet docker; then
        DOCKER_STATUS="\"running\""
        # Obtener nombres de contenedores activos y sus puertos publicados
        CONTAINERS_LIST=$(docker ps --format '{"name": "{{.Names}}", "ports": "{{.Ports}}"}' | paste -sd "," -)
    else
        DOCKER_STATUS="\"stopped\""
    fi
fi

# ==============================================================================
# Construcción del Objeto JSON Final
# ==============================================================================

cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "node": {
    "hostname": "${HOSTNAME}",
    "os": "${OS_VERSION}",
    "uptime": "${UPTIME}"
  },
  "metrics": {
    "cpu_load_1m": ${CPU_LOAD},
    "ram_mb": {
      "total": ${RAM_TOTAL},
      "used": ${RAM_USED}
    },
    "disk_root": {
      "total": "${DISK_TOTAL}",
      "usage_percent": "${DISK_USED_PCT}"
    }
  },
  "network": {
    "listening_ports": [${PORTS_LIST}]
  },
  "containers": {
    "docker_engine": ${DOCKER_STATUS},
    "running_instances": [${CONTAINERS_LIST}]
  }
}
EOF