describe Console::Table do
  
  before do
    @data = [
      ['one', 'two', 'three'],
      ['big long stuff that should wrap', 'short', 'short'],
      ["multiline\nthings", nil, nil]
    ]
    #@table = Table.new(@data, :width => 50)
  end
  
  it 'should output rows correctly'
  it 'should calculate column widths'
  it 'should wrap text as needed'
  it 'should handle nil cells'
  
end