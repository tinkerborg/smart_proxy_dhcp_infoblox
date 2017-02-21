module ::Proxy::DHCP::Infoblox
  class GridRestart
    MAX_ATTEMPTS = 3

    include ::Proxy::Log
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def try_restart
      props = ::Infoblox::DHCPProperties.all(connection).first
      if props.immediate_fa_configuration
        logger.debug 'Immediate FA configuration is set, skipping grid restart.'
        return
      end

      logger.debug 'Restarting grid.'

      MAX_ATTEMPTS.times do |tries|
        sleep tries
        return if restart
      end

      logger.info 'Restarting Grid failed.'
      false
    end

    def restart
      (@grid ||= ::Infoblox::Grid.get(@connection).first).restartservices
      true
    rescue Exception => e
      false
    end
  end
end
