module Enumerable
  
  def length_without_nil(exception = nil)
    n = 0
    self.each { |value| n += 1 unless value == exception }
    n
  end
  
  def mean(exception = nil)
    result = self.inject([0, 0]) do |accumulated, value| 
      unless value == exception
        accumulated[0] += value
        accumulated[1] += 1
      end
      accumulated
    end

    if result[1] > 0
      result[0] / result[1].to_f
    else
      nil
    end
  end
  
  def variance(exception = nil)
    result = self.inject([0, 0, 0]) do |accumulated, value| 
      unless value == exception
        accumulated[0] += value * value
        accumulated[1] += value
        accumulated[2] += 1
      end
      accumulated
    end

    if result[2] > 0
      (result[0].to_f - result[1] * result[1] / result[2]) / (result[2] - 1)
    else
      nil
    end
  end
  
  def sd(exception = nil)
    Math.sqrt(self.variance(exception))
  end
  
end

