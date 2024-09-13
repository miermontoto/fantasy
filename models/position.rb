require 'colorize'

$POSITIONS = {
  'pos-1' => '[PT]'.yellow,
  'pos-2' => '[DF]'.cyan,
  'pos-3' => '[MC]'.green,
  'pos-4' => '[DL]'.red
}

class Position
  def initialize(str)
    @position = $POSITIONS[str]
  end

  def to_s
    @position
  end
end
