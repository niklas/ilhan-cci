class Transactor
  def initialize(options={})
    @crunch   = options.fetch(:crunch)
    @sell_cci = options.fetch(:sell_cci) { 100 }
    @buy_cci  = options.fetch(:buy_cci) { -100 }
    @io       = options.fetch(:io) { $stderr }

    # number of shares we start of (1 or 0)
    @start_shares = options.fetch(:start_shares) { 0 }
    @start_money  = options.fetch(:start_money)  { 0 }.to_f

    @verbose    = options.fetch(:verbose) { false }
  end

  def run!
    @have = @start_shares
    @money = @start_money
    prev = 0

    @crunch.unpacked.each do |pup|
      puts_pupple(pup) if @verbose


      # oben nach unten durch upper cci
      if prev > @sell_cci && @sell_cci >= pup.cci
        sell(pup)
      end

      # von unten nach oben durch lower cci
      if prev < @buy_cci && @buy_cci <= pup.cci
        buy(pup)
      end

      prev = pup.cci
    end

    summary
  end

  private

  def puts_pupple(pup)
    @io.puts "%s\t€%.2f\t[CCI %.3f]" % [fmttime(pup.time), pup.price, pup.cci]
  end

  def sell(pup)
    if @have > 0
      @money += pup.price
      @have = 0
      @io.puts "SELL! (now have €%.2f)" % @money
      provision!
    else
      @io.puts "would sell, but don't have anything left"
    end
  end

  def buy(pup)
    if @have == 0
      @money -= pup.price
      @have = 1
      @io.puts "BUY! (now have €%.2f)" % @money
      provision!
    else
      @io.puts "would buy, but already have a share"
    end
  end

  def provision!
    @money -= 2.0 # provision
    @io.puts "Provision -2€! (now have €%.2f)" % @money
  end

  def summary
    @io.puts "Started with €%.2f and %i shares, now have €%.2f and %i shares" % [
                    @start_money,    @start_shares,     @money,    @have
    ]
  end

  def fmttime(time)
    time.strftime('%F %R')
  end
end
