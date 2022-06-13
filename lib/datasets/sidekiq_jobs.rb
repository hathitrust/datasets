require "datasets"

def load_config
  require_relative "../../config/hathitrust_config"
  config_yml = Pathname.new(__FILE__).expand_path.dirname / ".." / ".." / "config" / "config.yml"
  Datasets.config = Datasets::HathiTrust::Configuration.from_yaml(config_yml)
end

def setup_logs
  # set up pipe to rotatelogs
  log_basename = [Socket.gethostname, Process.pid, "%Y%m%d"].join("-")
  FileUtils.mkdir_p Datasets.config.worker_log_path
  log_template = File.join(Datasets.config.worker_log_path, "#{log_basename}.log")
  rotatelogs_cmd = "/usr/bin/rotatelogs -f -l #{log_template} 86400"
  log_io = IO.popen(rotatelogs_cmd, "w")
  log_io.sync = true

  Sidekiq.logger = Logger.new(log_io)
  Sidekiq.logger.level = Logger::INFO
end

load_config
setup_logs
