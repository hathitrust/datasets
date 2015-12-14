# database.rb
# connect to database in a runtime agnostic fasion, possibly offer some utility db methods

# get Sequel dataset representing lists of volumes matching certain rights creiteria
def rights_dataset()
end

# items missing from full set

# items to be linked
def items_to_link()
  # get things that are pd
  # return namespace, id, attr, reason
end

def items_to_delete()
  # namespace, id, ic, pd_us, pd_world, open_access
end
