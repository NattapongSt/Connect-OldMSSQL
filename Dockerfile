# Base image
FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

# install Dependency 
RUN apt-get update && \
    apt-get install -y \
    unixodbc \
    unixodbc-dev \
    freetds-bin \
    tdsodbc \
    && rm -rf /var/lib/apt/lists/*

# install Python packages
RUN pip install pyodbc python-dotenv

# copy odbcinst.ini configuration file
COPY odbcinst.ini /etc/odbcinst.ini

COPY .env .

# copy Python script
COPY test.py .

# set the default command to run the Python script
CMD [ "python", "test.py" ]