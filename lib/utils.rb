require 'gnuplot'
require 'transactor'
class Utils
  def self.plot(crunch, meth, options={})
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |pl|

        pl.title( options.fetch(:title) { 'ein paar Werte' } )
        pl.xlabel "Time"
        pl.xdata 'time'
        pl.ylabel options.fetch(:label) { "Werte" }
        pl.timefmt '"%s"'

        pl.arbitrary_lines << 'set format x "%d.%b"'
        pl.arbitrary_lines << 'set xtics border mirror rotate'

        puppels = crunch.unpacked
        values = puppels.map(&meth)

        x = puppels.map(&:utc)

        pl.data << Gnuplot::DataSet.new( [x, values] ) do |ds|
          ds.with = "lines"
          ds.notitle
          ds.using = '1:2'
        end

        width = [ options.fetch(:width) { values.length / 3 }, 600].max
        height = [ options.fetch(:height) { 444 }, 400].max

        pl.terminal "png size #{width},#{height} linewidth 3 enhanced font 'Verdana,22'"
        file =  options.fetch(:output) { 'plot.png' }
        pl.output(file)

        if options[:verbose]
          $stderr.puts "written #{file}"
        end

        if options[:show_trade_numbers]
          puppels.each do |pup|
            if pup.action
              pl.arbitrary_lines << circle(pup, meth)
            end
          end
        end

        if meth == :cci
          upper, lower = options.fetch(:sell_cci), options.fetch(:buy_cci)
          f, l = puppels.first, puppels.last
          pl.arbitrary_lines << %Q~set arrow from "#{f.utc}",#{upper} to "#{l.utc}",#{upper} nohead fc rgb "red"~
          pl.arbitrary_lines << %Q~set arrow from "#{f.utc}",#{lower} to "#{l.utc}",#{lower} nohead fc rgb "green"~
        end

      end

    end
  end

  def self.transact(crunch, options={})
    Transactor.new(options.merge(crunch: crunch)).tap(&:run!)
  end

  def self.circle(pup, meth)
    x = pup.utc
    y = pup.send(meth).to_i
    color = case pup.action
            when :sell
              'blue'
            when :buy
              'orange'
            else
              'pink'
            end

    msg = %Q~set object circle at first "#{x}",#{y} size screen 0.005 fc rgb "#{color}"~

    if i = pup.trans_index
      msg += %Q~\nset label #{i} at "#{x}",#{y} "#{i}"~
    end

    msg
  end
end
