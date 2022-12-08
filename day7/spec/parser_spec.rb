require "spec_helper"

describe Parser do
  let(:parser) { Parser.new }
  let(:file_system) { parser.file_system }

  context "root directory" do
    before do
      commands = <<-COM
        $ cd /
        $ cd foo
      COM
      parser.process(commands)
      expect(file_system.current_directory).to_not eq(file_system.root_directory)
    end

    let!(:result) { parser.process_line("$ cd /") }

    it "should process '$ cd /'" do
      expect(file_system.root_directory).to_not be_nil
      expect(file_system.current_directory).to eq(file_system.root_directory)
    end

    it "root directory should have no parent" do
      expect(file_system.root_directory.parent).to be_nil
    end
  end

  context "cd into a directory" do
    before do
      parser.process_line("$ cd /")
    end

    let!(:result) { parser.process_line("$ cd foo") }

    it "should switch to a new directory" do
      expect(file_system.current_directory.name).to eq("foo")
    end

    it "should have foo as a child of the root directory" do
      expect(file_system.current_directory.parent).to eq(file_system.root_directory)
    end
  end

  context "cd .." do
    before do
      commands = <<-COM
        $ cd /
        $ cd foo
      COM
      parser.process(commands)
    end

    let!(:result) { parser.process_line("$ cd ..") }

    it "should switch to the parent directory" do
      expect(file_system.current_directory).to eq(file_system.root_directory)
    end
  end

  context "cd .. from root directory" do
    before do
      commands = <<-COM
        $ cd /
      COM
      parser.process(commands)
    end

    let!(:result) { parser.process_line("$ cd ..") }

    it "should stay in the root directory" do
      expect(file_system.current_directory).to eq(file_system.root_directory)
    end
  end

  context "ls with files/directories following" do
    before do
      commands = <<-COM
        $ cd /
      COM
      parser.process(commands)
    end

    let!(:result) do
      commands = <<-COM
        $ ls
        dir foo
        12345 filename.txt
      COM
      parser.process(commands)
    end

    it "should list the files in the folder" do
      dir = file_system.current_directory
      expect(dir.files.size).to eq(1)
      expect(dir.files[0].name).to eq("filename.txt")
      expect(dir.files[0].size).to eq(12345)
    end

    it "should list the directories in the folder" do
      dir = file_system.current_directory
      expect(dir.directories.size).to eq(1)
      expect(dir.directories[0].name).to eq("foo")
    end
  end
end