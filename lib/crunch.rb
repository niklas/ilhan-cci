require 'open-uri'
require 'json'
class Crunch
  attr_reader :res
  def initialize(options={})
    @res = options.fetch(:resolution) { 3600 }
    @after = options[:after]
    @before = options[:before]
  end
  include OpenURI
  def json
    @json ||= JSON.parse( cached { download.read } )
  end

  # typical price (C+H+L)/3
  def values
    unpacked.map(&:t)
  end

  def unpacked
    @unpacked ||= begin
                    l = unpack
                    if @after
                      l = l.select { |p| @after <= p.time }
                    end
                    if @before
                      l = l.select { |p| p.time <= @before }
                    end
                    if l.empty?
                      raise "no data found between #{@after} and #{@before}"
                    end
                    l
                  end
  end

  def cci
    unpacked.map(&:cci)
  end

  def calculate_cci(options = {})
    period = options.fetch(:period) { 20 }
    factor = options.fetch(:factor) { 0.015 }

    # number of values to use for Simple Moving Average
    recent = []

    [].tap do |cci|
      unpacked.each do |pupple|
        price = pupple.t

        if recent.length < period / 2
          # avoid division by zero and too much fluctuation at statrt
          pupple.cci = 0
        else
          sma  = recent.reduce(&:+) / recent.length
          mean = recent.map { |p| p - sma }.map(&:abs).reduce(&:+) / recent.length

          cci = (price - sma) / (factor * mean)
          cci = [cci,-400].max
          cci = [cci,400].min
          pupple.cci = cci
        end

        # keep the +period+ recent values
        recent << price
        recent.shift while recent.length > period
      end
    end
  end

  # it is a touple that is worth anything coming out of your nose
  class Pupple < Struct.new(:epoch, :c, :o, :h, :l, :wth)
    TZDiff = 3
    # "typical price"
    def t
      (c+h+l)/3
    end

    alias_method :price, :t

    def epoch
      super + (TZDiff*60*60)
    end

    def utc
      epoch + (2*60*60)
    end

    def time
      Time.at epoch
    end

    attr_accessor :cci
    attr_accessor :action
    attr_accessor :trans_index
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

  def unpack
    m = []
    h = b = z = 0.0
    q = 0.0
    y = 0
    r = nil
    p = 100.0
    c = json['data']

    ts = c['ts']
    op = c['o'].map(&:to_f)
    va = c['v'].map(&:to_f)
    hi = c['h'].map(&:to_f)
    lo = c['l'].map(&:to_f)
    cl = c['c'].map(&:to_f)

    r = ts.length - 1

    if true # hasVolume
      while y <= r
        z += ts[y] * res
        b += op[y]
        h += va[y]

        m << Pupple.new(
          z,
          (b + hi[y] - cl[y]) / p,
          b / p,
          (b + hi[y]) / p,
          (b - lo[y]) / p,
          h
        )
        b += hi[y] - cl[y]
        y += 1
      end
    end



    m
  end
end

