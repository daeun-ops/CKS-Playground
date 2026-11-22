FROM ubuntu:16.04
RUN apt-get update && apt-get install -y curl
COPY app.tar.gz /app/
USER nobody
CMD ["sleep", "3600"]
