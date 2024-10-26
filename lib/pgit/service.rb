# Service Descriptor
class Service
  attr_accessor :name, :description, :path, :repository, :key

  def initialize(name, description, path)
    @name = name
    @description = description
    @path = path
  end
end
