class Transactor
  attr_reader :sell_cci, :buy_cci
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


  # 1. position ist 
  #   a) leerverkauf bei durchquerrung von upper von oben nach unten
  #   b) kauf bei durchquerung von lower von unten oder oben
  #

  def run!
    @money = @start_money
    @position = nil
    prev = nil
    @before = nil
    @transaction_index = 0

    @crunch.unpacked.each do |pup|
      puts_pupple(pup) if @verbose

      if prev
        case @position
        when :short  # \
             # from above through lower => WIN
          if (prev.cci > @buy_cci && @buy_cci >= pup.cci) ||
             # back to upper  => LOOSE
             (prev.cci < @sell_cci && @sell_cci <= pup.cci)
            short_buy pup
          end
        when :long   # /
             # from below through upper => WIN
          if (prev.cci < @sell_cci && @sell_cci <= pup.cci) ||
             # back to lower => LOOSE
             (prev.cci > @buy_cci && @buy_cci >= pup.cci)
            long_sell pup
          end
        when nil # must wait for an intrusion from outside into cci-band
          # from above
          if prev.cci > @sell_cci && @sell_cci >= pup.cci
            short_sell pup
          end
          # from below
          if prev.cci < @buy_cci && @buy_cci <= pup.cci
            long_buy pup
          end
        else
          raise "unknown position #{@position}"
        end
      end

      prev = pup
    end

    summary
  end

  private

  def puts_pupple(pup)
    @io.puts "%s\t€%.2f\t[CCI %.3f]" % [fmttime(pup.time), pup.price, pup.cci]
  end

  def short_sell(pup)
    @before = pup
    sell pup, :short
  end

  def short_buy(pup)
    buy pup, nil
    profit! pup, 'short'
    @before = nil
  end

  def long_sell(pup)
    sell pup, nil
    profit! pup, 'long'
    @before = nil
  end

  def long_buy(pup)
    @before = pup
    buy pup, :long
  end

  def sell(pup, pos)
    @money += pup.price
    @position = pos
    #@io.puts "#{fmttime(pup.time)} SELL! (now have €%.2f)" % @money
    pup.action = :sell
    provision!
  end

  def buy(pup, pos)
    @money -= pup.price
    @position = pos
    #@io.puts "#{fmttime(pup.time)} BUY! (now have €%.2f)" % @money
    pup.action = :buy
    provision!
  end

  def provision!
    @money -= 2.0 # provision
  end

  def profit!(pup, pos)
    @transaction_index += 1
    i = pup.trans_index = @transaction_index

    diff = pup.price - @before.price

    # bei Leerverkäufe ist kauf/verkauf vertauscht
    if pos == 'short'
      diff = -diff
    end

    word = diff < 0 ? 'Verlust' : 'Gewinn'


    @io.puts( %Q~(%i) Eröffnungskurs %.2f Datum %s %s~ %
             [i, @before.price, fmttime(@before.time), pos] )
    @io.puts( %Q~     Schlusskurs %.2f Enddatum %s~ %
             [ pup.price, pup.time ])
    @io.puts( %Q~     4.00 +- %s %.2f = %.2f (Balance)~ %
             [ word, diff.abs, @money ])
    @io.puts
  end

  def summary
    @io.puts "Started with €%.2f and %i shares, now have €%.2f" % [
                    @start_money,    @start_shares,     @money
    ]
  end

  def fmttime(time)
    time.strftime('%F %R')
  end
end
