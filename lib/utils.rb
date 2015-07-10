require 'gnuplot'
class Utils
  def self.plot(values, options={})
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |pl|

        pl.title( options.fetch(:title) { 'ein paar Werte' } )
        pl.xlabel "i"
        pl.ylabel "c"

        pl.terminal "png"
        pl.output( options.fetch(:output) { 'plot.png' } )

        x = (0...values.length).collect { |v| v.to_f }

        pl.data << Gnuplot::DataSet.new( [x, values] ) do |ds|
          ds.with = "lines"
          ds.notitle
        end
      end

    end
  end
end
