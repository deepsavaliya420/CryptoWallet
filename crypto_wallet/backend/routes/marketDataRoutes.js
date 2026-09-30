const express = require("express");

const {
  getUsdRates
} = require("../services/marketDataService");

const router =
  express.Router();

router.get(
  "/rates",
  async (req, res) => {
    try {
      const marketData =
        await getUsdRates();

      return res.status(200).json({
        success: true,

        target: "USD",

        rates:
          marketData.rates,

        cryptoUsdPrices:
          marketData.cryptoUsdPrices,

        cached:
          marketData.cached,

        stale:
          marketData.stale,

        cachedAt:
          marketData.cachedAt
      });
    } catch (error) {
      console.error(
        "Market data error:",
        error
      );

      return res.status(500).json({
        success: false,

        message:
          error.message ||
          "Failed to fetch market data"
      });
    }
  }
);

module.exports = router;