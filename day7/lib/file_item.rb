class FileItem # can't call this "File"
  attr_reader :name, :size
  def initialize(name, size)
    @name = name.freeze
    @size = size.freeze
  end
end
