require 'pry'
require 'date'
require 'faraday'
require 'faraday_middleware'

require 'socket'
tcp_server = TCPServer.new(9292)

puts "Ready for a request"
count = 0
running = true
while running
  count += 1
  client = tcp_server.accept
  request_lines = []
  while line = client.gets and !line.chomp.empty?
    request_lines << line.chomp
  end

  puts "Got this request:"
  puts request_lines.inspect
  # binding.pry
  response_arr = {}
  response_arr[:Host] = 'localhost:9292'
  request_lines.map do |req_line|
    split = req_line.split(": ")
    if req_line.include? "HTTP"
      split = req_line.split(" ")
      response_arr[:Verb] = split[0]
      response_arr[:Path] = split[1]
      response_arr[:Protocol] = split[2]
    else
      response_arr[split[0]] = split[1]
    end
  end

  puts "Sending response."

  response_arr = {
    "Verb": response_arr[:Verb],
    "Path": response_arr[:Path],
    "Protocol": response_arr[:Protocol],
    "Host": response_arr[:Host].split(":")[0],
    "Port": response_arr[:Host].split(":")[1],
    "Origin": response_arr[:Host].split(":")[0],
    "Accept": response_arr[:Accept]
  }

  puts "Composed response array."


  case response_arr[:Path]
  when '/hello'
    greeting = "hello world! + #{count}"
    output = "<html><head></head><body>#{response_arr}#{greeting}</body></html>"
  when '/datetime'
    output = Date.today.strftime("%I:%M on %A, %B %d, %Y")
  when '/shutdown'
    output = "total requests: + #{count}"
    running = false
  else
    output = "<html><head></head><body>#{response_arr}</body></html>"
  end

  headers = ["http/1.1 200 ok",
            "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
            "server: ruby",
            "content-type: text/html; charset=iso-8859-1",
            "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  client.puts headers
  client.puts output

  puts ["Wrote this response:", headers, output].join("\n")


  unless running
    p 'Closing server!'
    client.close
  end
end
puts "\nResponse complete, exiting."
