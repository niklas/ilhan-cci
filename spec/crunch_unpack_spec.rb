require 'spec_helper'

describe 'unpacking' do
  let(:source) {{
    'data' => {
      'c' => [ 816        , 607       , 312     , 1453    , 0]        ,
      'h' => [ 14         , 0         , 752     , 0       , 589]      ,
      'l' => [ 1863       , 663       , 126     , 1607    , 151]      ,
      'ts' => [ 23931783  , 1         , 1       , 1       , 1]        ,
      'o'  =>  [ 1108204  , 21        , 13      , -29     , -10]      ,
      'v'  =>  [ 43512516 , -37936441 , 1597252 , 3297702 , -4109826] ,
    }
  }}

  let(:crunch)   { Crunch.new }
  before do
    crunch.stub json: source
  end
  let(:unpacked) { crunch.unpacked }
  let(:fun)      { unpacked.first }

  it 'unpacks timestamp' do
    fun[0].should == 1435906980
  end
  it 'unpacks [1] (b + hi - cl)' do
    fun[1].should == 11074.02
  end
  it 'unpacks [2] (b)' do
    fun[2].should == 11082.04
  end
  it 'unpacks [3] (b+hi)' do
    fun[3].should == 11082.18
  end
  it 'unpacks [4] (b-lo)' do
    fun[4].should == 11063.41
  end
  it 'unpacks [5] (h)' do
    fun[5].should == 43512516
  end

  it 'unpacks first line' do
    unpacked.first.should == [1435906980, 11074.02, 11082.04, 11082.18, 11063.41, 43512516]
  end

  it 'unpacks second line' do
    unpacked[1].should == [1435907040, 11068.16, 11074.23, 11074.23, 11067.6, 5576075]
  end

  it 'unpacks all' do
    unpacked.length.should == 5
    unpacked.should == [
      [1435906980, 11074.02, 11082.04, 11082.18, 11063.41, 43512516],
      [1435907040, 11068.16, 11074.23, 11074.23, 11067.6, 5576075],
      [1435907100, 11072.69, 11068.29, 11075.81, 11067.03, 7173327],
      [1435907160, 11057.87, 11072.4, 11072.4, 11056.33, 10471029],
      [1435907220, 11063.66, 11057.77, 11063.66, 11056.26, 6361203],
    ]
  end
end
