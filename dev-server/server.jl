using HTTP


mimetypes = Dict([
  (".js", "text/javascript; charset=utf-8"),
  (".mp3", "audio/mpeg")
])


function handler(req::HTTP.Request) 

  target = HTTP.URI(req.target)
  @show target

  filename = basename(target.path)
  filename = ifelse(isempty(filename), "index.html", filename)

  if isfile(filename)
    
    mimetype = get(mimetypes, splitext(filename)[2], nothing)
    if !isnothing(mimetype)
      headers = [("Content-Type", mimetype)]
    else 
      headers = []
    end

    return HTTP.Response(200, headers, body = read(filename))
  else
    text = target.query |>
      HTTP.queryparams |>
      x -> get(x, "text", nothing)

    return HTTP.Response(200, [("Content-Type", "audio/opus")], body = call(text))
  end

end


if (!@isdefined server)
  server = Base.Threads.@spawn HTTP.serve(handler , "0.0.0.0", 8080)
end

