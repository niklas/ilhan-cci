require 'open-uri'
class Crunch
  include OpenURI
  def json
    @json ||= cached { download.read }
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

