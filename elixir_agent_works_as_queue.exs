#!/usr/bin/env elixir

# Goal:
#   Compare elixir Agent versa plain Enumerable in pool mode:
#   every next request should get a next value from the
#   predefined list in a inifinite loop.
#
# Software:
#
#   System Software Overview:
#
#     System Version: OS X 10.11.4 (15E65)
#     Kernel Version: Darwin 15.4.0
#     Boot Volume: Macintosh HD
#     Boot Mode: Normal
#     Secure Virtual Memory: Enabled
#     System Integrity Protection: Enabled
#     Time since boot: 5 days 14:21
#
# Hardware:
#
#   Hardware Overview:
#
#     Model Name: MacBook Air
#     Model Identifier: MacBookAir5,2
#     Processor Name: Intel Core i5
#     Processor Speed: 1,8 GHz
#     Number of Processors: 1
#     Total Number of Cores: 2
#     L2 Cache (per Core): 256 KB
#     L3 Cache: 3 MB
#     Memory: 4 GB
#     Boot ROM Version: MBA51.00EF.B04
#     SMC Version (system): 2.5f9
#
# Results:
#   8.1e-5
#   0.005962

list = [1, 2, 3, 4, 5, 6, 7, 8, 9]

defmodule Compare do
  def loop(0, list), do: list

  def loop(index, [head | tail]) do
    list = tail ++ [head]
    loop(index - 1, list)
  end
end

Compare |> :timer.tc(:loop, [1000, list]) |> elem(0) |> Kernel./(1_000_000) |> IO.inspect


list = [1, 2, 3, 4, 5, 6, 7, 8, 9]
Agent.start_link(fn -> list end, name: AgentCompare)

defmodule AgentCompare do
  def loop(0), do: :ok

  def loop(index) do
    Agent.get_and_update(__MODULE__, fn list ->
      [head | tail] = list

      { head, tail ++ [head]}
    end)

    loop(index - 1)
  end
end

AgentCompare |> :timer.tc(:loop, [1000]) |> elem(0) |> Kernel./(1_000_000) |> IO.inspect
