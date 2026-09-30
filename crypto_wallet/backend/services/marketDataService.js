const fs = require("fs");
const path = require("path");

const CACHE_FILE = path.join(__dirname, "market_cache.json");

// Coinlayer free plan has limited requests.
// Refresh at most once every 12 hours.
const CACHE_DURATION_MS = 12 * 60 * 60 * 1000;

const symbols = "BTC,ETH,SOL,TRX,USDT,USDC";

let memoryCache = null;

// ============================================================
// FIAT RATES
// Units of currency per 1 USD.
//
// Example:
// 1 USD = 96.18 INR
// 1 USD = 0.8821 EUR
// ============================================================

const FIAT_USD_RATES = {
  USD: 1.0,
  INR: 96.18,
  EUR: 0.8821,
  GBP: 0.7571,
  AED: 3.6725,
  JPY: 157.37
};

// ============================================================
// READ CACHE
// ============================================================

const readCache = () => {
  if (memoryCache) {
    return memoryCache;
  }

  try {
    if (!fs.existsSync(CACHE_FILE)) {
      return null;
    }

    const fileData = fs.readFileSync(
      CACHE_FILE,
      "utf8"
    );

    if (!fileData.trim()) {
      return null;
    }

    const parsed = JSON.parse(fileData);

    if (
      !parsed ||
      !parsed.rates ||
      typeof parsed.rates !== "object"
    ) {
      return null;
    }

    memoryCache = parsed;

    return memoryCache;
  } catch (error) {
    console.error(
      "Market cache read error:",
      error.message
    );

    return null;
  }
};

// ============================================================
// SAVE CACHE
// ============================================================

const saveCache = (data) => {
  try {
    memoryCache = data;

    fs.writeFileSync(
      CACHE_FILE,
      JSON.stringify(data, null, 2),
      "utf8"
    );
  } catch (error) {
    console.error(
      "Market cache save error:",
      error.message
    );

    memoryCache = data;
  }
};

// ============================================================
// FETCH COINLAYER
// ============================================================

const fetchCoinlayerRates = async () => {
  const apiKey =
    process.env.COINLAYER_API_KEY;

  if (!apiKey) {
    throw new Error(
      "COINLAYER_API_KEY is missing from .env"
    );
  }

  const url =
    `https://api.coinlayer.com/live?access_key=${encodeURIComponent(
      apiKey
    )}&symbols=${symbols}`;

  const response =
    await fetch(url);

  if (!response.ok) {
    throw new Error(
      `Coinlayer HTTP error: ${response.status} ${response.statusText}`
    );
  }

  const data =
    await response.json();

  if (data.success !== true) {
    throw new Error(
      data.error?.info ||
        "Coinlayer returned an unsuccessful response"
    );
  }

  return data;
};

// ============================================================
// GET COINLAYER RATES
// ============================================================

const getCoinlayerRates = async () => {
  const cached =
    readCache();

  // ----------------------------------------------------------
  // USE FRESH CACHE
  // ----------------------------------------------------------

  if (cached) {
    const cacheAge =
      Date.now() -
      cached.cachedAt;

    if (
      cacheAge <
      CACHE_DURATION_MS
    ) {
      return {
        success: true,
        target: "USD",
        rates: cached.rates,
        cached: true,
        cachedAt: cached.cachedAt
      };
    }
  }

  // ----------------------------------------------------------
  // CACHE EXPIRED
  // FETCH COINLAYER
  // ----------------------------------------------------------

  try {
    const data =
      await fetchCoinlayerRates();

    const rates =
      data.rates || {};

    const cacheData = {
      cachedAt: Date.now(),

      rates: {
        BTC:
          rates.BTC ?? null,

        ETH:
          rates.ETH ?? null,

        SOL:
          rates.SOL ?? null,

        TRX:
          rates.TRX ?? null,

        USDT:
          rates.USDT ?? null,

        USDC:
          rates.USDC ?? null
      }
    };

    saveCache(
      cacheData
    );

    return {
      success: true,
      target: "USD",
      rates:
        cacheData.rates,
      cached: false,
      cachedAt:
        cacheData.cachedAt
    };
  } catch (error) {
    console.error(
      "Coinlayer API error:",
      error.message
    );

    // --------------------------------------------------------
    // USE LAST SUCCESSFUL CACHE IF API FAILS
    // --------------------------------------------------------

    if (cached) {
      console.warn(
        "Using last successful market rates because Coinlayer is unavailable."
      );

      return {
        success: true,
        target: "USD",
        rates:
          cached.rates,
        cached: true,
        stale: true,
        cachedAt:
          cached.cachedAt
      };
    }

    throw error;
  }
};

// ============================================================
// BUILD COMMON USD RATE MAP
//
// Every value means:
//
// "How many units of this asset equal 1 USD"
//
// Examples:
//
// USD  = 1
// INR  = 96.18
// BTC  = 1 / BTC_USD
// ============================================================

const getUsdRates = async () => {
  const coinlayerData =
    await getCoinlayerRates();

  const cryptoRates =
    coinlayerData.rates || {};

  const usdRates = {
    USD:
      FIAT_USD_RATES.USD,

    INR:
      FIAT_USD_RATES.INR,

    EUR:
      FIAT_USD_RATES.EUR,

    GBP:
      FIAT_USD_RATES.GBP,

    AED:
      FIAT_USD_RATES.AED,

    JPY:
      FIAT_USD_RATES.JPY
  };

  // ----------------------------------------------------------
  // CRYPTO
  // ----------------------------------------------------------

  const cryptoSymbols = [
    "BTC",
    "ETH",
    "SOL",
    "TRX",
    "USDT",
    "USDC"
  ];

  for (
    const symbol of cryptoSymbols
  ) {
    const usdPrice =
      Number(
        cryptoRates[symbol]
      );

    if (
      Number.isFinite(
        usdPrice
      ) &&
      usdPrice > 0
    ) {
      usdRates[symbol] =
        1 / usdPrice;
    }
  }

  // ----------------------------------------------------------
  // USDC FALLBACK
  //
  // Coinlayer currently returns null for USDC.
  // USDC is treated as approximately 1 USD.
  // ----------------------------------------------------------

  if (
    usdRates.USDC === undefined
  ) {
    usdRates.USDC = 1.0;
  }

  // ----------------------------------------------------------
  // USDT FALLBACK
  // ----------------------------------------------------------

  if (
    usdRates.USDT === undefined
  ) {
    usdRates.USDT = 1.0;
  }

  return {
    success: true,

    target: "USD",

    rates: usdRates,

    cryptoUsdPrices: {
      BTC:
        cryptoRates.BTC ?? null,

      ETH:
        cryptoRates.ETH ?? null,

      SOL:
        cryptoRates.SOL ?? null,

      TRX:
        cryptoRates.TRX ?? null,

      USDT:
        cryptoRates.USDT ?? null,

      USDC:
        cryptoRates.USDC ?? 1.0
    },

    cached:
      coinlayerData.cached ??
      false,

    stale:
      coinlayerData.stale ??
      false,

    cachedAt:
      coinlayerData.cachedAt ??
      null
  };
};

// ============================================================
// SUPPORTED RATES
// ============================================================

const getSupportedCryptoRates =
  async () => {
    const data =
      await getCoinlayerRates();

    const rates =
      data.rates || {};

    return {
      BTC:
        rates.BTC ?? null,

      ETH:
        rates.ETH ?? null,

      SOL:
        rates.SOL ?? null,

      TRX:
        rates.TRX ?? null,

      USDT:
        rates.USDT ?? null,

      USDC:
        rates.USDC ?? 1.0
    };
  };

// ============================================================
// EXPORT
// ============================================================

module.exports = {
  getCoinlayerRates,
  getSupportedCryptoRates,
  getUsdRates,
  FIAT_USD_RATES
};