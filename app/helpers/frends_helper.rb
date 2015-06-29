module FrendsHelper

  def join_tests(frend)
    test = []
    test << frend.test0_id if frend.test0_id
    test << frend.test1_id if frend.test1_id
    test << frend.test2_id if frend.test2_id
    test.join(':')
  end
  
  def join_results(frend)
    result = []
    result << frend.test0_result if frend.test0_result
    result << frend.test1_result if frend.test1_result
    result << frend.test2_result if frend.test2_result
    result.join(':')
  end
  
end
