using HTTP
using JSON
using Base64

url = "https://texttospeech.googleapis.com/v1/text:synthesize"
header = [
  "Content-Type" => "application/json"          
]


function call(s)
  r = HTTP.post("$url?key=$(ENV["API_KEY"])", header, open("sample.json", "r"))

  r.body |> 
    String |> 
    JSON.parse |> 
    x -> get(x, "audioContent", nothing) |>
    base64decode

end
