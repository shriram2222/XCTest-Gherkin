class TravisFormatter < XCPretty::Simple

  FEATURE_MATCHER = /^\s*Feature: (.+)$/
  SCENARIO_MATCHER = /^\s*Scenario: (.+)$/
  STEP_MATCHER = /^\s*step (.+)\s{2}\(((?:.+):(?:\d+))\)$/
  TEST_CASE_FAILED_MATCHER = /^\s*Test Case\s'-\[(.*)\s(.*)\]'\sfailed\s\((\d*\.\d{3})\sseconds\)/
  
  def initialize (use_unicode, colorize)
    super
    @performed_step = nil
  end

  def pretty_format(text)
    case text.strip
    when TEST_CASE_FAILED_MATCHER
      return format_failed_test($1, $2, $3)
    when FEATURE_MATCHER
      return format_feature(text)
    when SCENARIO_MATCHER
      return format_scenario(text)
    when STEP_MATCHER
      text = format_performed_step(method(:green))
      @performed_step = INDENT + $1 + "  " + gray("(#{$2})")
      return text
    else
      parser.parse(text)
    end
  end

  def format_other(message);
    return format_performed_step(method(:green))
  end

  # renderes cached step and clears cache
  def format_performed_step(color)
    unless @performed_step.nil?
      text = color.call(@performed_step)
      @performed_step = nil
      return text
    else
      return EMPTY
    end
  end

  def format_text_after_step(color, separator, text)
    unless @performed_step.nil?
      return format_performed_step(color) + separator + text
    else
      return text
    end
  end
  
  def format_feature(text)
    format_text_after_step(method(:green), "\n", "\n" + text.strip)
  end

  def format_scenario(text)
    format_text_after_step(method(:green), "\n", "\n" + text)
  end

  def format_passing_test(suite, test, time)
    text = super
    format_text_after_step(method(:green), "\n\n", text)
  end

  # same as format_passing_test but for failed test
  def format_failed_test(suite, test_case, time)
    text = INDENT + format_test("#{test_case} (#{colored_time(time)} seconds)", :fail)
    format_text_after_step(method(:green), "\n\n", text)
  end

  # formats test failure with snippet
  def format_failing_test(suite, test, reason, file_path);
    text = format_failure({file_path: file_path, reason: reason})
    format_text_after_step(method(:red), "\n", text)
  end

  def format_test_run_started(name)
    EMPTY
  end
  
  def format_test_suite_started(name)
    yellow(heading("Test Suite", name, yellow("started")))
  end

  def format_test_summary(executed_message, failures_per_suite)
    EMPTY
  end

  def format_failure(f)
    filepath = f[:file_path]
    snippet = Snippet.from_filepath(filepath)
    path, line_number = filepath.split(':')

    output = INDENT + "#{red(f[:reason])}\n"
    output += INDENT + "#{cyan(f[:file_path])}\n"
    return output if snippet.contents.empty?

    output += INDENT + "```\n"
    snippet_contents = []
    if @colorize
      snippet_contents = Syntax.highlight(snippet).lines[0...-1]
    else
      snippet_contents = snippet.contents.lines
    end

    snippet_contents.each_with_index { |line, index|
      output += INDENT + gray("#{line_number.to_i + index - 1}") + line 
    }

    output += INDENT + "```"
    output
  end

  def gray(text)
    return text unless !!@colorize
    "\u{001B}[0;90m#{text}\u{001B}[0;0m"
  end

  def green(text)
    ansi_parse(text, :green)
  end

end

TravisFormatter
