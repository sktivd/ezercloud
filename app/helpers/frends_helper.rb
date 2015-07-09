module FrendsHelper

  def join_tests(frend)
    test = []
    test << frend.test_id0 if frend.test_id0
    test << frend.test_id1 if frend.test_id1
    test << frend.test_id2 if frend.test_id2
    test.join(':')
  end
  
  def join_results(frend)
    result = []
    result << frend.test_result0 if frend.test_result0
    result << frend.test_result1 if frend.test_result1
    result << frend.test_result2 if frend.test_result2
    result.join(':')
  end
  
end
