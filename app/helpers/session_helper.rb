module SessionHelper

  def current_session
    session_id = cookies['session']
    return nil if !session_id

    session = Session.find_by_id(session_id)
    return nil if !session || session.closed || DateTime.now > session.expires_at;
    session
  end

  def current_user
    session = current_session;
    return nil if !session 
    session.user
  end

  def authenticated?
    return false if !current_user
    true
  end

  def login_user(user, persistence)
    session = Session.new
    session.id = SecureRandom.uuid
    session.user = user;
    session.persistent = persistence
    lifetime = persistence ? Settings.security.persistent_session_lifetime : Settings.security.session_lifetime
    session.expires_at = DateTime.now + lifetime
    session.save!

    cookies['session'] = {   
        value: session.id,
        expires: session.expires_at,
        httponly: true
    }
  end

  def logout_user
    return if !current_session

    session = Session.find(current_session.id)
    session.closed = true
    session.closed_at = DateTime.now
    session.save!

    cookies.delete 'session'
  end 

end