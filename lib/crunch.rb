require 'open-uri'
require 'json'
class Crunch
  include OpenURI
  def json
    @json ||= JSON.parse( cached { download.read } )
  end

  def values
    json['data']['c']
  end

  def unpacked
    @unpacked ||= unpack
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
    h = b = z = 0
    y = q = 0
    r = nil
    p = 100
    # "f"
    bc = 60
    c = json['data']

    ts = c['ts']
    op = c['o']
    va = c['v']
    hi = c['h']
    lo = c['l']
    cl = c['c']

    r = ts.length - 1
    while 2 > q
      q += 1

      if true # hasVolume
        while y < r
          z += ts[y] * bc
          b += op[y]
          h += va[y]

          m << [
            z,
            (b + hi[y] - cl[y]) / p,
            b / p,
            (b + hi[y]) / p,
            (b - lo[y]) / p,
            0
          ]
          b += hi[y] - cl[y]
          y += 1
        end
      end

    end


    m
  end
end

