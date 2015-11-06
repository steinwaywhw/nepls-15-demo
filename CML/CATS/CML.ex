

defmodule Channel do 
	defp on_send(sender, msg) do 
		receive do 
			{:recv, receiver} -> 
				send receiver, {msg}
				receive do 
					{:ack} -> send sender, {:ack}
				end 
		end 
	end 

	defp on_recv(receiver) do 
		receive do 
			{:send, sender, msg} -> 
				send receiver, {msg}
				receive do 
					{:ack} -> send sender, {:ack}
				end 
		end 
	end 

	defp channel_task do 
		receive do 
			{:send, sender, msg} -> 
				on_send(sender, msg)
			{:recv, receiver} -> 
				on_recv(receiver)
		end 
		channel_task()
	end 

	def channel do 
		spawn fn -> channel_task() end
	end

	def channel_send(channel, msg) do
		send channel, {:send, self(), msg}
		receive do 
			{:ack} -> nil
		end
	end

	def channel_recv(channel) do 
		send channel, {:recv, self()}
		receive do 
			{msg} -> 
				send channel, {:ack}
				msg
		end
	end
end 
