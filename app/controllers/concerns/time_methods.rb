module TimeMethods
  extend ActiveSupport::Concern
    
  private

    def in_sec_ seconds, options = {}
      o = {minor: 2}.merge options
      unit = ["second", "seconds"]
      unit = ["sec", "sec"] if o[:type] == :short
      if seconds == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % seconds) + unit[1]
      end
    end
    
    def in_min_ minutes, options = {}
      o = {minor: 2}.merge options
      unit = ["minute", "minutes"]
      unit = ["min", "min"] if o[:type] == :short
      if minutes == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % minutes) + unit[1]
      end
    end

    def in_h_ hours, options = {}
      o = {minor: 2}.merge options
      unit = ["hour", "hours"]
      unit = ["h", "h"] if o[:type] == :short
      if hours == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % hours) + unit[1]
      end
    end

    def in_d_ days, options = {}
      o = {minor: 2}.merge options
      unit = ["day", "days"]
      unit = ["d", "d"] if o[:type] == :short
      if days == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % days) + unit[1]
      end
    end

    def in_w_ weeks, options = {}
      o = {minor: 2}.merge options
      unit = ["week", "weeks"]
      unit = ["w", "w"] if o[:type] == :short
      if weeks == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % weeks) + unit[1]
      end
    end

    def in_m_ months, options = {}
      o = {minor: 2}.merge options
      unit = ["month", "months"]
      unit = ["m", "m"] if o[:type] == :short
      if months == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % months) + unit[1]
      end
    end

    def in_y_ years, options = {}
      o = {minor: 2}.merge options
      unit = ["year", "years"]
      unit = ["y", "y"] if o[:type] == :short
      if years == 1
        "1 " + unit[0]
      else
        ("%.#{o[:minor]}f " % years) + unit[1]
      end
    end

    def in_seconds seconds, options = {}
      case
      when seconds < 60
        in_sec_ seconds
      when seconds < 3600
        m = (seconds / 60).to_i
        s = seconds % 60
        in_min_(m, options.merge(minor: 0)) + " " + in_sec_(s, options)
      when seconds < 86400
        h = (seconds / 3600).to_i
        m = (seconds % 3600).to_f / 60
        in_h_(h, options.merge(minor: 0)) + " " + in_min_(m, options)
      when seconds < 604800
        d = (seconds / 86400).to_i
        h = (seconds % 86400).to_f / 3600
        in_d_(d, options.merge(minor: 0)) + " " + in_h_(h, options)
      when seconds < 2592000
        w = (seconds / 604800).to_i
        d = (seconds % 604800).to_f / 86400
        in_w_(w, options.merge(minor: 0)) + " " + in_d_(d, options)
      when seconds < 31536000
        m = (seconds / 2592000).to_i
        d = (seconds % 2592000).to_f / 86400
        in_m_(m, options.merge(minor: 0)) + " " + in_d_(d, options)
      else
        y = (seconds / 31536000).to_i
        m = (seconds % 31536000).to_f / 2592000
        in_y_(y, options.merge(minor: 0)) + " " + in_m_(m, options)
      end
    end

end