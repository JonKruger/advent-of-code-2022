require "spec_helper"

describe FileSystem do
  let(:parser) { Parser.new }
  let(:file_system) { parser.file_system }

  context "#find_directory" do
    before do
      commands = <<-COM
        $ cd /
        $ ls
        10 file1
        $ cd one
        $ ls
        100 file2
        $ cd two
        $ ls
        250 file3
      COM
      parser.process(commands)
    end

    it "should find leaf node" do
      expect(file_system.find_directory("/one/two").name).to eq("two")
    end

    it "should find root node" do
      expect(file_system.find_directory("/")).to eq(file_system.root_directory)
    end
  end

  context "#total_size_at_most" do
    before do
      commands = <<-COM
        $ cd /
        $ ls
        10 file1
        $ cd one
        $ ls
        100 file2
        $ cd two
        $ ls
        250 file3
      COM
      parser.process(commands)
    end

    it "should calculate for root node" do
      expect(file_system.total_size_at_most(361)).to eq(960)
      expect(file_system.total_size_at_most(360)).to eq(600)
      expect(file_system.total_size_at_most(9)).to eq(0)
    end
  end

end