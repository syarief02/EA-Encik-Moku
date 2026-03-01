# 🏯 EA Encik Moku v1.06

> **Ichimoku Kinko Hyo trend-following EA** — Trades above the cloud (buy) and below the cloud (sell), confirmed by RSI and Stochastic across up to 4 timeframes.

[![MT4](https://img.shields.io/badge/Platform-MT4-blue)](#) [![MT5](https://img.shields.io/badge/Platform-MT5-green)](#) [![License](https://img.shields.io/badge/License-Free-brightgreen)](#)

---

## 📖 Overview

EA Encik Moku is a **single-entry, trend-following** Expert Advisor built around the **Ichimoku Kinko Hyo** indicator system. It buys when price is above the Kumo (cloud) and sells when price is below it, with additional confirmation from RSI and Stochastic oscillators.

The EA supports **5 Multi-Timeframe (MTF) modes** that require all 4 configured timeframes to agree on direction before entering a trade — dramatically reducing false signals.

**"Ayuh bangkit darah pahlawan. Pantang undur sebelum MC! Agi idup, agi ngelaban!"**

---

## 🎯 Strategy

### Entry Conditions

**Buy Signal (all must be true on each timeframe):**
| Indicator | Condition |
|-----------|-----------|
| **Ichimoku** | Tenkan-sen > Senkou Span A AND Tenkan-sen > Senkou Span B AND Tenkan-sen > Kijun-sen |
| **RSI(14)** | RSI < 70 (not overbought) |
| **Stochastic(5,3,3)** | Main < 80 AND Main > Signal (bullish crossover) |

**Sell Signal (all must be true on each timeframe):**
| Indicator | Condition |
|-----------|-----------|
| **Ichimoku** | Tenkan-sen < Senkou Span A AND Tenkan-sen < Senkou Span B AND Tenkan-sen < Kijun-sen |
| **RSI(14)** | RSI > 30 (not oversold) |
| **Stochastic(5,3,3)** | Main > 20 AND Main < Signal (bearish crossover) |

### Multi-Timeframe Modes

| Mode | Name | Timeframes | Best For |
|------|------|------------|----------|
| AA | No MTF | Current chart TF only | Quick testing |
| BB | Scalperz | H1 → M15 → M5 → M1 | Scalping |
| CC | Intradayz | H4 → H1 → M15 → M5 | Intraday (default) |
| DD | Swingz | D1 → H4 → H1 → M15 | Swing trading |
| EE | Positionz | W1 → D1 → H4 → H1 | Position trading |

### Exit Conditions

- **Take Profit / Stop Loss** — Fixed pip-based targets
- **Trailing Stop** — Locks in profit as trade moves favorably
- **Close on Reversal** — Automatically closes opposite trades when a new signal appears

---

## ⚙️ Settings

### Core Settings
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| Lots | double | 0.01 | Base lot size for each trade |
| Takeprofit_Pips | int | 50 | Take profit distance in pips |
| Stoploss_Pips | int | 50 | Stop loss distance in pips |
| Close_On_Reversal | bool | true | Close opposite trades on reversal signal |
| MultiTimeFrame_Mode | enum | CC | Which MTF mode to use |
| AutoCompounding_Mode | enum | A (Off) | Auto lot-sizing based on equity |
| ECN_Broker | bool | false | Send order without SL/TP first, then modify |

### Trailing Stop
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| TrailingStop | bool | false | Enable/disable trailing stop |
| TrailingStop_Pips | int | 25 | Distance from current price |
| TrailingGap_Pips | int | 7 | Minimum pip gap before trail activates |
| NewTakeProfit_Pips | int | 0 | New TP after trailing (0 = keep original) |

### Martingale / Lot Management
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| LotMultiplierOnLoss | double | 2.25 | Multiply lot size after losing trade |
| LotsMultiplierOnProfit | double | 1 | Multiply lot size after winning trade |
| MaxLots | double | 999 | Maximum allowed lot size (safety cap) |
| LotsResetOnProfit | bool | true | Reset to base lot after win |
| LotsResetOnLoss | bool | false | Reset to base lot after loss |

### Auto-Compounding Modes
| Mode | Formula |
|------|---------|
| A (Off) | EntryLot = Lots |
| B (Very High Risk) | EntryLot = Lots / 50 × Equity |
| C (High Risk) | EntryLot = Lots / 100 × Equity |
| D (Medium Risk) | EntryLot = Lots / 1,000 × Equity |
| E (Low Risk) | EntryLot = Lots / 10,000 × Equity |
| F (Very Low Risk) | EntryLot = Lots / 100,000 × Equity |

### Trading Time
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| Monday – Sunday | bool | All true | Enable/disable trading on specific days |
| HoursFrom / HoursTo | int | 0 / 24 | Trading hours (local time, supports overnight) |

### Notifications
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| Email_Notification | bool | true | Send trade signals via email |
| Alert_Notification | bool | false | Show popup alerts |
| MT4/MT5_Messages | bool | true | Send push notifications to mobile app |

---

## 📥 Installation

### MT4
1. Download the `.ex4` file from the [Releases](../../releases) or from the repository
2. Open MetaTrader 4 → `File` → `Open Data Folder` → navigate to `MQL4\Experts\`
3. Place the `.ex4` file in the `Experts` folder
4. Press `Ctrl+N` in MT4 → right-click `Expert Advisors` → `Refresh`
5. Drag the EA onto a chart of your chosen trending pair

### MT5
1. Download the `.ex5` file
2. Open MetaTrader 5 → `File` → `Open Data Folder` → navigate to `MQL5\Experts\`
3. Place the `.ex5` file in the `Experts` folder
4. Press `Ctrl+N` in MT5 → right-click `Expert Advisors` → `Refresh`
5. Drag the EA onto a chart

### Configuration Tips
- **Trending pairs work best**: EURUSD, GBPUSD, USDJPY, XAUUSD, indices
- **Start with default settings** on a demo account
- **Mode CC (Intradayz)** is recommended for most traders
- **Always set MaxLots** to a reasonable cap when using martingale
- **Enable AutoTrading** (green button in MT4/MT5 toolbar)

---

## ⚠️ Risk Warning

- **Martingale carries significant risk.** The default 2.25× multiplier means after 3 consecutive losses, your lot is ~11× base size.
- **Always test on demo** before going live.
- **Past performance does not guarantee future results.**
- **Trade only what you can afford to lose.**

---

## 📋 Changelog

### v1.06
- Extended expiration to March 28, 2026
- Added MT5 version with CTrade and indicator handles
- Fixed MagicNumber (now 260328 instead of hardcoded 1)
- Added proper array-based authorization system
- Added chart comment display with account info
- Added CountBuy/CountSell utilities
- Made ECN_Broker configurable as input parameter
- Removed obfuscated code protection
- Consolidated ~80 chain functions into clean helpers (MT5)
- Improved code readability and maintainability

---

## 🔗 Links

- 🌐 **Website**: [EA Budak Ubat](https://ea-budak-ubat.vercel.app)
- 💬 **Telegram**: [t.me/EAEncikMoku](https://t.me/EAEncikMoku)
- 📘 **Facebook**: [m.me/EABudakUbat](https://m.me/EABudakUbat)
- 📞 **Contact**: +60194961568 (Budak Ubat)

---

**Open Source · Free to Use · Expires 2026-03-28 · By Syarief Azman**
