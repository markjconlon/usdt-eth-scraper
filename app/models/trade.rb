class Trade < ApplicationRecord
  require "csv"

  def self.check_trades(liqui_response, poloniex_response)

    # calls to the apis are made on in the controller and passed down
    return if liqui_response["success"] == 0
    return if poloniex_response.parsed_response == 0
    liqui_sell = liqui_response["eth_usdt"]["asks"][0]
    liqui_buy = liqui_response["eth_usdt"]["bids"][0]
    poloniex_sell = [(poloniex_response["asks"][0][0]).to_f, poloniex_response["asks"][0][1]]
    poloniex_buy = [(poloniex_response["bids"][0][0]).to_f, poloniex_response["bids"][0][1]]

    top_trades = { sells:
      { sell_on_liqui: liqui_buy,
        sell_on_poloniex: poloniex_buy },
        buys:
        { buy_on_liqui: liqui_sell,
          buy_on_poloniex: poloniex_sell}
        }
    profitable_trade(top_trades)
  end

  def self.find_highest_sell(sells)
    (sells.max_by{|k,v| v})
  end

  def self.find_lowest_buy(buys)
    (buys.min_by{|k,v| v})
  end

  def self.profitable_trade(trades)
    # determines which exchange has the highest sell and lowest buy
    # then we check if the difference is in our margin
    high_sell = find_highest_sell(trades[:sells])
    low_buy = find_lowest_buy(trades[:buys])
    rate_above =  high_sell[1][0] - (low_buy[1][0] * ((1 + 0.0025)/ ( 1 - 0.0026)) + (25+0.01*low_buy[1][0])/8)
    puts rate_above
    if high_sell[1][0] >= (low_buy[1][0] * ((1 + 0.0025)/ ( 1 - 0.0026)) + (25+0.01*low_buy[1][0])/8)
      # if there is an opportunity we check to see which one has the lowest volume
      # this becomes the highest amount we can buy/sell
      find_highest_amount([high_sell, low_buy, rate_above])
    end
  end

  def self.find_highest_amount(data)
    # data is in a format of [sellexchange: [rate, eth_amount], buyexchang: [rate, eth_amount]]
    if (data[0][1][1] < data[1][1][1])
      Trade.create(sell_exchange: data[0][0], sell_rate: data[0][1][0], buy_exchange: data[1][0], buy_rate: data[1][1][0], amount: data[0][1][1], rate_above_break_even: data[2])
    else
      Trade.create(sell_exchange: data[0][0], sell_rate: data[0][1][0], buy_exchange: data[1][0], buy_rate: data[1][1][0], amount: data[1][1][1], rate_above_break_even: data[2])
    end
  end

  def self.to_csv(options={})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |trade|
        csv << trade.attributes.values
      end
    end
  end
end
