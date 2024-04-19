# Cardano JS SDK | Docker Composer Environment Variables

This folder holds environment variable files for various Docker composer setups. The `.env` files are referenced in the `../package.json` file.
`schedules.json` file contains configuration for pg-boss schedules. The file can be copy-pasted separately for each network and each network can use it's own file specified in `.env.*`.
`schedules.json` file is attached as a volume while running our Docker Compose setup in `../docker-compose.yml`.
