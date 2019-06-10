require 'pry'

require 'socket'
tcp_server = TCPServer.new(9292)

puts "Ready for a request"
count = 0
while true
  count += 1
  client = tcp_server.accept
  request_lines = []
  while line = client.gets and !line.chomp.empty?
    request_lines << line.chomp
  end

  puts "Got this request:"
  puts request_lines.inspect
  split_lines = request_lines.map { |req_line| req_line.split(":")}
  split_header_on_space = split_lines[0].map { |path| path.split(" ") }

  puts "Sending response."
  # binding.pry
  response_arr = [
    "Verb": split_header_on_space[0][0],
    "Path": split_header_on_space[0][1],
    "Protocol": split_header_on_space[0][2],
    "Host": split_lines[1][1],
    "Port": split_lines[1][2],
    "Origin": split_lines[1][1],
    "Accept": split_lines[6][1]
  ]

  # response = "<pre>" + request_lines.join("\n") + "</pre>"
  response = "<pre>#{response_arr}</pre>"

  greeting = "hello world! + #{count}"

  output = "<html><head></head><body>#{response}#{greeting}</body></html>"
  headers = ["http/1.1 200 ok",
            "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
            "server: ruby",
            "content-type: text/html; charset=iso-8859-1",
            "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  client.puts headers
  client.puts output

  puts ["Wrote this response:", headers, output].join("\n")
  client.close
end
puts "\nResponse complete, exiting."
