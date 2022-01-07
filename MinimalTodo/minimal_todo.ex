defmodule MinimalTodo do
  def start do
    load_csv()
  end

  def add_todo(data) do
    name = get_item_name(data)
    titles = get_fields(data)
    fields = Enum.map(titles, fn field -> field_from_user(field) end)
    new_todo = %{name => Enum.into(fields, %{})}
    IO.puts ~s(New TODO "#{name}" added.)
    new_data = Map.merge(data, new_todo)
    get_command(new_data)
  end

  def field_from_user(name) do
    field = IO.gets("#{name}: ") |> String.trim
    case field do
      _ -> {name, field}
    end
  end

  def get_fields(data) do
    data[hd Map.keys(data)] |> Map.keys
  end

  def get_item_name(data) do
    name = IO.gets("Enter the name of the new todo: ") |> String.trim
    if Map.has_key?(data, name) do
      IO.puts("TODO with that name is already exists\n")
      get_item_name(data)
    else
      name
    end
  end

  def load_csv do
    filename = IO.gets("Name of csv. to load: ") |> String.trim
    read(filename)
      |> parse
      |> get_command
  end

  def get_command(data) do
    prompt = """
    Type the first letter of the command you want to run
    R)ead todos   A)dd a todo    D)elete a todo    L)oad a csv.    S)ave a csv.
    """
    command = IO.gets(prompt)
      |> String.trim
      |> String.downcase

    case command do
      "r" ->  show_todos(data)
      "a" ->  add_todo(data)
      "d" ->  delete_todos(data)
      "q" ->  "GoodBye!"
      "s" ->  save_csv(data)
      _   ->  get_command(data)
    end
  end

  def show_todos(data, next_command? \\ true) do
    items = Map.keys(data)
    IO.puts "You have the followoing todos:\n"
    Enum.each items, fn item -> IO.puts item end
    IO.puts "\n"
    if next_command? do
      get_command(data)
    end
  end

  def delete_todos(data) do
    todo = IO.gets("Which todo would you like to delete?\n") |> String.trim
    if Map.has_key?(data, todo) do
      IO.puts "ok."
      new_map = Map.drop(data, [todo])
      IO.puts ~s("#{todo}"" has been deleted!)
      get_command(new_map)
    else
      IO.puts ~s(There is no todo "#{todo}"!)
      show_todos(data, false)
      get_command(data)
    end
  end

  def read(filename) do
    case File.read(filename) do
      {:ok, body}       ->  body
      {:error, reason}  ->  IO.puts ~s(Could not open the file #{filename}\n)
                            IO.puts ~s(#{:file.format_error reason}\n)
                            start()
    end
  end

  def parse_lines(lines, titles) do
    Enum.reduce(lines, %{}, fn line, built ->
      [name | fields] = String.split(line, ",")
      if Enum.count(fields) == Enum.count(titles) do
        line_data = Enum.zip(titles, fields) |> Enum.into(%{})
        Map.merge(built, %{name => line_data})
      else
        built
      end
    end)
  end

  def parse(body) do
    [header | lines] = String.split(body, ~r{(\r\n|\n|\r)})
    titles = tl String.split(header, ",")
    parse_lines(lines, titles)
  end

  def prepare_csv(data) do
    headers = ["Item" | get_fields(data)]
    items = Map.keys(data)
    item_rows = Enum.map(items, fn item ->
      [item | Map.values(data[item])]
    end)
    rows = [headers | item_rows]
    row_strings = Enum.map(rows, &(Enum.join(&1, ",")))
    Enum.join(row_strings, "\n")
  end

  def save_csv(data) do
    filename = IO.gets("Name of csv. file: ") |> String.trim
    filedata = prepare_csv(data)
    case File.write(filename, filedata) do
      :ok               -> IO.puts "CSV saved"
      {:error, reason}  -> IO.puts ~s(Could not save file "#{filename}")
                           IO.puts ~s("#{:file.format_error(reason)}"\n)
                           get_command(data)
    end
  end

end
