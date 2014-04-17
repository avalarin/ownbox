class FileItem < DataItem
  include ActionView::Helpers::NumberHelper

  attr_accessor :size, :type
  attr_reader :human_size

  def initialize(h)
    super
    @size = h[:size];
    @type = h[:type];

    @human_size = number_to_human_size @size
  end
end