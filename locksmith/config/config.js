const urlParser = require('url')

const config = {
  database: {
    dialect: 'postgres', // sequelize v4 needs this
  },
  stripeSecret: process.env.STRIPE_SECRET,
  web3ProviderHost: process.env.WEB3_PROVIDER_HOST,
  unlockContractAddress: process.env.UNLOCK_CONTRACT_ADDRESS,
  defaultNetwork: process.env.DEFAULT_NETWORK,
  purchaserCredentials:
    process.env.PURCHASER_CREDENTIALS ||
    '0x08491b7e20566b728ce21a07c88b12ed8b785b3826df93a7baceb21ddacf8b61',
  graphQLBaseURL: process.env.GRAPHQL_BASE_URL,
  metadataHost: process.env.METADATA_HOST,
  logging: false,
}

// Heroku sets DATABASE_URL
if (process.env.DATABASE_URL) {
  const databaseConfigUrl = new urlParser.URL(process.env.DATABASE_URL)
  config.database.username = databaseConfigUrl.username
  config.database.password = databaseConfigUrl.password
  config.database.host = databaseConfigUrl.hostname
  config.database.database = databaseConfigUrl.pathname.substring(1)

  // Heroku needs this:
  config.database.ssl = true
  config.database.dialectOptions = {
    ssl: {
      require: true,
      rejectUnauthorized: false,
    },
  }
} else {
  config.database.username = process.env.DB_USERNAME
  config.database.password = process.env.DB_PASSWORD
  config.database.database = process.env.DB_NAME
  config.database.host = process.env.DB_HOSTNAME
  config.database.options = {
    dialect: 'postgres',
  }
}

module.exports = config
