defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join

    %{ conv | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(conv, %{"id" => id}) do
    %{ conv | status: 200, resp_body: "Bear #{id}"}
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{ conv | status: 201,
              resp_body: "Created a #{type} bear named #{name}!"}
  end
end
