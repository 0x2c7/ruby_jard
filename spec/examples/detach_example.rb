def detach
  reader, writer = IO.pipe

  pid = Kernel.spawn(
    "setsid bundle exec ruby #{File.join(File.dirname(__FILE__), 'top_level_example.rb')}",
    out: writer, err: writer, pgroup: true, close_others: true
  )
  Process.detach(pid)
  until reader.eof? || writer.closed?
    content = reader.read_nonblock(2048) rescue nil
    if content.nil?
      sleep 1.to_f / 30
    else
      STDOUT.write content
    end
  end
ensure
  Process.kill('SIGTERM', pid)
end
detach
