require 'gnuplot'
class Utils
  def self.plot(crunch, meth, options={})
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |pl|

        pl.title( options.fetch(:title) { 'ein paar Werte' } )
        pl.xlabel "Time"
        pl.xdata 'time'
        pl.ylabel "c"
        pl.timefmt '"%s"'

        pl.arbitrary_lines << 'set format x "%Y-%m-%d %H:%M"'
        pl.arbitrary_lines << 'set xtics border mirror rotate by 80'

        puppels = crunch.unpacked
        values = puppels.map(&meth)

        x = puppels.map(&:time)

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

      end

    end
  end
end
