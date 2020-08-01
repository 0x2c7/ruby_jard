##
# Config to test pry-related commands. Copy from pry and pry-byebug test base
Pry.config.color = false
Pry.config.pager = false
Pry.config.correct_indent = false

def redirect_pry_io(new_in, new_out = StringIO.new)
  old_in = Pry.input
  old_out = Pry.output
  Pry.input = new_in
  Pry.output = new_out
  begin
    yield
  ensure
    Pry.input = old_in
    Pry.output = old_out
  end
end

class InputTester
  def initialize(*actions)
    @actions = actions
  end

  def add(*actions)
    @actions += actions
  end

  def readline(*)
    @actions.shift
  end
end
