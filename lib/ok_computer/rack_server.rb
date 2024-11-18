module OkComputer
  module RackServer
    def self.run!(port: 3000)
      require "rack/handler/puma"

      fork do
        handler = Rack::Handler::Puma
        handler.run(self, Port: port, Threads: "1:3", workers: 0)
      end
    end

    def self.call(_env)
      checks = OkComputer::Registry.all
      checks.run

      if checks.success?
        [200, {}, ["200 OK"]]
      else
        [500, {}, [checks.to_text]]
      end
    end
  end
end
