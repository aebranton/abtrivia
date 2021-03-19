module TriviaProcs

    def create_countdown()
        pr = Proc.new do |sec, channel|
            sec.downto(0) do |c|
                channel.broadcast_subscription({action: "timer_tick", value: c})
                sleep(1)
            end
        end
    end

end