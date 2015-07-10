require 'open-uri'
require 'json'
class Crunch
  include OpenURI
  def json
    @json ||= JSON.parse( cached { download.read } )
  end

  def values
    unpacked.map { |u| u[1] }
  end

  def unpacked
    @unpacked ||= unpack
  end

  def cci(options = {})
    period = options.fetch(:period) { 20 }

    # number of values to use for Simple Moving Average
    recent = []
    factor = 0.015

    [].tap do |cci|
      values.each do |price|

        if recent.length < period / 2
          # avoid division by zero and too much fluctuation at statrt
          cci << 0
        else
          sma  = recent.reduce(&:+) / recent.length
          mean = recent.map { |p| p - sma }.map(&:abs).reduce(&:+) / recent.length

          c = (price - sma) / (factor * mean)
          cci << c
        end

        # keep the +period+ recent values
        recent << price
        recent.shift while recent.length > period
      end
    end
  end

  private

  def download
    open uri
  end

  def uri
    "http://go.guidants.com/api/v1/services/charting/d/q?iid=133962&res=#{res}&eid=4"
  end

  def cached(&block)
    Cache.fetch cache_path, &block
  end

  def cache_path
    ".cci-#{res}"
  end

  def res
    3600
  end

  def unpack
    m = []
    h = b = z = 0.0
    q = 0.0
    y = 0
    r = nil
    p = 100.0
    # "f"
    bc = 60.0
    c = json['data']

    ts = c['ts']
    op = c['o'].map(&:to_f)
    va = c['v'].map(&:to_f)
    hi = c['h'].map(&:to_f)
    lo = c['l'].map(&:to_f)
    cl = c['c'].map(&:to_f)

    r = ts.length - 1
    while 2 > q
      q += 1

      if true # hasVolume
        while y <= r
          z += ts[y] * bc
          b += op[y]
          h += va[y]

          m << [
            z,
            (b + hi[y] - cl[y]) / p,
            b / p,
            (b + hi[y]) / p,
            (b - lo[y]) / p,
            h
          ]
          b += hi[y] - cl[y]
          y += 1
        end
      end

    end


    m
  end
end

