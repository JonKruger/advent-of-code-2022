class FileSystem
  attr_reader :root_directory, :current_directory

  def initialize
    @root_directory = Directory.new("", nil)
    @current_directory = root_directory
  end

  def set_current_directory(directory)
    @current_directory = directory
  end

  def find_directory(path)
    directory_names = path.split("/").select { |p| !p.empty? }
    result = @root_directory
    directory_names.each do |name|
      result = result.find_directory(name)
      return result if result.nil?
    end
    result
  end

  def print_path_sizes
    @root_directory.print_path_sizes
  end

  def total_size_at_most(max_size)
    sizes = @root_directory.total_size_including_subdirectories
    sizes
      .select { |size| size < max_size }
      .sum
  end

  def all_directory_sizes
    @root_directory.total_size_including_subdirectories.sort
  end
end