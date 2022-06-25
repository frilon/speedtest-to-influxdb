FROM python:3.10-slim-bullseye
LABEL maintainer="frilon" \
    description="Original by Aiden Gilmartin, forked by Breadlysm. Maintained by frilon"

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update 
RUN apt-get -q -y install --no-install-recommends apt-utils gnupg1 apt-transport-https dirmngr curl

# Install Speedtest
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
RUN apt-get update && apt-get -q -y install speedtest

# Clean up
RUN apt-get -q -y autoremove && apt-get -q -y clean 
RUN rm -rf /var/lib/apt/lists/*

# Copy and final setup
ADD . /app
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt 
COPY . .

# Excetution
CMD ["python", "main.py"]
