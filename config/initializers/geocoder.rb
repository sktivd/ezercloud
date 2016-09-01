# This class implements a cache with simple delegation to the Redis store, but
# when it creates a key/value pair, it also sends an EXPIRE command with a TTL.
# It should be fairly simple to do the same thing with Memcached.
class AutoexpireCacheRedis
  def initialize(store, ttl = 86400 * 90)
    @store = store
    @ttl = ttl
  end

  def [](url)
    @store.[](url)
  end

  def []=(url, value)
    @store.[]=(url, value)
    @store.expire(url, @ttl)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end

Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  # lookup: :google,            # name of geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #keys)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys
  cache: AutoexpireCacheRedis.new(Redis.new),

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
  
  # MaxMind GeoIP2 Precision Web Services
  ip_lookup: :maxmind_geoip2,
  maxmind_geoip2: { service: :city, basic_auth: {user: '114710', password: 'tiHWzav9iwAS' } }
)
