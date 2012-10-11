
module Gabba

  class Gabba

    attr_accessor :ip_address

    # makes the tracking call to Google Analytics
    def hey(params)
      query = params.map {|k,v| "#{k}=#{URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}" }.join('&')

      response = Net::HTTP.start(GOOGLE_HOST) do |http|
        request = Net::HTTP::Get.new("#{BEACON_PATH}?#{query}")
        request["User-Agent"] = URI.escape(user_agent)
        request["Accept"] = "*/*"
        request["X-Forwarded-For"] = URI.escape(ip_address) if ip_address
        http.request(request)
      end

      raise GoogleAnalyticsNetworkError unless response.code == "200"
      response
    end

  end

end
