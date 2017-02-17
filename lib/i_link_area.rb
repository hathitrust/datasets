require "link"

# Wraps the filesystem.
class ILinkArea

  # Save a link to the filesystem. This operation
  # is idempotent.
  # @param [Link] link
  def save(link); end

  # Remove a link from the filesystem. This operation
  # is idempotent.
  # @param [Link] link
  def delete(link); end
end
