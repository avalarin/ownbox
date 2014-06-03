app_root  = "/home/avalarin/Projects/ownbox"
pid_file   = "#{app_root}/tmp/pids/unicorn.pid"
socket_file= "#{app_root}/tmp/sockets/unicorn.sock"
log_file   = "#{app_root}/log/unicorn.log"
err_log    = "#{app_root}/log/unicorn_error.log"
old_pid    = pid_file + '.oldbin'

timeout 30
worker_processes 4 # Здесь тоже в зависимости от нагрузки, погодных условий и текущей фазы луны
listen socket_file, :backlog => 1024
pid pid_file
stderr_path err_log
stdout_path log_file

preload_app true # Мастер процесс загружает приложение, перед тем, как плодить рабочие процессы.

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=) # Решительно не уверен, что значит эта строка, но я решил ее оставить.

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{app_root}/Gemfile"
end
