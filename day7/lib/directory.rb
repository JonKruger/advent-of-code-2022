class Directory
  attr_reader :name, :parent, :directories, :files
  def initialize(name, parent)
    @name = name.freeze
    @parent = parent
    @directories = []
    @files = []
  end

  def add_directory(name)
    directory = find_directory(name)
    unless directory
      directory = Directory.new(name, self)
      directories << directory
    end
    directory
  end

  def add_file(name, size)
    @files << FileItem.new(name, size)
  end

  def find_directory(name)
    @directories.select { |dir| dir.name == name }.first
  end

  def total_size
    files.map(&:size).sum + directories.map(&:total_size).sum
  end

  def total_size_including_subdirectories
    ([total_size] + directories.map(&:total_size_including_subdirectories)).flatten
  end

  def absolute_path
    path = (parent&.absolute_path || "")
    path += "/" unless path.end_with?("/")
    path += name
    path
  end

  def print_path_sizes
    puts "#{absolute_path} - #{total_size}"
    directories.each(&:print_path_sizes)
  end
end