# require "./file_system.rb"

class Parser
  attr_reader :file_system

  def initialize
    @file_system = FileSystem.new
    @ls_mode = false
  end

  def process(lines)
    lines.split("\n").compact.each { |line| process_line(line) }
  end

  def process_line(line)
    line = line.strip

    if line.start_with?("$")
      @ls_mode = false
    end

    if line == "$ cd /"
      puts("[1] processing #{line}")
      file_system.set_current_directory(file_system.root_directory)
    elsif line == "$ cd .."
      puts("[2] processing #{line}")
      if file_system.current_directory.parent
        file_system.set_current_directory(file_system.current_directory.parent)
      end
    elsif matches = /\$ cd ([a-zA-Z0-9]+)$/.match(line)
      puts("[3] processing #{line}")
      dir = file_system.current_directory.add_directory(matches[1])
      file_system.set_current_directory(dir)
    elsif line == "$ ls"
      @ls_mode = true
    elsif matches = /dir ([a-zA-Z0-9\.]+)$/.match(line)
      raise unless @ls_mode
      file_system.current_directory.add_directory(matches[1])
    elsif matches = /([0-9]+) ([a-zA-Z0-9\.]+)$/.match(line)
      raise unless @ls_mode
      file_system.current_directory.add_file(matches[2], matches[1].to_i)
    end
  end
end

