defmodule RPCHandler do
  @moduledoc """
  RPC АПИ для работы с Процедурным процессором
  """
  use GenServer
  require Logger



  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end


  def ref(_company_id, params) do
    IO.puts("Received parameters:")
    IO.inspect(params)
    {:ok, "Parameters printed"}
  end

  def get_account_info(company_id) do
    {:ok, %{company_id: company_id, name: "Example Company"}}
  end

  def process_request(:another_method, params) do
    {:error, "Method not implemented for #{inspect(params)}"}
  end

  def process_request(_unknown_method, _params) do
    {:error, "Unknown method"}
  end
end
