const Swap = require("../models/Swap");
const Wallet = require("../models/Wallet");

const {
  getUsdRates
} = require("../services/marketDataService");

const SUPPORTED_ASSETS = [
  "USD",
  "INR",
  "EUR",
  "GBP",
  "AED",
  "JPY",
  "USDT",
  "USDC",
  "BTC",
  "ETH",
  "SOL",
  "TRX"
];

const SUPPORTED_NETWORKS = [
  "TRC-20",
  "ERC-20",
  "Solana",
  "BEP-20",
  "TRON",
  "Bitcoin"
];

const SWAP_FEE_PERCENT = 0.0;

const sourceAssets = [
  "USD",
  "ETH",
  "USDT",
  "USDC",
  "SOL",
  "TRX",
  "BTC"
];

const generateSwapId = () => {
  return `SW-${Date.now()}-${Math.random()
    .toString(36)
    .substring(2, 8)
    .toUpperCase()}`;
};

// ============================================================
// GET USD VALUE
//
// usdRate means:
// how many units of an asset equal 1 USD.
//
// Example:
//
// INR = 96.18
// 96.18 INR / 96.18 = 1 USD
//
// BTC = 1 / 83318.25
// 1 BTC / (1 / 83318.25) = 83318.25 USD
// ============================================================

const getUsdValue = (
  amount,
  asset,
  usdRates
) => {
  const rate =
    usdRates[asset];

  if (
    rate === undefined ||
    !Number.isFinite(rate) ||
    rate <= 0
  ) {
    throw new Error(
      `Unsupported market rate for currency: ${asset}`
    );
  }

  return amount / rate;
};

// ============================================================
// EXCHANGE RATE
//
// Returns destination units received for 1 source unit.
//
// Example:
//
// BTC -> USD
//
// USD rate:
// BTC = 1 / 83318.25
// USD = 1
//
// 1 / BTC_RATE
// = 83318.25 USD
// ============================================================

const getExchangeRate = (
  fromAsset,
  toAsset,
  usdRates
) => {
  const fromRate =
    usdRates[fromAsset];

  const toRate =
    usdRates[toAsset];

  if (
    fromRate === undefined ||
    !Number.isFinite(fromRate) ||
    fromRate <= 0
  ) {
    throw new Error(
      `Unsupported source market rate: ${fromAsset}`
    );
  }

  if (
    toRate === undefined ||
    !Number.isFinite(toRate) ||
    toRate <= 0
  ) {
    throw new Error(
      `Unsupported destination market rate: ${toAsset}`
    );
  }

  return toRate / fromRate;
};

// ============================================================
// RESTORE BALANCES
// ============================================================

const restoreBalances = (
  wallet,
  balances
) => {
  wallet.balances.USD =
    balances.USD;

  wallet.balances.ETH =
    balances.ETH;

  wallet.balances.USDT =
    balances.USDT;

  wallet.balances.USDC =
    balances.USDC;

  wallet.balances.SOL =
    balances.SOL;

  wallet.balances.TRX =
    balances.TRX;

  wallet.balances.BTC =
    balances.BTC;

  wallet.balances.INR =
    balances.INR;

  wallet.balances.EUR =
    balances.EUR;

  wallet.balances.GBP =
    balances.GBP;

  wallet.balances.AED =
    balances.AED;

  wallet.balances.JPY =
    balances.JPY;
};

// ============================================================
// GET SWAPS
// ============================================================

const getSwaps =
  async (req, res) => {
    try {
      const swaps =
        await Swap.find({
          userId:
            req.user.userId
        }).sort({
          createdAt: -1
        });

      return res.status(200).json({
        success: true,
        swaps
      });
    } catch (error) {
      console.error(
        "Get swaps error:",
        error
      );

      return res.status(500).json({
        success: false,
        message:
          "Server error while fetching swaps"
      });
    }
  };

// ============================================================
// CREATE SWAP
// ============================================================

const createSwap =
  async (req, res) => {
    let wallet = null;
    let originalBalances = null;
    let walletChanged = false;

    try {
      const {
        fromAsset,
        fromNetwork,
        toAsset,
        toNetwork,
        fromAmount
      } = req.body;

      // ------------------------------------------------------
      // REQUIRED FIELDS
      // ------------------------------------------------------

      if (
        !fromAsset ||
        !fromNetwork ||
        !toAsset ||
        !toNetwork ||
        fromAmount === undefined
      ) {
        return res.status(400).json({
          success: false,
          message:
            "From asset, from network, to asset, to network and from amount are required"
        });
      }

      // ------------------------------------------------------
      // NORMALIZE
      // ------------------------------------------------------

      const normalizedFromAsset =
        fromAsset
          .toString()
          .trim()
          .toUpperCase();

      const normalizedToAsset =
        toAsset
          .toString()
          .trim()
          .toUpperCase();

      const normalizedFromNetwork =
        fromNetwork
          .toString()
          .trim();

      const normalizedToNetwork =
        toNetwork
          .toString()
          .trim();

      const numericFromAmount =
        Number(fromAmount);

      // ------------------------------------------------------
      // VALIDATE ASSETS
      // ------------------------------------------------------

      if (
        !SUPPORTED_ASSETS.includes(
          normalizedFromAsset
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            `Unsupported source asset: ${normalizedFromAsset}`
        });
      }

      if (
        !SUPPORTED_ASSETS.includes(
          normalizedToAsset
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            `Unsupported destination asset: ${normalizedToAsset}`
        });
      }

      // ------------------------------------------------------
      // VALIDATE NETWORKS
      // ------------------------------------------------------

      if (
        !SUPPORTED_NETWORKS.includes(
          normalizedFromNetwork
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            `Unsupported source network: ${normalizedFromNetwork}`
        });
      }

      if (
        !SUPPORTED_NETWORKS.includes(
          normalizedToNetwork
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            `Unsupported destination network: ${normalizedToNetwork}`
        });
      }

      // ------------------------------------------------------
      // SAME ASSET + SAME NETWORK
      // ------------------------------------------------------

      if (
        normalizedFromAsset ===
          normalizedToAsset &&
        normalizedFromNetwork ===
          normalizedToNetwork
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Source and destination cannot be the same."
        });
      }

      // ------------------------------------------------------
      // VALIDATE AMOUNT
      // ------------------------------------------------------

      if (
        !Number.isFinite(
          numericFromAmount
        ) ||
        numericFromAmount <= 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "From amount must be a valid positive number"
        });
      }

      // ------------------------------------------------------
      // GET LIVE MARKET RATES
      //
      // This uses the backend cache.
      // Coinlayer is not called every swap.
      // ------------------------------------------------------

      const marketData =
        await getUsdRates();

      const usdRates =
        marketData.rates;

      // ------------------------------------------------------
      // VALIDATE MARKET RATES
      // ------------------------------------------------------

      if (
        usdRates[
          normalizedFromAsset
        ] === undefined
      ) {
        return res.status(503).json({
          success: false,
          message:
            `Live market rate unavailable for ${normalizedFromAsset}`
        });
      }

      if (
        usdRates[
          normalizedToAsset
        ] === undefined
      ) {
        return res.status(503).json({
          success: false,
          message:
            `Live market rate unavailable for ${normalizedToAsset}`
        });
      }

      // ------------------------------------------------------
      // CALCULATE LIVE RATE
      // ------------------------------------------------------

      const rate =
        getExchangeRate(
          normalizedFromAsset,
          normalizedToAsset,
          usdRates
        );

      // ------------------------------------------------------
      // CALCULATE FEE
      // ------------------------------------------------------

      const fee =
        numericFromAmount *
        (SWAP_FEE_PERCENT / 100);

      const amountAfterFee =
        numericFromAmount -
        fee;

      // ------------------------------------------------------
      // CALCULATE RECEIVED AMOUNT
      // ------------------------------------------------------

      const received =
        amountAfterFee *
        rate;

      if (
        !Number.isFinite(received) ||
        received < 0
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Unable to calculate swap amount"
        });
      }

      // ------------------------------------------------------
      // GET WALLET
      // ------------------------------------------------------

      wallet =
        await Wallet.findOne({
          userId:
            req.user.userId
        });

      if (!wallet) {
        return res.status(404).json({
          success: false,
          message:
            "Wallet not found"
        });
      }

      // ------------------------------------------------------
      // SAVE ORIGINAL BALANCES
      // ------------------------------------------------------

      originalBalances = {
        USD:
          wallet.balances.USD ?? 0,

        ETH:
          wallet.balances.ETH ?? 0,

        USDT:
          wallet.balances.USDT ?? 0,

        USDC:
          wallet.balances.USDC ?? 0,

        SOL:
          wallet.balances.SOL ?? 0,

        TRX:
          wallet.balances.TRX ?? 0,

        BTC:
          wallet.balances.BTC ?? 0,

        INR:
          wallet.balances.INR ?? 0,

        EUR:
          wallet.balances.EUR ?? 0,

        GBP:
          wallet.balances.GBP ?? 0,

        AED:
          wallet.balances.AED ?? 0,

        JPY:
          wallet.balances.JPY ?? 0
      };

      // ======================================================
      // USD SOURCE
      //
      // Preserve existing project behavior:
      // USD represents the complete USD-equivalent
      // portfolio and consumes assets in this order.
      // ======================================================

      if (
        normalizedFromAsset === "USD"
      ) {
        let remainingUsd =
          numericFromAmount;

        for (
          const asset of sourceAssets
        ) {
          if (
            remainingUsd <= 0
          ) {
            break;
          }

          const balance =
            Number(
              wallet.balances[
                asset
              ] ?? 0
            );

          if (
            !Number.isFinite(
              balance
            ) ||
            balance <= 0
          ) {
            continue;
          }

          const assetUsdValue =
            getUsdValue(
              balance,
              asset,
              usdRates
            );

          if (
            assetUsdValue <= 0
          ) {
            continue;
          }

          if (
            assetUsdValue <=
            remainingUsd
          ) {
            wallet.balances[
              asset
            ] = 0;

            remainingUsd -=
              assetUsdValue;
          } else {
            const amountToRemove =
              remainingUsd *
              usdRates[asset];

            wallet.balances[
              asset
            ] =
              balance -
              amountToRemove;

            remainingUsd = 0;
          }
        }

        if (
          remainingUsd >
          0.00000001
        ) {
          return res.status(400).json({
            success: false,
            message:
              "Insufficient wallet balance for this swap"
          });
        }
      } else {
        // ----------------------------------------------------
        // NORMAL SOURCE ASSET
        // ----------------------------------------------------

        const sourceBalance =
          Number(
            wallet.balances[
              normalizedFromAsset
            ] ?? 0
          );

        if (
          sourceBalance <
          numericFromAmount
        ) {
          return res.status(400).json({
            success: false,
            message:
              `Insufficient ${normalizedFromAsset} balance`
          });
        }

        wallet.balances[
          normalizedFromAsset
        ] =
          sourceBalance -
          numericFromAmount;
      }

      // ------------------------------------------------------
      // ADD DESTINATION AMOUNT
      // ------------------------------------------------------

      wallet.balances[
        normalizedToAsset
      ] =
        Number(
          wallet.balances[
            normalizedToAsset
          ] ?? 0
        ) +
        received;

      wallet.updatedAt =
        new Date();

      // ------------------------------------------------------
      // SAVE WALLET
      // ------------------------------------------------------

      await wallet.save();

      walletChanged = true;

      // ------------------------------------------------------
      // CREATE SWAP
      // ------------------------------------------------------

      const swap =
        await Swap.create({
          swapId:
            generateSwapId(),

          userId:
            req.user.userId,

          fromAsset:
            normalizedFromAsset,

          fromNetwork:
            normalizedFromNetwork,

          toAsset:
            normalizedToAsset,

          toNetwork:
            normalizedToNetwork,

          fromAmount:
            numericFromAmount,

          toAmount:
            received,

          rate:
            rate,

          status:
            "completed"
        });

      // ------------------------------------------------------
      // RESPONSE
      // ------------------------------------------------------

      return res.status(201).json({
        success: true,

        message:
          "Swap created successfully",

        swap,

        wallet,

        marketData: {
          cached:
            marketData.cached,

          stale:
            marketData.stale,

          cachedAt:
            marketData.cachedAt
        }
      });
    } catch (error) {
      console.error(
        "Create swap error:",
        error
      );

      // ------------------------------------------------------
      // ROLLBACK WALLET
      // ------------------------------------------------------

      if (
        walletChanged &&
        wallet &&
        originalBalances
      ) {
        try {
          restoreBalances(
            wallet,
            originalBalances
          );

          wallet.updatedAt =
            new Date();

          await wallet.save();
        } catch (
          rollbackError
        ) {
          console.error(
            "Swap wallet rollback error:",
            rollbackError
          );
        }
      }

      return res.status(500).json({
        success: false,
        message:
          error.message ||
          "Server error while creating swap"
      });
    }
  };

module.exports = {
  getSwaps,
  createSwap
};