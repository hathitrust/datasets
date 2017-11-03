class HTIDRetriever
  def initialize(repository:, htids:)
    @htids = htids
    @repository = repository
  end

  def retrieve
    repository.volumes(htids)
  end

  private

  attr_reader :repository, :htids
end
