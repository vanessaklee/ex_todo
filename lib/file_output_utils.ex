defmodule ExTodo.FileOutputUtils do
  @moduledoc """
  This module is used to format strings for File write so that reports are easy
  to read.
  """

  @doc "Underline the provided text"
  def underline_text(text) do
    "_" <> text <> "_"
  end

  @doc "Make the provided text green - cannot do in file write"
  def green_text(text), do: "### " <> text <> "\n"

  @doc "Make the provided text blue - cannot do in file write"
  def blue_text(text), do: "__" <> text <> "__\n"

  @doc "Make the provided text white - cannot do in file write"
  def white_text(text), do: text

  @doc "Make the provided text red - cannot do in file write"
  def red_text(text), do: "*" <> text <> "*"

  @doc "Make the provided text ligth cyan - cannot do in file write"
  def light_cyan_text(text), do: "*" <> text <> "*\n"

  @doc "Format a string to be of a certain width and have a certain padding"
  def gen_fixed_width_string(value, width, padding \\ 2)

  def gen_fixed_width_string(value, width, padding) when is_integer(value) do
    value
    |> Integer.to_string()
    |> gen_fixed_width_string(width, padding)
  end

  def gen_fixed_width_string(value, width, padding) do
    sub_string_length = width - (padding + 1)

    value
    |> String.slice(0..sub_string_length)
    |> String.pad_trailing(width)
  end
end
