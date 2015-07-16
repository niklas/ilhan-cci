class Annual < Crunch
  def unpack
    list = []

    csv = File.read 'db/annual.txt'

    csv.lines.each do |line|
      datum, op, cl, hi, lo = line.split

      if op && cl && hi && lo && datum =~ /(\d\d)\.(\d\d)\.(\d{4})/
        epoch = Time.new($3.to_i, $2.to_i, $1.to_i).to_i
        list << Pupple.new(
          epoch,
          german_num(cl),
          german_num(op),
          german_num(hi),
          german_num(lo),
          nil
        )
      end
    end

    list.sort_by(&:epoch)
  end


  def german_num(s)
    s.gsub('.','').sub(',','.').to_f
  end
end
