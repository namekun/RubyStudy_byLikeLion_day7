class LottoController < ApplicationController
    def index
        @new_number = Lotto.last
        @numbers = Lotto.all
        
    end
    
    def new
        number = (1..45).to_a.sample(6).sort.to_s
        lotto = Lotto.new
        lotto.numbers = number
        lotto.save
        redirect_to "/lotto" #Rails에서 Post역시 redirect로 접속하는데, 이때는 redirect_to로 한다.
    end

end
