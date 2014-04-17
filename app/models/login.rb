class Login
    include ActiveModel::Model
    attr_accessor :email, :password, :remember

    validates :name, :email, presence: true
    validates :name, length: { minimum: 5 }
    validates :email, email_format: { message: "doesn't look like an email address" }
end