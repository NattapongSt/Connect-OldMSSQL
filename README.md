# Connecting to Legacy MS SQL Server with Docker and FreeTDS

This project demonstrates how to connect Python (pyodbc) to a legacy Microsoft SQL Server instance that does not support modern security protocols (like TLS 1.2+).

## 🎯 1. The Goal & The Problem

**Goal:** Connect a Python script to a SQL Server at IP: `10.16.252.117`

**Problems Encountered:**
1.  **Microsoft ODBC Driver 18:** Failed with `pyodbc.OperationalError: ... (10054) (SQLDriverConnect)`.
    * **Reason:** The modern driver attempts a security handshake using **TLS 1.2**. The legacy server does not understand this protocol and immediately terminates the connection (Connection Reset).
2.  **Microsoft ODBC Driver 17:** Failed with `pyodbc.Error: ('IM004', ...SQLAllocHandle... failed)`.
    * **Reason:** The driver installation on a modern Linux host is broken. It has unmet dependencies (like `libssl1.1`) that no longer exist in modern operating systems.

## 💡 2. Solution Overview

We solve this by containerizing the application to escape the host's dependency issues and bypassing the modern driver's security enforcement.

1.  **Use Docker:** We create a **clean, isolated container environment** where we have full control over all installed packages.
2.  **Use FreeTDS:** We replace the proprietary Microsoft drivers with `FreeTDS`, a flexible open-source driver.
3.  **Force a Legacy Protocol:** We configure FreeTDS to speak an "ancient" protocol (`TDS_Version=7.0`). This protocol version does not use modern TLS, completely bypassing the handshake problem that caused the `10054` error.

## 🗂️ 3. Project Files

* `Dockerfile`
    * The blueprint for our container.
    * Installs `python`, `unixodbc` (the driver manager), `freetds-bin` (for testing), and `tdsodbc` (the FreeTDS-to-ODBC bridge).
    * Installs `pyodbc`, `dotenv` via `pip`.
    * Copies our configuration files and Python script into the image.

* `test.py`
    * The main Python script for testing the connection.
    * **Crucially, its connection string is modified to use `DRIVER={FreeTDS}` and explicitly force `TDS_Version=7.0`.**

* `odbcinst.ini`
    * The driver "registry" file for `unixODBC`.
    * Tells `unixODBC` that when `DRIVER={FreeTDS}` is requested, it should load the driver file from `/usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so`.

* `.env` 
    * Environment file for database details

## 🚀 4. How to Use

You must have [Docker](https://www.docker.com/) installed on your machine.

1.  **Step 1: Edit `test.py`**
    Open `test.py` and enter the **database details** in the .env file.

2.  **Step 2: Build the Docker Image**
    Open a terminal in this project's folder and run:
    ```bash
    docker build -t mssql-connect .
    ```
    (The `-t` flag "tags" or names the image `mssql-connect`)

3.  **Step 3: Run the Container**
    Run this command to execute the connection test:
    ```bash
    docker run --rm mssql-connect
    ```

## 📖 5. Command Explanation

### `docker run --rm mssql-connect`

* `docker run`: The command to run a new container.
* `--rm`: (Remove) Automatically deletes the container after it finishes running. This prevents cluttering your system with stopped containers.
* `mssql-connect`: The name of the image we want to run.

## ⚠️ 6. Security Warning

This solution is **NOT SECURE** ‼️

* By forcing `TDS_Version=7.0`, you are disabling all modern encryption.
* All data sent over the network (including the **username and password**) is in **Clear Text**. This traffic can be easily "sniffed" and read by anyone on the same network.
* This workaround should **only** be used in a trusted, internal network as a last resort.

**The correct, permanent solution is to upgrade or patch the legacy SQL Server** to support modern security protocols (TLS 1.2). This would allow you to use a modern, secure driver like `ODBC Driver 18`.