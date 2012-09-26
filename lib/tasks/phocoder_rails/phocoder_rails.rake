namespace :phocoder_rails do
  desc "Update pending EncodableJobs"
  task :update_pending_jobs => :environment do
    e = EncodableJob.first
    e.encodable # try to load phocoder config
    e.encodable.class.read_phocodable_configuration
    #puts "api key = #{Phocoder.api_key}"
    #puts "Rails.env = #{Rails.env}"
    puts "Updating #{EncodableJob.pending.count} EncodableJobs"
    EncodableJob.update_pending_jobs
  end
end