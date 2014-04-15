require 'spec_helper'

describe Dbsync::Sync do
  let(:local_path) { File.expand_path("../local/dbsync.dump", __FILE__) }
  let(:remote_path) { File.expand_path("../remote/dbsync.dump", __FILE__) }

  let(:ssh_config) do
    {
      :local  => File.expand_path("../local/dbsync.dump", __FILE__),
      :remote => File.expand_path("../remote/dbsync.dump", __FILE__)
    }
  end

  let(:db_config) do
    {
      :adapter    => "mysql2",
      :database   => "cool_db",
      :username   => "root",
      :password   => nil
    }
  end


  describe "::notify" do
  end

  describe '#fetch' do
    it "creates the directory if it's missing" do
      ssh_config[:local] = File.expand_path("../local_missing/dbsync.dump", __FILE__)
      sync = Dbsync::Sync.new(ssh_config, db_config)

      sync.fetch

      File.directory?(File.expand_path("../local_missing", __FILE__)).should be_true
      FileUtils.rm_rf(File.expand_path("../local_missing", __FILE__))
    end

    it "copies the remote file the the local file" do
      sync = Dbsync::Sync.new(ssh_config, db_config)
      sync.fetch

      File.read(local_path).should eq File.read(remote_path)
    end
  end

  describe '#merge' do
  end

  describe '#clone_dump' do
    it "removes the local file and rsyncs a fresh one" do
      # Put a dummy local file in place to make sure it gets removed
      File.open(local_path, "w") { |f| f.write "Hello." }
      File.read(local_path).should eq "Hello."

      sync = Dbsync::Sync.new(ssh_config, db_config)
      sync.clone_dump

      File.read(local_path).should eq File.read(remote_path)
    end
  end

  describe '#pull' do
  end
end
