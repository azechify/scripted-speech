println("start main.jl")
using HTTP

println("!!!!! http package loaded")

HTTP.listen("0.0.0.0", 8080) do http::HTTP.Stream
  @show http.message
  @show HTTP.header(http, "Content-Type")
  while !eof(http)
    println("body data: ", String(readavailable(http)))
  end
  HTTP.setstatus(http, 200)
  HTTP.startwrite(http)
  write(http, "response body")
  write(http, " ")
  write(http, "more response body")
end

