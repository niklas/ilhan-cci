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

        pl.arbitrary_lines << 'set format x "%Y-%m-%d %H:%M"'
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

        pl.terminal "png size #{width},#{height}"
        file =  options.fetch(:output) { 'plot.png' }
        pl.output(file)

        if options[:verbose]
          $stderr.puts "written #{file}"
        end

        puppels.each do |pup|
          if pup.action
            pl.arbitrary_lines << circle(pup, meth)
          end
        end

      end

    end
  end

  def self.transact(crunch, options={})
    Transactor.new(options.merge(crunch: crunch)).run!
  end

  def self.circle(pup, meth)
    x = pup.utc
    y = pup.send(meth).to_i
    color = case pup.action
            when :sell
              'light-blue'
            when :buy
              'orange'
            else
              'pink'
            end
    %Q~set object circle at first "#{x}",#{y} size screen 0.01 fc rgb "#{color}"~
  end
end
