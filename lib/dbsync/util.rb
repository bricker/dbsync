module Dbsync
  module Util
    class << self
      def symbolize_keys(hash)
        return hash unless hash.keys.any? { |k| k.is_a?(String) }

        result = {}
        hash.each_key { |k| result[k.to_sym] = hash[k] }
        result
      end

      def notify(message="")
        $stdout.puts "[#{Time.now.strftime('%T')}] [dbsync] #{message}"
      end
    end
  end
end
