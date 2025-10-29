# ใช้ Python 3.11-slim (Debian Bookworm) เป็นเบส
FROM python:3.11-slim

# ตั้งค่าเพื่อป้องกันไม่ให้ apt-get ถามคำถามระหว่างติดตั้ง
ENV DEBIAN_FRONTEND=noninteractive

# ติดตั้ง Dependency ที่จำเป็นทั้งหมด
RUN apt-get update && \
    apt-get install -y \
    unixodbc \
    unixodbc-dev \
    freetds-bin \
    tdsodbc \
    && rm -rf /var/lib/apt/lists/*

# ติดตั้ง pyodbc
RUN pip install pyodbc python-dotenv

# คัดลอกไฟล์ Config ที่เราสร้างขึ้น ไปยังตำแหน่งที่ถูกต้องใน Image
# COPY freetds.conf /etc/freetds/freetds.conf
COPY odbcinst.ini /etc/odbcinst.ini

COPY .env .

# คัดลอกสคริปต์ Python ของเราเข้าไป
COPY test.py .

# คำสั่งที่จะรันเมื่อ Container เริ่มทำงาน
CMD [ "python", "test.py" ]