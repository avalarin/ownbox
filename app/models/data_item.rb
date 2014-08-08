class DataItem < ActiveRecord::Base
  self.table_name = :items
  self.inheritance_column = 'class_name'

  validates :name, :full_path, :owner, :type, presence: true

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_many :shares, foreign_key: 'item_id'

  def initialize(h = {})
    permission = h[:permission] || :unknown
    h.delete(:permission)
    super h
  end

  def self.find_by_user_and_path user, path
    DataItem.where(user_id: user.id, path: path).first
  end

  def path
    @path_value = Path.parse(read_attribute(:path)) unless @path_value
    @path_value
  end

  def path= value
    write_attribute(:path, value.to_s_rooted)
    @path_value = value
  end

  def permission
    @permission
  end

  def permission= value
    @permission = value
  end

  def self.save_all items
    return unless items.count
    raw_sql = "INSERT INTO Items (name, path, full_path, user_id, type, class_name) VALUES " + (Array.new(items.count, "(?,?,?,?,?,?)")*",")
    params = items.flat_map do |item|
      [item.name, item.path.to_s_rooted, item.full_path, item.user_id, item.type, item.class.name]
    end
    params.insert(0, raw_sql)
    # params = items.each_with_index do |item, index|
      # sql << ", " if (index > 0)
      # sql << "('#{ item.name }', '#{ item.path }', '#{ item.full_path }', #{ item.user_id }, '#{ item.type }', '#{ item.class.name }')"
    # end
    sql = ActiveRecord::Base.send(:sanitize_sql_array, params)
    conn = ActiveRecord::Base.connection
    conn.execute(sql)
  end

end