class OperationJob
  include SuckerPunch::Job

  def perform(mda, mda_server_host)
    mda = Analysis.find(mda_id) 
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda, mda_server_host)
    ok, log = ogen.run :analysis
  end
end
