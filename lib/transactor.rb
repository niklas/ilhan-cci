class Transactor
  def initialize(options={})
    @crunch   = options.fetch(:crunch)
    @sell_cci = options.fetch(:sell_cci) { 100 }
    @buy_cci  = options.fetch(:buy_cci) { -100 }
    @io       = options.fetch(:io) { $stderr }

    # number of shares we start of (1 or 0)
    @start    = options.fetch(:start) { 1 }
  end

  def run!
    @have = @start
    prev = 0

    @crunch.unpacked.each do |pup|
      puts_balance(pup)


      if prev > @sell_cci && @sell_cci >= pup.cci
        sell(pup)
      end

      if prev < @buy_cci && @buy_cci <= pup.cci
        buy(pup)
      end

      prev = pup.cci
    end
  end

  private

  def puts_balance(pup)
    @io.puts "€%.2f   [CCI %.3f]" % [pup.t, pup.cci]
  end

  def sell(pup)
    @io.puts "SELL!"
  end

  def buy(pup)
    @io.puts "BUY!"
  end
end
