defmodule Servy.Handler do

  @pages_path Path.expand("../../pages", __DIR__)

  alias Servy.Conv

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  def handle(request) do
    request
      |> parse
      |> rewrite_path
      |> log
      |> route
      |> track
      |> format_response
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Smoky, Teddy, Peddington"}
  end

  def route(%Conv{ method: "GET", path: "/bear" <> id} = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{ method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!"}
  end

  def handle_file({:ok, content}, conv) do
     %{ conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found"}
  end

  def handle_file({:error, reason}, conv) do
     %{ conv | status: 500, resp_body: "Error #{reason}"}
  end


  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end
request = """
GET /about HTTP/1.1
HOST: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

test = Servy.Handler.handle(request)

IO.puts test

request = """
POST /bears HTTP/1.1
HOST: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloon&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response
