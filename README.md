# 🛜🕸️ DDoS Simulation
This project simulates a DDoS (Distributed Denial of Service) attack on an intentionally vulnerable victim, in this case a basic e-commerce web application setup using *Node.js* and *SQLite*.

## 🪲 Vulnerability being demo-ed
This simulation primarily addresses vulnerabilities leading to **Resource Exhaustion** such as:
* [CWE-770: Allocation of Resources Without Limits or Throttling](https://cwe.mitre.org/data/definitions/770.html)
* [OWASP API4:2023 Unrestricted Resource Consumption](https://api-security.owasp.org/editions/2023/en/0xa4-unrestricted-resource-consumption/)

Computing resources is utilized for any sort of work by software and hardware, and thus there are ways to exploit this maliciously. For example, unregulated computationally heavy requests to a service spikes up memory and CPU usage and eventually enough of these requests lead to exhausting resource limits, leading to crashes and failures.

Documented cases include:
* [CVE-2021-22029: VMware Workspace ONE UEM REST API](https://app.opencve.io/cve/CVE-2021-22029)
* [CVE-2025-48375: Schule Missing Rate Limiting on OTP Email Requests](https://app.opencve.io/cve/CVE-2025-48375)

## ⚙️ How this simulation works
This section details how the simulation has been designed.

### 1. Virtual Docker Container (Bot)
This project uses **Docker**, acting as the test environment, to spin up multiple containers with scripts for:
* Establishing a Websocket connection to the Bot Master (C2 Layer)
* Bash scripts to attack, using relevant tools such as `hping3`, a given target

### 2. HTTP Server managing Websocket Connections (Master)
When a container (bot) starts, it attempts to establish a Websocket connection with the C2 layer and keeps trying until one is established. The C2 Layer has an HTTP server that manages Websocket connections, and sends/broadcasts messages to
bots.

The bot then receives target IPs from the C2 layer and executes scripts accordingly to attack the destination.

### 3. Vulnerable E-Commerce Web Application
The web application is implemented using *Node.js* and *SQLite*, running on a container with low specs so as to crash faster for the sake of demonstration. The web application provides a **search feature with filtering options, which the botnet will exploit by sending volumous amounts of complex queries** which requires the database to work significantly more until resources are exhausted.

### 4. Simulated Environment
Docker is used to create the simulated environment comprising:
* **Botnet Network** on a Docker subnet `172.20.0.0`
* **Victim Network** on a Docker subnet `192.0.2.0`

Topology (inside Docker) is as follows:
```
Bot Network (172.20.0.x) ----- (172.20.0.2) Router (192.0.2.2) ----- (192.0.2.x) Victim Network
```

## 🔧 Possible Countermeasures 
This section briefly goes over the implemented counter measures.

### 1. Firewall + Rate Limiting
### 2. Firewall + Rate Limiting + Request Cache
### 3. Firewall + Rate Limiting + Request Cache + Load Balancing

## 📦 Prerequisites
Make sure you have the following dependencies installed.

* [Golang 1.27.0](https://go.dev/doc/install)
* [Docker 29.7.2](https://www.docker.com/get-started/)
* [Docker Compose 5.5.0](https://docs.docker.com/compose/install/)

## 💻 Setup & Usage
Follow these steps to get your development environment setup.

1. **Clone the repository**
    ```bash
    git clone https://github.com/dotping-me/simulated-ddos.git && cd simulated-ddos/
    ```

2. **Start C2 HTTP server**
    ```bash
    cd ./attacker && go run ./cmd/c2/main.go
    ```

3. **Spin up a given environment (from Project Root)**
    ```bash
    sudo docker compose -f templates/<template>/compose.yml up --build -d --scale bot=<num_of_bots>
    ```
   
4. **Cleanup after the mess (from Project Root)**
    ```bash
    sudo docker compose -f templates/<template>/compose.yml down --remove-orphans
    ```