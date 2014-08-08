class FileItem < DataItem
  include ActionView::Helpers::NumberHelper

  attr_reader :human_size

  def initialize(h = {})
    h[:type] = 'file' unless h[:type]

    size = h[:size]
    h.delete(:size)
    super h
  end

  def size 
    @size
  end

  def size= value
    @size = value
    @human_size = number_to_human_size size
  end

end