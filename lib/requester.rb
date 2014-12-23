##
#
class Requester
  class << self
    def http
      @http ||= begin
        sess = Patron::Session.new
        sess.enable_debug nil
        sess.connect_timeout = 45
        sess.timeout = 45
        sess
      end
    end

    ##
    # Sends a request to the given webhook and returns a
    # hash containing the parsed response body and the raw Patron response
    #
    # @param endpoint [String] address
    # @param body [String] data to be sent
    # @param content_type [String]
    # @return [Hash] Patron response
    def request(endpoint, body, content_type)
      http.post endpoint, body, 'Content-Type' => content_type
    end

  end
end