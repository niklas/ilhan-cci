require 'gnuplot'
class Utils
  def self.plot(values, options={})
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |pl|

        pl.title( options.fetch(:title) { 'ein paar Werte' } )
        pl.xlabel "i"
        pl.ylabel "c"

        x = (0...values.length).collect { |v| v.to_f }

        pl.data << Gnuplot::DataSet.new( [x, values] ) do |ds|
          ds.with = "lines"
          ds.notitle
        end

        width = options.fetch(:width) { values.length / 3 }
        height = options.fetch(:height) { 444 }

        pl.terminal "png size #{width},#{height}"
        pl.output( options.fetch(:output) { 'plot.png' } )

      end

    end
  end
end
