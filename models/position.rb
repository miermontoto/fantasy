$POSITIONS = {
  'pos-1' => '[PT]',
  'pos-2' => '[DF]',
  'pos-3' => '[MC]',
  'pos-4' => '[DL]'
}

class Position
  def initialize(str)
    @position = $POSITIONS[str]
  end

  def to_s
    @position
  end

  def to_i
    $POSITIONS.key(@position).split('-').last.to_i
  end
end
