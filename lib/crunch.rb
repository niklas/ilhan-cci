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
end

