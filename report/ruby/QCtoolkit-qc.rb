require 'tmpdir'

if ENV["RAILS_ENV"] == "production"
  SKYNET_REPORT_DIR = '/home/servers/skynet/report'
else
  SKYNET_REPORT_DIR = '/Users/skon/iCloudDocs/SK/Sources/QCtoolkit/skynet/report'
end

# make temporary directory
temporary_directory = Dir.mktmpdir 'QCtoolkit-'
Dir.chdir temporary_directory

STDERR.puts temporary_directory

# run QCtoolkit R routine
exec("Rscript #{SKYNET_REPORT_DIR}/R/QCtoolkit-qc.R #{SKYNET_REPORT_DIR}")
