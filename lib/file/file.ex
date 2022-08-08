defmodule ExTodo.File do
  alias ExTodo.{Config, FileSummary, FileUtils, FileOutputUtils, CodetagEntry}

  @todo_file "todo.md"

  @doc "Given a config, run the codetags report"
  def run_report(%Config{} = config) do
    file_init()
    config
    |> FileUtils.get_all_files()
    |> FileUtils.read_file_list_contents()
    |> FileUtils.get_file_list_codetags(config)
    |> Enum.map(fn {path, file_codetags} ->
      FileSummary.build(path, file_codetags)
    end)
    |> Enum.sort(fn file_summary_1, file_summary_2 ->
      file_summary_1.file_path <= file_summary_2.file_path
    end)
    |> output_report()
    |> output_summary(config)
    |> report_result(config)
  end

  defp output_report([]) do
    file_write("No codetags of interest have been found in the codebase.\n")
  end

  defp output_report(entries) do
    Enum.each(entries, fn entry ->
      entry.file_path
      |> FileOutputUtils.blue_text()
      |> FileOutputUtils.underline_text()
      |> file_write()

      Enum.each(entry.todo_entries, fn todo_entry ->
        line_label =
          "  line #{Integer.to_string(todo_entry.line)}"
          |> FileOutputUtils.gen_fixed_width_string(12, 1)
          |> FileOutputUtils.green_text()

        type_label =
          todo_entry.type
          |> FileOutputUtils.gen_fixed_width_string(8, 1)
          |> FileOutputUtils.white_text()

        comment = FileOutputUtils.light_cyan_text(todo_entry.comment)

        file_write("#{line_label}#{type_label}#{comment}")
      end)
    end)

    entries
  end

  # TODO this is a test
  # TODO this is one too

  defp file_write(contents) do
    path = @todo_file
    File.write(path, contents, [:append])
  end

  defp file_init() do
    path = @todo_file
    File.write(path, "# TODO\n \n")
  end

  defp output_summary(entries, %Config{} = config) do
    "ExTodo Scan Summary"
    |> FileOutputUtils.blue_text()
    |> FileOutputUtils.underline_text()
    |> file_write()

    entries
    |> Enum.map(fn files ->
      files.todo_entries
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn entry, acc ->
      acc
      |> Map.update(entry.type, 1, &(&1 + 1))
    end)
    |> Map.to_list()
    |> Enum.sort(fn {keyword_1, _}, {keyword_2, _} ->
      keyword_1 <= keyword_2
    end)
    |> Enum.each(fn {keyword, count} ->
      if keyword in config.error_codetags do
        type =
          "  #{keyword}"
          |> FileOutputUtils.gen_fixed_width_string(10, 1)
          |> FileOutputUtils.red_text()

        count =
          count
          |> FileOutputUtils.gen_fixed_width_string(10, 1)
          |> FileOutputUtils.red_text()

        file_write("#{type}#{count}")
      else
        type =
          "  #{keyword}"
          |> FileOutputUtils.gen_fixed_width_string(10, 1)
          |> FileOutputUtils.green_text()

        count =
          count
          |> FileOutputUtils.gen_fixed_width_string(10, 1)
          |> FileOutputUtils.green_text()

        file_write("#{type}#{count}")
      end
    end)

    entries
  end

  defp report_result(entries, %Config{} = config) do
    found_errors =
      entries
      |> Enum.map(fn files ->
        files.todo_entries
      end)
      |> List.flatten()
      |> Enum.find_value(false, fn %CodetagEntry{type: type} ->
        type in config.error_codetags
      end)

    not found_errors
  end
end
