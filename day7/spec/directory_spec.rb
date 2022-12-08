require "spec_helper"

describe Directory do
  let(:parser) { Parser.new }
  let(:file_system) { parser.file_system }

  context "#total_size" do
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

    it "should calculate total size" do
      expect(file_system.find_directory("/one/two").total_size).to eq(250)
      expect(file_system.find_directory("/one").total_size).to eq(350)
      expect(file_system.find_directory("/").total_size).to eq(360)
    end
  end

  context "#absolute_path" do
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

    it "should calculate absolute path" do
      expect(file_system.find_directory("/one/two").absolute_path).to eq("/one/two")
      expect(file_system.find_directory("/one").absolute_path).to eq("/one")
      expect(file_system.find_directory("/").absolute_path).to eq("/")
    end
  end

end