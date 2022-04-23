defmodule ExAthena.IO.InvalidOptionError do
  @moduledoc false
  defexception [:option]

  @impl true
  def message(%__MODULE__{option: option}) do
    "The given option #{option} wasn't defined in the configuration options"
  end
end

defmodule ExAthena.IO.InvalidTypeError do
  @moduledoc false
  defexception [:type]

  @impl true
  def message(%__MODULE__{type: type}) do
    "Expected a valid configuration type, got: #{type}"
  end
end
