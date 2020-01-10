class OpenDevTools
  def run
    close(inspect_tab)
    close(dev_tools_tab)

    open(INSPECT_URL)
  end

private

  EXECUTABLE = "chrome-cli"
  INSPECT_URL = "chrome://inspect"
  TAB_ID_REGEX = /\[\d+:(\d+)\]/

  def dev_tools_tab
    @dev_tools_tab ||= tab_id_for(tab_matching('DevTools - Node.js'))
  end

  def inspect_tab
    @inspect_tab ||= tab_id_for(tab_matching('Inspect with Chrome Developer Tools'))
  end

  def tab_id_for(tab)
    # Tab looks like [1234:5678]
    return unless tab

    TAB_ID_REGEX.match(tab).captures.first
  end

  def tab_matching(needle)
    tabs.find do |tab_name|
      tab_name.include?(needle)
    end
  end

  def open(url)
    return unless url

    puts "Opening #{url}..."
    `#{EXECUTABLE} open #{url} -n`
  end

  def close(tab)
    return unless tab

    puts "Closing #{tab}..."
    `#{EXECUTABLE} close -t #{tab}`
  end

  def tabs
    `#{EXECUTABLE} list tabs`.split("\n")
  end
end

OpenDevTools.new.run
