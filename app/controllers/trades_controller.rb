class TradesController < ApplicationController

  def index
    @trades = Trade.all
    respond_to do |format|
      format.html
      format.csv { send_data @trades.to_csv }
    end
  end

  def show
  end

  def check_trades
    x = 2400
    x.times do
      begin
        liqui_response = HTTParty.get('https://api.liqui.io/api/3/depth/eth_usdt?limit=10')
      rescue Errno::ETIMEDOUT, Net::OpenTimeout, Errno::ECONNRESET, OpenSSL::SSL::SSLError
        puts "liqui rescue"
        retry
      end
      begin
        poloniex_response = HTTParty.get('https://poloniex.com/public?command=returnOrderBook&currencyPair=USDT_ETH&depth=10')
      rescue Errno::ETIMEDOUT, Net::OpenTimeout, Errno::ECONNRESET, OpenSSL::SSL::SSLError
        puts "poloniex rescue"
        retry
      end
      puts "///// #{x} ///////"
      x -= 1;
      Trade.check_trades(liqui_response, poloniex_response)

      sleep(rand(5..9))
    end
  end
end
