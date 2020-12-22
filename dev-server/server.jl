using HTTP


mimetypes = Dict([
  (".js", "text/javascript; charset=utf-8"),
  (".mp3", "audio/mpeg")
])


HTTP.serve("0.0.0.0", 8080) do req::HTTP.Request

  @show req.target
  filename = basename(HTTP.URI(req.target).path)
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
    return HTTP.Response(200, [("Content-Type", "audio/mp3")], body = call("hello"))
  end


end

