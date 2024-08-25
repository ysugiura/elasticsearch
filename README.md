# My Custom Elasticsearch Setup

This repository contains a Docker setup for running Elasticsearch with Nginx and the Kuromoji plugin. This setup is designed to be lightweight and easy to deploy, with all dependencies and configurations managed within the Docker container.

## Features

- **Elasticsearch 1.3.9** with **Kuromoji plugin** for Japanese language analysis.
- **Nginx** for reverse proxy.
- **Supervisor** for managing multiple processes inside the container.
- Optional **HTTP basic authentication**.

## Prerequisites

- Docker installed on your machine.

## Getting Started

### 1. Build the Docker Image

Clone the repository and navigate to the directory containing the Dockerfile. Then run the following command to build the Docker image:

```bash
docker build -t my-custom-elasticsearch .
```

This will create a Docker image named `my-custom-elasticsearch`.

### 2. Run the Container

Start the container using the following command:

```bash
docker run -d -p 9200:9200 --name my-elasticsearch-container my-custom-elasticsearch
```

- `-d` runs the container in detached mode.
- `-p 9200:9200` maps port 9200 on the host to port 9200 on the container.
- `--name my-elasticsearch-container` gives the container a custom name.

### 3. Verify the Setup

To verify that Elasticsearch is running, open your browser and navigate to:

```
http://localhost:9200
```

You can also use `curl`:

```bash
curl http://localhost:9200
```

### 4. Running Elasticsearch with HTTP Basic Authentication

You can enable HTTP basic authentication by setting the environment variables `ELASTICSEARCH_USER` and `ELASTICSEARCH_PASS` when running the container:

```bash
docker run -d -p 9200:9200 \
  -e ELASTICSEARCH_USER=admin \
  -e ELASTICSEARCH_PASS=mypass \
  --name my-elasticsearch-container \
  my-custom-elasticsearch
```

Now, connect to Elasticsearch using:

```bash
curl admin:mypass@127.0.0.1:9200
```

### 5. Check Installed Plugins

Verify that the Kuromoji plugin is installed by running:

```bash
curl -X GET "http://localhost:9200/_cat/plugins?v"
```

You should see `elasticsearch-analysis-kuromoji` listed in the output.

## Customization

- **Environment Variables:** You can set custom Elasticsearch credentials by modifying the `ENV` variables in the Dockerfile.
- **Configuration Files:** The Nginx configuration can be adjusted by editing the `nginx_default` file, and the supervisor configuration is in the `supervisord.conf` file.

## Stopping and Removing the Container

To stop the running container:

```bash
docker stop my-elasticsearch-container
```

To remove the container:

```bash
docker rm my-elasticsearch-container
```

## About This Fork

This Docker setup is based on the original `tutum-docker-elasticsearch` project but includes additional features such as the Kuromoji plugin for Elasticsearch, Nginx as a reverse proxy, and Supervisor to manage multiple processes.

## Troubleshooting

If you encounter any issues, you can check the logs for more information:

```bash
docker logs my-elasticsearch-container
```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes or improvements.

## License

This project is licensed under the Apache-2.0 License. See the [LICENSE](LICENSE) file for details.

## Maintainer

This project is maintained by [Yuichiro Sugiura](mailto:yuichirol@activewave.com).
