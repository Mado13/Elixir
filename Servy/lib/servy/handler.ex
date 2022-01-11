defmodule Servy.Handler do
  def handle(request) do
    request
      |> parse
      |> rewrite_path
      |> route
      |> format_response
  end

  def rewrite_path(%{ path: "/wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(conv), do: conv

  def parse(request) do
    [method, path, _] =
      request
        |> String.split("\n")
        |> List.first
        |> String.split(" ")

    %{ method: method,
       path: path,
       resp_body: "",
       status: nil}
  end

  def route(%{ method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%{ method: "GET", path: "/bears"} = conv) do
    %{ conv | status: 200, resp_body: "Smoky, Teddy, Peddington"}
  end

  def route(%{ method: "GET", path: "/about"} = conv) do
      Path.expand("../../pages", __DIR__)
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
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

  # def route(%{ method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{ conv | status: 200, resp_body: content}

  #     {:error, :enoent} ->
  #       %{ conv | status: 404, resp_body: "File not found"}

  #     {:error, reason } ->
  #       %{ conv | status: 500, resp_body: "Error #{reason}"}
  #   end
  # end

  def route(%{ method: "GET", path: "/bear" <> id} = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{ path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
        200 => "OK",
        201 => "Created",
        401 => "Unauthorized",
        403 => "Forbidden",
        404 => "Not Found",
        500 => "Internal Server Error"
    } [code]
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
