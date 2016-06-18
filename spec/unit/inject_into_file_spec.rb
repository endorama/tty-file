# encoding: utf-8

RSpec.describe TTY::File, '#inject_into_file' do
  before do
    FileUtils.rm_rf(tmp_path)
    FileUtils.cp_r(fixtures_path, tmp_path)
  end

  it "injects content into file :before" do
    file = File.join(tmp_path, 'Gemfile')
    TTY::File.inject_into_file(file, "gem 'tty'\n",
      before: "gem 'rack', '>=1.0'\n", verbose: false)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'tty'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "injects content into file :after" do
    file = File.join(tmp_path, 'Gemfile')

    expect {
      TTY::File.inject_into_file(file, "gem 'tty'", after: "gem 'rack', '>=1.0'\n")
    }.to output(/inject/).to_stdout_from_any_process

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'"
    ].join)
  end

  it "accepts content in block" do
    file = File.join(tmp_path, 'Gemfile')

    expect {
      TTY::File.inject_into_file(file, after: "gem 'rack', '>=1.0'\n") do
        "gem 'tty'"
      end
    }.to output(/inject/).to_stdout_from_any_process

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'"
    ].join)
  end

  it "accepts many lines" do
    file = File.join(tmp_path, 'Gemfile')

    TTY::File.inject_into_file(file, "gem 'tty'\n", "gem 'loaf'",
      after: "gem 'rack', '>=1.0'\n", verbose: false)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'\n",
      "gem 'loaf'"
    ].join)
  end

  it "logs action" do
    file = File.join(tmp_path, 'Gemfile')

    expect {
    TTY::File.inject_into_file(file, "gem 'tty'\n", "gem 'loaf'",
      after: "gem 'rack', '>=1.0'\n", verbose: true)
    }.to output(/inject.*Gemfile/).to_stdout_from_any_process
  end

  it "doesn't change content if already exists" do
    file = File.join(tmp_path, 'Gemfile')
    TTY::File.inject_into_file(file, "gem 'tty'",
      after: "gem 'rack', '>=1.0'\n", verbose: false)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'"
    ].join)

    TTY::File.inject_into_file(file, "gem 'tty'",
      after: "gem 'rack', '>=1.0'\n", verbose: false)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
      "gem 'tty'"
    ].join)
  end

  it "changes content already present if :force flag is true" do
    file = File.join(tmp_path, 'Gemfile')

    TTY::File.inject_into_file(file, "gem 'tty'\n",
      before: "gem 'nokogiri'", verbose: false)

    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)

    TTY::File.inject_into_file(file, "gem 'tty'\n",
      before: "gem 'nokogiri'", verbose: false, force: true)

    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'tty'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "fails to inject into non existent file" do
    file = File.join(tmp_path, 'unknown')

    expect {
      TTY::File.inject_into_file(file, "gem 'tty'", after: "gem 'rack', '>=1.0'\n")
    }.to raise_error(ArgumentError, /File path (.)* does not exist/)
  end

  it "doesn't change content when :noop flag is true" do
    file = File.join(tmp_path, 'Gemfile')
    TTY::File.inject_into_file(file, "gem 'tty'\n",
      before: "gem 'nokogiri'", verbose: false, noop: true)

    expect(File.read(file)).to eq([
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end
end
